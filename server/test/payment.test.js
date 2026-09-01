import { describe, it, expect, beforeEach, vi } from 'vitest';
import request from 'supertest';
import mongoose from 'mongoose';

// Control the WaafiPay HTTP layer — no live gateway, no real money.
const wp = vi.hoisted(() => ({
  callWaafiPay: vi.fn(),
  isWaafiPayConfigured: vi.fn(() => true),
}));
vi.mock('../src/integrations/payments/waafiPayClient.js', () => ({
  callWaafiPay: wp.callWaafiPay,
  isWaafiPayConfigured: wp.isWaafiPayConfigured,
}));

import app from '../src/app.js';
import User from '../src/models/User.js';
import Campaign from '../src/models/Campaign.js';
import Donation from '../src/models/Donation.js';
import Payment from '../src/models/Payment.js';
import PaymentTransaction from '../src/models/PaymentTransaction.js';
import AuditLog from '../src/models/AuditLog.js';
import { ApiError } from '../src/utils/ApiError.js';
import { normalizeSomaliPhone } from '../src/integrations/payments/WaafiPayProvider.js';

const API = '/api/v1';

let seq = 0;
function uniquePhone() {
  seq += 1;
  return `+25262${String(seq).padStart(7, '0')}`;
}

async function makeCampaign(overrides = {}) {
  seq += 1;
  const organizer = await User.create({
    fullName: 'Organizer',
    email: `org${seq}-${Date.now()}@example.com`,
    phone: uniquePhone(),
    passwordHash: 'x',
    roles: ['organizer'],
    emailVerified: true,
  });
  return Campaign.create({
    organizerId: organizer._id,
    title: { so: 'Caawimaad caafimaad', en: 'Medical help' },
    story: { so: 'Sababta caawimaadda oo faahfaahsan halkan ku qoran.', en: 'Story' },
    category: 'Medical',
    goalAmount: 1000,
    currency: 'USD',
    status: 'active',
    ...overrides,
  });
}

beforeEach(() => {
  wp.callWaafiPay.mockReset();
  wp.isWaafiPayConfigured.mockReturnValue(true);
});

