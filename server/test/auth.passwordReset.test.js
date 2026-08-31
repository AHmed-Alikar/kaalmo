import { describe, it, expect, beforeEach, vi } from 'vitest';
import request from 'supertest';

import app from '../src/app.js';
import User from '../src/models/User.js';
import Verification from '../src/models/Verification.js';
import AuditLog from '../src/models/AuditLog.js';
import { passwordResetRateLimiter } from '../src/middleware/rateLimit.js';

// Clear the per-IP counter — used by tests that exercise the per-code attempt
// limit, which would otherwise be masked by the (deliberately lower) IP limit.
async function clearIpRateLimit() {
  for (const key of ['::ffff:127.0.0.1', '::1', '127.0.0.1']) {
    await passwordResetRateLimiter.resetKey(key);
  }
}

// Capture outbound emails (and their codes) without sending anything.
const mail = vi.hoisted(() => ({ outbox: [] }));

vi.mock('../src/services/emailService.js', async (importOriginal) => {
  const actual = await importOriginal();
  const capture = (kind) =>
    vi.fn(async (user, code) => {
      mail.outbox.push({ kind, to: user.email, code });
      return { delivered: true };
    });
  return {
    ...actual,
    sendVerificationEmail: capture('email'),
    sendOrganizerConfirmationEmail: capture('organizer'),
    sendPasswordResetEmail: capture('password_reset'),
  };
});

const API = '/api/v1';

let phoneSeq = 0;
function uniquePhone() {
  phoneSeq += 1;
  return `+25261${String(phoneSeq).padStart(7, '0')}`;
}

async function register(overrides = {}) {
  const body = {
    fullName: 'Test User',
    email: `user${phoneSeq}-${Date.now()}@example.com`,
    phone: uniquePhone(),
    password: 'OriginalPass1',
    ...overrides,
  };
  const res = await request(app).post(`${API}/auth/register`).send(body);
  return { res, body };
}

function codeFor(kind, email) {
  const hits = mail.outbox.filter((m) => m.kind === kind && (!email || m.to === email));
  return hits.length ? hits[hits.length - 1].code : null;
}

beforeEach(() => {
  mail.outbox.length = 0;
});

describe('POST /api/v1/auth/forgot-password', () => {
  it('sends a reset code for a real account and stores only a bcrypt hash', async () => {
    const { body } = await register();
    mail.outbox.length = 0;

    const res = await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ sent: true });

    const code = codeFor('password_reset', body.email);
    expect(code).toMatch(/^\d{6}$/);

    const user = await User.findOne({ email: body.email });
    const record = await Verification.findOne({ userId: user._id, type: 'password_reset' });
    expect(record).toBeTruthy();
    expect(record.status).toBe('pending');
    expect(record.attempts).toBe(0);
    expect(record.token).not.toBe(code); // stored as a hash, not the plaintext code
    expect(record.token.startsWith('$2')).toBe(true); // bcrypt
    const ttlMs = record.expiresAt.getTime() - Date.now();
    expect(ttlMs).toBeGreaterThan(13 * 60 * 1000);
    expect(ttlMs).toBeLessThanOrEqual(15 * 60 * 1000);
  });

  it('returns the same response for an unknown email and sends nothing', async () => {
    const res = await request(app)
      .post(`${API}/auth/forgot-password`)
      .send({ email: 'no-such-person@example.com' });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ sent: true });
    expect(codeFor('password_reset')).toBeNull();
    expect(await Verification.countDocuments({ type: 'password_reset' })).toBe(0);
  });

  it('does not send a reset code to a suspended account (no enumeration)', async () => {
    const { body } = await register();
    await User.updateOne({ email: body.email }, { status: 'suspended' });
    mail.outbox.length = 0;

    const res = await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ sent: true });
    expect(codeFor('password_reset', body.email)).toBeNull();
    expect(await Verification.countDocuments({ type: 'password_reset' })).toBe(0);
  });

  it('throttles to 3 reset requests per account per 15 minutes', async () => {
    const { body } = await register();
    mail.outbox.length = 0;

    for (let i = 0; i < 3; i++) {
      const res = await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });
      expect(res.status).toBe(200);
    }
    expect(mail.outbox.filter((m) => m.kind === 'password_reset').length).toBe(3);

    const fourth = await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });
    expect(fourth.status).toBe(200);
    expect(fourth.body).toEqual({ sent: true });
    // Still 3 — the 4th request produced no email and no new code.
    expect(mail.outbox.filter((m) => m.kind === 'password_reset').length).toBe(3);
  });

  it('invalidates the previous pending code when a new one is requested', async () => {
    const { body } = await register();
    mail.outbox.length = 0;

    await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });
    const firstCode = codeFor('password_reset', body.email);
    await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });

    const user = await User.findOne({ email: body.email });
    const pending = await Verification.find({ userId: user._id, type: 'password_reset', status: 'pending' });
    expect(pending).toHaveLength(1);

    // The superseded code no longer works.
    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code: firstCode, password: 'ReplacementPass1' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('INVALID_CODE');
  });
});

