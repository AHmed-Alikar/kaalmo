// EVC Plus (Hormuud) mobile money via the WaafiPay gateway (spec Section 14).
// USSD push flow: WaafiPay's API_PURCHASE call sends a payment prompt to the
// donor's phone and the request itself blocks until the donor enters their
// PIN (or the request times out) — the response tells us success/failure
// synchronously, so there is no separate "confirm" step or webhook to wait on.

import https from 'node:https';
import Payment from '../../models/Payment.js';
import PaymentTransaction from '../../models/PaymentTransaction.js';
import { ApiError } from '../../utils/ApiError.js';

const REQUEST_TIMEOUT_MS = 30_000;

// Somali mobile numbers are accepted in any common local shape
// (0616123456, 616123456, +252616123456) and normalized to 252XXXXXXXXX,
// the format WaafiPay's accountNo expects.
export function normalizeSomaliPhone(raw) {
  const digits = String(raw || '').replace(/[^\d]/g, '');
  if (digits.startsWith('252') && digits.length === 12) return digits;
  if (digits.startsWith('0') && digits.length === 10) return `252${digits.slice(1)}`;
  if (digits.length === 9) return `252${digits}`;
  return null;
}

// Node's built-in fetch() (undici) hangs indefinitely against WaafiPay's
// endpoint in this environment despite curl/https.request working fine —
// using the plain https module here sidesteps that.
function callWaafiPay(serviceName, serviceParams) {
  const baseUrl = process.env.WAAFIPAY_BASE_URL;
  if (!baseUrl || !process.env.WAAFIPAY_API_KEY) {
    return Promise.reject(new ApiError(501, 'PROVIDER_NOT_IMPLEMENTED', 'EVC Plus is not configured yet'));
  }

  const body = JSON.stringify({
    schemaVersion: '1.0',
    requestId: String(Date.now()) + Math.floor(Math.random() * 1000),
    timestamp: new Date().toISOString(),
    channelName: 'WEB',
    serviceName,
    serviceParams: {
      merchantUid: process.env.WAAFIPAY_MERCHANT_UID,
      apiUserId: process.env.WAAFIPAY_API_USER_ID,
      apiKey: process.env.WAAFIPAY_API_KEY,
      ...serviceParams,
    },
  });

  return new Promise((resolve, reject) => {
    const req = https.request(
      baseUrl,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      },
      (res) => {
        let raw = '';
        res.on('data', (chunk) => { raw += chunk; });
        res.on('end', () => {
          try {
            resolve(JSON.parse(raw));
          } catch {
            reject(new ApiError(502, 'PAYMENT_GATEWAY_ERROR', 'EVC Plus returned an unexpected response. Please try again.'));
          }
        });
      }
    );

    req.on('error', () => {
      reject(new ApiError(502, 'PAYMENT_GATEWAY_ERROR', 'Could not reach EVC Plus right now. Please try again.'));
    });
    req.setTimeout(REQUEST_TIMEOUT_MS, () => {
      req.destroy();
      reject(new ApiError(504, 'PAYMENT_TIMEOUT', 'EVC Plus did not respond in time. Please try again.'));
    });

    req.write(body);
    req.end();
  });
}

export const waafiPayProvider = {
  // Kept for interface parity with other providers — WaafiPay's model is a
  // single synchronous purchase call, so the real work happens in charge().
  async createPaymentIntent({ campaignId, donorId, amount, currency }) {
    const payment = await Payment.create({
      campaignId,
      donorId,
      amount,
      currency,
      provider: 'mobile_money',
      status: 'pending',
    });
    return { paymentId: payment._id, status: payment.status };
  },

  async charge({ campaignId, donorId, amount, currency, phone, description }) {
    const accountNo = normalizeSomaliPhone(phone);
    if (!accountNo) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Enter a valid Somali mobile money number', { phone: 'invalid' });
    }

    const payment = await Payment.create({
      campaignId,
      donorId,
      amount,
      currency,
      provider: 'mobile_money',
      status: 'pending',
    });

    const data = await callWaafiPay('API_PURCHASE', {
      paymentMethod: 'mwallet_account',
      payerInfo: { accountNo },
      transactionInfo: {
        referenceId: String(payment._id),
        invoiceId: String(payment._id),
        amount: Number(amount).toFixed(2),
        currency,
        description: description || 'Kaalmo donation',
      },
    });

    const approved = data.responseCode === '2001' && data.params?.state === 'APPROVED';

    const transaction = await PaymentTransaction.create({
      paymentId: payment._id,
      provider: 'mobile_money',
      providerTransactionId: data.params?.transactionId || `waafipay-${payment._id}-${Date.now()}`,
      amount,
      currency,
      status: approved ? 'confirmed' : 'failed',
      rawPayload: data,
    });

    payment.status = approved ? 'confirmed' : 'failed';
    await payment.save();

    if (!approved) {
      // WaafiPay's responseMsg is a technical code (e.g. RCS_INSUFFICIENT_BALANCE) —
      // never surface it raw to the donor (Design_Rules.md Rule 17/29).
      const friendly = FAILURE_MESSAGES[data.responseMsg] || 'The payment was declined. Please try again or use a different method.';
      throw new ApiError(402, 'PAYMENT_DECLINED', friendly, { providerMessage: data.responseMsg });
    }

    return { paymentId: payment._id, status: 'confirmed', transaction };
  },

  async confirmPayment() {
    // No-op: WaafiPay purchases are confirmed synchronously in charge().
    throw new ApiError(400, 'NOT_SUPPORTED', 'EVC Plus payments are confirmed automatically and cannot be confirmed manually');
  },

  async handleWebhook() {
    // Not used — WaafiPay's API_PURCHASE response is authoritative and synchronous.
    return { handled: false };
  },

  async refund({ paymentId }) {
    const payment = await Payment.findById(paymentId);
    if (!payment) throw new ApiError(404, 'NOT_FOUND', 'Payment not found');
    // Real reversal requires WaafiPay's refund service call — not yet wired up.
    payment.status = 'refunded';
    await payment.save();
    return { payment };
  },
};

const FAILURE_MESSAGES = {
  RCS_INSUFFICIENT_BALANCE: 'Insufficient EVC Plus balance for this donation.',
  RCS_USER_REJECTED: 'The payment was cancelled on your phone.',
  RCS_TIMEOUT: 'You did not respond to the payment prompt in time. Please try again.',
};