describe('POST /api/v1/campaigns/:id/donate — manual provider', () => {
  it('records a valid donation with consistent Payment / Transaction / Donation', async () => {
    const campaign = await makeCampaign();

    const res = await request(app).post(`${API}/campaigns/${campaign._id}/donate`).send({ amount: 50 });

    expect(res.status).toBe(201);
    expect(res.body.payment.status).toBe('confirmed');
    expect(res.body.raisedAmount).toBe(50);
    expect(res.body.note).toBe('Donation confirmed.');

    const payment = await Payment.findById(res.body.donation.paymentId);
    const txn = await PaymentTransaction.findOne({ paymentId: payment._id });
    const donation = await Donation.findById(res.body.donation._id);

    expect(payment.provider).toBe('manual');
    expect(payment.status).toBe('confirmed');
    expect(txn.status).toBe('confirmed');
    expect(donation.status).toBe('confirmed');
    // amount integrity across all three records
    expect(payment.amount).toBe(50);
    expect(txn.amount).toBe(50);
    expect(donation.amount).toBe(50);

    const fresh = await Campaign.findById(campaign._id);
    expect(fresh.raisedAmount).toBe(50);

    const audit = await AuditLog.findOne({ targetId: donation._id, action: 'payment.confirmed' });
    expect(audit).toBeTruthy();
    expect(audit.actorType).toBe('system'); // guest donation
  });

  it('attributes the audit log to the donor when authenticated', async () => {
    const campaign = await makeCampaign();
    const reg = await request(app).post(`${API}/auth/register`).send({
      fullName: 'Donor', email: `d${Date.now()}@example.com`, phone: uniquePhone(), password: 'DonorPass1',
    });

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .set('Authorization', `Bearer ${reg.body.accessToken}`)
      .send({ amount: 25 });
    expect(res.status).toBe(201);

    const audit = await AuditLog.findOne({ targetId: res.body.donation._id, action: 'payment.confirmed' });
    expect(audit.actorType).toBe('user');
  });

  it.each([[0], [-5], [0.009], [null], ['abc']])('rejects invalid amount %p', async (amount) => {
    const campaign = await makeCampaign();
    const res = await request(app).post(`${API}/campaigns/${campaign._id}/donate`).send({ amount });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('accepts the minimum donation of 0.01', async () => {
    const campaign = await makeCampaign();
    const res = await request(app).post(`${API}/campaigns/${campaign._id}/donate`).send({ amount: 0.01 });
    expect(res.status).toBe(201);
    expect(res.body.donation.amount).toBe(0.01);
  });

  it('returns 404 for a non-existent campaign', async () => {
    const res = await request(app)
      .post(`${API}/campaigns/${new mongoose.Types.ObjectId()}/donate`)
      .send({ amount: 10 });
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe('NOT_FOUND');
  });

  it('rejects a donation to a non-public campaign', async () => {
    const campaign = await makeCampaign({ status: 'draft' });
    const res = await request(app).post(`${API}/campaigns/${campaign._id}/donate`).send({ amount: 10 });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('CAMPAIGN_NOT_OPEN');
  });

  it('rejects an unsupported provider', async () => {
    const campaign = await makeCampaign();
    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 10, provider: 'paypal' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('requires a phone number for evc_plus', async () => {
    const campaign = await makeCampaign();
    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 10, provider: 'evc_plus' });
    expect(res.status).toBe(400);
    expect(res.body.error.fields.phone).toBeTruthy();
    expect(wp.callWaafiPay).not.toHaveBeenCalled();
  });
});

describe('idempotency — duplicate donation requests', () => {
  it('a retried request with the same Idempotency-Key does not charge twice', async () => {
    const campaign = await makeCampaign();
    const key = 'client-generated-key-123';

    const first = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .set('Idempotency-Key', key)
      .send({ amount: 40 });
    const second = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .set('Idempotency-Key', key)
      .send({ amount: 40 });

    expect(first.status).toBe(201);
    expect(second.status).toBe(201);
    expect(second.body.donation._id).toBe(first.body.donation._id);

    expect(await Donation.countDocuments({ campaignId: campaign._id })).toBe(1);
    expect(await Payment.countDocuments({ campaignId: campaign._id })).toBe(1);

    const fresh = await Campaign.findById(campaign._id);
    expect(fresh.raisedAmount).toBe(40); // not 80
  });
});

describe('POST /api/v1/campaigns/:id/donate — evc_plus (WaafiPay, mocked)', () => {
  const approve = () =>
    wp.callWaafiPay.mockResolvedValue({
      responseCode: '2001',
      params: { state: 'APPROVED', transactionId: 'WP-TXN-001' },
    });

  it('confirms an approved USSD-push charge', async () => {
    const campaign = await makeCampaign();
    approve();

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 30, provider: 'evc_plus', phone: '0615123456' });

    expect(res.status).toBe(201);
    expect(res.body.payment.status).toBe('confirmed');
    const txn = await PaymentTransaction.findOne({ paymentId: res.body.donation.paymentId });
    expect(txn.provider).toBe('mobile_money');
    expect(txn.providerTransactionId).toBe('WP-TXN-001');
    expect(txn.status).toBe('confirmed');
  });

  it('declines and records a failed payment (no donation) when the gateway rejects', async () => {
    const campaign = await makeCampaign();
    wp.callWaafiPay.mockResolvedValue({
      responseCode: '5310',
      responseMsg: 'RCS_INSUFFICIENT_BALANCE',
      params: { state: 'FAILED' },
    });

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 30, provider: 'evc_plus', phone: '0615123456' });

    expect(res.status).toBe(402);
    expect(res.body.error.code).toBe('PAYMENT_DECLINED');
    expect(await Donation.countDocuments({ campaignId: campaign._id })).toBe(0);
    const payment = await Payment.findOne({ campaignId: campaign._id });
    expect(payment.status).toBe('failed');
    const txn = await PaymentTransaction.findOne({ paymentId: payment._id });
    expect(txn.status).toBe('failed');
    const fresh = await Campaign.findById(campaign._id);
    expect(fresh.raisedAmount).toBe(0);
  });

  it('surfaces a provider timeout as 504 PAYMENT_TIMEOUT', async () => {
    const campaign = await makeCampaign();
    wp.callWaafiPay.mockRejectedValue(new ApiError(504, 'PAYMENT_TIMEOUT', 'EVC Plus did not respond in time.'));

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 30, provider: 'evc_plus', phone: '0615123456' });
    expect(res.status).toBe(504);
    expect(res.body.error.code).toBe('PAYMENT_TIMEOUT');
  });

  it('surfaces a malformed gateway response as 502', async () => {
    const campaign = await makeCampaign();
    wp.callWaafiPay.mockRejectedValue(new ApiError(502, 'PAYMENT_GATEWAY_ERROR', 'Unexpected response.'));

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 30, provider: 'evc_plus', phone: '0615123456' });
    expect(res.status).toBe(502);
  });

  it('returns 501 when the provider is not configured', async () => {
    const campaign = await makeCampaign();
    wp.callWaafiPay.mockRejectedValue(
      new ApiError(501, 'PROVIDER_NOT_IMPLEMENTED', 'EVC Plus is not configured yet')
    );

    const res = await request(app)
      .post(`${API}/campaigns/${campaign._id}/donate`)
      .send({ amount: 30, provider: 'evc_plus', phone: '0615123456' });
    expect(res.status).toBe(501);
    expect(res.body.error.code).toBe('PROVIDER_NOT_IMPLEMENTED');
  });
});