describe('POST /api/v1/auth/reset-password', () => {
  async function requestReset(email) {
    mail.outbox.length = 0;
    await request(app).post(`${API}/auth/forgot-password`).send({ email });
    return codeFor('password_reset', email);
  }

  it('resets the password, verifies the email, and lets the user log in with the new password', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);

    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ reset: true });
    expect(res.body.accessToken).toBeUndefined();
    expect(res.body.refreshToken).toBeUndefined();

    const user = await User.findOne({ email: body.email });
    expect(user.emailVerified).toBe(true);
    expect(user.passwordChangedAt).toBeInstanceOf(Date);

    const login = await request(app)
      .post(`${API}/auth/login`)
      .send({ email: body.email, password: 'BrandNewPass9' });
    expect(login.status).toBe(200);
    expect(login.body.accessToken).toBeTruthy();
  });

  it('rejects the old password after a reset', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);
    await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });

    const login = await request(app)
      .post(`${API}/auth/login`)
      .send({ email: body.email, password: 'OriginalPass1' });
    expect(login.status).toBe(401);
    expect(login.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('does not allow a reset code to be used twice', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);

    const first = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });
    expect(first.status).toBe(200);

    const second = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'AnotherPass123' });
    expect(second.status).toBe(400);
    expect(second.body.error.code).toBe('INVALID_CODE');
  });

  it('burns the code after 5 wrong attempts', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);
    const wrong = code === '000000' ? '111111' : '000000';

    for (let i = 0; i < 5; i++) {
      await clearIpRateLimit(); // isolate the per-code attempt limit from the IP limit
      const res = await request(app)
        .post(`${API}/auth/reset-password`)
        .send({ email: body.email, code: wrong, password: 'BrandNewPass9' });
      expect(res.status).toBe(400);
      expect(res.body.error.code).toBe('INVALID_CODE');
    }

    // Correct code no longer works — the record is spent.
    await clearIpRateLimit();
    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('INVALID_CODE');

    const user = await User.findOne({ email: body.email });
    const record = await Verification.findOne({ userId: user._id, type: 'password_reset' }).sort({ createdAt: -1 });
    expect(record.attempts).toBeGreaterThanOrEqual(5);
    expect(record.status).toBe('rejected');
  });

  it('rejects an expired code', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);

    const user = await User.findOne({ email: body.email });
    await Verification.updateOne(
      { userId: user._id, type: 'password_reset', status: 'pending' },
      { expiresAt: new Date(Date.now() - 1000) }
    );

    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('INVALID_CODE');
  });

  it('rejects a weak password with a validation error', async () => {
    const { body } = await register();
    const code = await requestReset(body.email);

    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'short' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
    expect(res.body.error.fields.password).toBeTruthy();
  });

  it('returns the generic INVALID_CODE error for an unknown email (no enumeration)', async () => {
    const res = await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: 'no-such-person@example.com', code: '123456', password: 'BrandNewPass9' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('INVALID_CODE');
  });
});

describe('refresh-token invalidation after password reset', () => {
  it('rejects refresh tokens issued before the reset and accepts ones issued after', async () => {
    const { res: reg, body } = await register();
    const oldRefreshToken = reg.body.refreshToken;
    expect(oldRefreshToken).toBeTruthy();

    // Ensure the old token's `iat` second is strictly before passwordChangedAt.
    await new Promise((r) => setTimeout(r, 1100));

    mail.outbox.length = 0;
    await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });
    const code = codeFor('password_reset', body.email);
    await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });

    const stale = await request(app).post(`${API}/auth/refresh`).send({ refreshToken: oldRefreshToken });
    expect(stale.status).toBe(401);
    expect(stale.body.error.code).toBe('INVALID_TOKEN');

    const login = await request(app)
      .post(`${API}/auth/login`)
      .send({ email: body.email, password: 'BrandNewPass9' });
    const freshRefresh = await request(app)
      .post(`${API}/auth/refresh`)
      .send({ refreshToken: login.body.refreshToken });
    expect(freshRefresh.status).toBe(200);
    expect(freshRefresh.body.accessToken).toBeTruthy();
  });
});

