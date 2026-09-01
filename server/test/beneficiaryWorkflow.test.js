import { describe, it, expect } from 'vitest';
import request from 'supertest';

import app from '../src/app.js';
import User from '../src/models/User.js';
import Campaign from '../src/models/Campaign.js';
import Beneficiary from '../src/models/Beneficiary.js';
import AuditLog from '../src/models/AuditLog.js';

const API = '/api/v1';
let seq = 0;

async function makeUser(role) {
  seq += 1;
  const email = `bw${seq}-${Date.now()}@example.com`;
  const res = await request(app).post(`${API}/auth/register`).send({
    fullName: `User ${seq}`,
    email,
    phone: `+25264${String(seq).padStart(7, '0')}`,
    password: 'Passw0rd123',
  });
  const userId = res.body.user.id;
  if (role) {
    await User.findByIdAndUpdate(userId, { $addToSet: { roles: role }, emailVerified: true });
    // re-login so the token carries the new role
    const relog = await request(app).post(`${API}/auth/login`).send({ email, password: 'Passw0rd123' });
    return { userId, email, token: relog.body.accessToken };
  }
  return { userId, email, token: res.body.accessToken };
}

async function makeCampaign(token) {
  const res = await request(app)
    .post(`${API}/campaigns`)
    .set('Authorization', `Bearer ${token}`)
    .send({
      title: { so: 'Olole tijaabo ah' },
      story: { so: 'Sheeko dheer oo ku filan si loo gaaro xadka ugu yar.' },
      category: 'Medical',
      goalAmount: 1000,
    });
  return res.body._id;
}

describe('beneficiary invitation + verification workflow', () => {
  it('invite → accept does NOT verify; submit → pending; admin approves', async () => {
    const organizer = await makeUser('organizer');
    const beneficiary = await makeUser();
    const admin = await makeUser('admin');
    const campaignId = await makeCampaign(organizer.token);

    // 1. organizer invites the beneficiary by email
    const invite = await request(app)
      .post(`${API}/campaigns/${campaignId}/beneficiary`)
      .set('Authorization', `Bearer ${organizer.token}`)
      .send({ email: beneficiary.email });
    expect(invite.status).toBe(201);
    expect(invite.body.verificationStatus).toBe('invited');

    // campaign is linked
    const camp = await Campaign.findById(campaignId);
    expect(String(camp.beneficiaryId)).toBe(String(invite.body._id));

    // 2. beneficiary sees the invite
    const invites = await request(app)
      .get(`${API}/beneficiaries/invites/mine`)
      .set('Authorization', `Bearer ${beneficiary.token}`);
    expect(invites.body).toHaveLength(1);

    // 3. accept — must NOT auto-verify
    const accepted = await request(app)
      .post(`${API}/beneficiaries/invites/${invite.body._id}/accept`)
      .set('Authorization', `Bearer ${beneficiary.token}`);
    expect(accepted.status).toBe(200);
    expect(accepted.body.verificationStatus).toBe('accepted');

    // 4. submit verification → pending review
    const submitted = await request(app)
      .post(`${API}/beneficiaries/me`)
      .set('Authorization', `Bearer ${beneficiary.token}`)
      .send({ fullName: 'Real Name', idDocumentUrl: 'https://example.com/id.jpg' });
    expect(submitted.status).toBe(201);
    expect(submitted.body.verificationStatus).toBe('pending');

    // 5. organizer sees the beneficiary status for their campaign
    const orgView = await request(app)
      .get(`${API}/campaigns/${campaignId}/beneficiary`)
      .set('Authorization', `Bearer ${organizer.token}`);
    expect(orgView.body.verificationStatus).toBe('pending');

    // 6. admin review → needs_more_information (audited)
    const nmi = await request(app)
      .patch(`${API}/admin/beneficiaries/${invite.body._id}/review`)
      .set('Authorization', `Bearer ${admin.token}`)
      .send({ status: 'needs_more_information', reviewNote: 'ID photo is blurry.' });
    expect(nmi.status).toBe(200);
    expect(nmi.body.verificationStatus).toBe('needs_more_information');
    expect(nmi.body.reviewNote).toBe('ID photo is blurry.');
    expect(await AuditLog.findOne({ action: 'beneficiary.needs_more_information' })).toBeTruthy();

    // 7. beneficiary resubmits → pending again
    const resub = await request(app)
      .post(`${API}/beneficiaries/me`)
      .set('Authorization', `Bearer ${beneficiary.token}`)
      .send({ fullName: 'Real Name', idDocumentUrl: 'https://example.com/id2.jpg' });
    expect(resub.body.verificationStatus).toBe('pending');

    // 8. admin approves
    const approved = await request(app)
      .patch(`${API}/admin/beneficiaries/${invite.body._id}/review`)
      .set('Authorization', `Bearer ${admin.token}`)
      .send({ status: 'verified' });
    expect(approved.body.verificationStatus).toBe('verified');
    expect(await AuditLog.findOne({ action: 'beneficiary.verified' })).toBeTruthy();

    // campaign now carries the verified badge
    const finalCamp = await Campaign.findById(campaignId);
    expect(finalCamp.verificationBadges).toContain('beneficiary_verified');
  });

  it('cannot submit verification before accepting the invitation', async () => {
    const organizer = await makeUser('organizer');
    const beneficiary = await makeUser();
    const campaignId = await makeCampaign(organizer.token);
    await request(app)
      .post(`${API}/campaigns/${campaignId}/beneficiary`)
      .set('Authorization', `Bearer ${organizer.token}`)
      .send({ email: beneficiary.email });

    // still `invited` — no accept yet
    const early = await request(app)
      .post(`${API}/beneficiaries/me`)
      .set('Authorization', `Bearer ${beneficiary.token}`)
      .send({ fullName: 'Real Name', idDocumentUrl: 'https://example.com/id.jpg' });
    expect(early.status).toBe(409);
    expect(early.body.error.code).toBe('NOT_ACCEPTED');
  });

  it('only the campaign owner can assign a beneficiary', async () => {
    const owner = await makeUser('organizer');
    const other = await makeUser('organizer');
    const campaignId = await makeCampaign(owner.token);

    const res = await request(app)
      .post(`${API}/campaigns/${campaignId}/beneficiary`)
      .set('Authorization', `Bearer ${other.token}`)
      .send({ email: 'someone@example.com' });
    expect(res.status).toBe(403);
  });

  it('a non-admin cannot review a beneficiary', async () => {
    const organizer = await makeUser('organizer');
    const beneficiary = await makeUser();
    const campaignId = await makeCampaign(organizer.token);
    const invite = await request(app)
      .post(`${API}/campaigns/${campaignId}/beneficiary`)
      .set('Authorization', `Bearer ${organizer.token}`)
      .send({ email: beneficiary.email });

    const res = await request(app)
      .patch(`${API}/admin/beneficiaries/${invite.body._id}/review`)
      .set('Authorization', `Bearer ${organizer.token}`)
      .send({ status: 'verified' });
    expect(res.status).toBe(403);
  });
});