describe('transaction integrity', () => {
  it('raisedAmount equals the sum of confirmed donations', async () => {
    const campaign = await makeCampaign();
    for (const amount of [10, 20, 30]) {
      await request(app).post(`${API}/campaigns/${campaign._id}/donate`).send({ amount });
    }
    const fresh = await Campaign.findById(campaign._id);
    const confirmed = await Donation.aggregate([
      { $match: { campaignId: campaign._id, status: 'confirmed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } },
    ]);
    expect(fresh.raisedAmount).toBe(60);
    expect(confirmed[0].total).toBe(60);
  });

  it('rejects a duplicate provider transaction id at the ledger', async () => {
    const payment = await Payment.create({ amount: 5, currency: 'USD', provider: 'manual', status: 'confirmed' });
    await PaymentTransaction.create({
      paymentId: payment._id, provider: 'manual', providerTransactionId: 'DUP-1', amount: 5, currency: 'USD', status: 'confirmed',
    });
    await expect(
      PaymentTransaction.create({
        paymentId: payment._id, provider: 'manual', providerTransactionId: 'DUP-1', amount: 5, currency: 'USD', status: 'confirmed',
      })
    ).rejects.toThrow();
  });
});

describe('GET /api/v1/payments/config', () => {
  it('lists manual only when WaafiPay is not configured', async () => {
    wp.isWaafiPayConfigured.mockReturnValue(false);
    const res = await request(app).get(`${API}/payments/config`);
    expect(res.status).toBe(200);
    expect(res.body.providers).toEqual(['manual']);
    expect(res.body.currency).toBe('USD');
    expect(res.body.minAmount).toBe(0.01);
  });

  it('includes evc_plus when WaafiPay is configured', async () => {
    wp.isWaafiPayConfigured.mockReturnValue(true);
    const res = await request(app).get(`${API}/payments/config`);
    expect(res.body.providers).toContain('evc_plus');
  });
});

describe('normalizeSomaliPhone', () => {
  it.each([
    ['0615123456', '252615123456'],
    ['615123456', '252615123456'],
    ['+252615123456', '252615123456'],
    ['252615123456', '252615123456'],
  ])('normalizes %s → %s', (input, expected) => {
    expect(normalizeSomaliPhone(input)).toBe(expected);
  });

  it.each([['123'], [''], [null], ['06151234567890']])('rejects %p', (input) => {
    expect(normalizeSomaliPhone(input)).toBeNull();
  });
});