describe('IP rate limiting on password-reset endpoints', () => {
  it('blocks after 5 requests per hour from one IP', async () => {
    const email = 'ratelimited@example.com';
    for (let i = 0; i < 5; i++) {
      const res = await request(app).post(`${API}/auth/forgot-password`).send({ email });
      expect(res.status).toBe(200);
    }
    const blocked = await request(app).post(`${API}/auth/forgot-password`).send({ email });
    expect(blocked.status).toBe(429);
    expect(blocked.body.error.code).toBe('RATE_LIMITED');
    expect(blocked.body.error).toHaveProperty('fields');
  });
});

describe('audit logging for password reset', () => {
  it('records request and completion without ever storing the code or password', async () => {
    const { body } = await register();
    mail.outbox.length = 0;
    await request(app).post(`${API}/auth/forgot-password`).send({ email: body.email });
    const code = codeFor('password_reset', body.email);
    await request(app)
      .post(`${API}/auth/reset-password`)
      .send({ email: body.email, code, password: 'BrandNewPass9' });

    const user = await User.findOne({ email: body.email });
    const logs = await AuditLog.find({ targetId: user._id }).sort({ createdAt: 1 });
    const actions = logs.map((l) => l.action);
    expect(actions).toContain('auth.password_reset_requested');
    expect(actions).toContain('auth.password_reset_completed');
    for (const log of logs) {
      expect(log.actorType).toBe('user');
      const serialized = JSON.stringify(log.toObject());
      expect(serialized).not.toContain(code);
      expect(serialized).not.toContain('BrandNewPass9');
      expect(serialized).not.toContain('OriginalPass1');
    }

    // The stored reset token is a hash, never the emailed code.
    const record = await Verification.findOne({ userId: user._id, type: 'password_reset' });
    expect(record.token).not.toBe(code);
  });
});

describe('regression — existing auth and OTP flows still work', () => {
  it('register → login → refresh', async () => {
    const { res, body } = await register();
    expect(res.status).toBe(201);
    expect(res.body.accessToken).toBeTruthy();
    expect(res.body.user.email).toBe(body.email);

    const login = await request(app)
      .post(`${API}/auth/login`)
      .send({ email: body.email, password: body.password });
    expect(login.status).toBe(200);

    const refresh = await request(app)
      .post(`${API}/auth/refresh`)
      .send({ refreshToken: login.body.refreshToken });
    expect(refresh.status).toBe(200);
    expect(refresh.body.accessToken).toBeTruthy();
  });

  it('email verification OTP flow is unchanged', async () => {
    mail.outbox.length = 0;
    const { res, body } = await register();
    const accessToken = res.body.accessToken;

    const code = codeFor('email', body.email);
    expect(code).toMatch(/^\d{6}$/);

    const verify = await request(app)
      .post(`${API}/auth/verify-email-otp`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ code });
    expect(verify.status).toBe(200);
    expect(verify.body).toEqual({ verified: true });

    const user = await User.findOne({ email: body.email });
    expect(user.emailVerified).toBe(true);
    // Email OTP records stay plaintext — this flow is deliberately untouched.
    const record = await Verification.findOne({ userId: user._id, type: 'email' }).sort({ createdAt: -1 });
    expect(record.token).toBe(code);
  });

  it('organizer OTP flow is unchanged', async () => {
    mail.outbox.length = 0;
    const { res, body } = await register();
    const accessToken = res.body.accessToken;

    await request(app)
      .post(`${API}/auth/verify-email-otp`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ code: codeFor('email', body.email) });

    const reqAccess = await request(app)
      .post(`${API}/users/me/request-organizer-access`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ purpose: 'Community water project' });
    expect(reqAccess.status).toBe(200);
    expect(reqAccess.body).toEqual({ sent: true });

    const orgCode = codeFor('organizer', body.email);
    expect(orgCode).toMatch(/^\d{6}$/);

    const confirm = await request(app)
      .post(`${API}/users/me/confirm-organizer-access`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ code: orgCode });
    expect(confirm.status).toBe(200);
    expect(confirm.body.confirmed).toBe(true);
    expect(confirm.body.accessToken).toBeTruthy();

    const user = await User.findOne({ email: body.email });
    expect(user.roles).toContain('organizer');
  });

  it('resend-verification-email still works for an unverified user', async () => {
    const { res, body } = await register();
    mail.outbox.length = 0;

    const resend = await request(app)
      .post(`${API}/auth/resend-verification-email`)
      .set('Authorization', `Bearer ${res.body.accessToken}`)
      .send();
    expect(resend.status).toBe(200);
    expect(resend.body).toEqual({ sent: true });
    expect(codeFor('email', body.email)).toMatch(/^\d{6}$/);
  });
});
