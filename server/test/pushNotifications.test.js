import { describe, it, expect, beforeEach, afterAll, vi } from 'vitest';
import request from 'supertest';
import mongoose from 'mongoose';

// Enable FCM before any module reads the config, and stub the Firebase SDK so
// nothing talks to Google.
vi.hoisted(() => {
  process.env.FIREBASE_PROJECT_ID = 'kaalmo-test';
  process.env.FIREBASE_CLIENT_EMAIL = 'test@kaalmo-test.iam.gserviceaccount.com';
  process.env.FIREBASE_PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----\\nSUPERSECRETKEYMATERIAL\\n-----END PRIVATE KEY-----\\n';
});

const fb = vi.hoisted(() => ({ sendEachForMulticast: vi.fn() }));
vi.mock('firebase-admin/app', () => ({
  initializeApp: vi.fn(() => ({ name: 'kaalmo-fcm' })),
  getApps: vi.fn(() => []),
  cert: vi.fn((c) => c),
}));
vi.mock('firebase-admin/messaging', () => ({
  getMessaging: vi.fn(() => ({ sendEachForMulticast: fb.sendEachForMulticast })),
}));

import app from '../src/app.js';
import User from '../src/models/User.js';
import DeviceToken from '../src/models/DeviceToken.js';
import Notification from '../src/models/Notification.js';
import AuditLog from '../src/models/AuditLog.js';
import { sendToUser, isFcmConfigured, normalizePrivateKey } from '../src/services/fcmService.js';
import { notifyUser } from '../src/services/notificationService.js';

const API = '/api/v1';
const SECRET_KEY_MARKER = 'SUPERSECRETKEYMATERIAL';

let seq = 0;
function uniquePhone() {
  seq += 1;
  return `+25263${String(seq).padStart(7, '0')}`;
}

async function registerUser() {
  seq += 1;
  const res = await request(app).post(`${API}/auth/register`).send({
    fullName: 'Push User',
    email: `push${seq}-${Date.now()}@example.com`,
    phone: uniquePhone(),
    password: 'PushPass123',
  });
  return { accessToken: res.body.accessToken, userId: res.body.user.id };
}

beforeEach(() => {
  fb.sendEachForMulticast.mockReset();
  fb.sendEachForMulticast.mockResolvedValue({ responses: [], successCount: 0, failureCount: 0 });
});

afterAll(() => {
  delete process.env.FIREBASE_PROJECT_ID;
  delete process.env.FIREBASE_CLIENT_EMAIL;
  delete process.env.FIREBASE_PRIVATE_KEY;
});

describe('device token registration', () => {
  it('registers a token for an authenticated user', async () => {
    const { accessToken, userId } = await registerUser();

    const res = await request(app)
      .post(`${API}/devices`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ token: 'fcm-token-abcdefghij', platform: 'android' });

    expect(res.status).toBe(200);
    expect(res.body).toEqual({ registered: true });

    const row = await DeviceToken.findOne({ token: 'fcm-token-abcdefghij' });
    expect(String(row.userId)).toBe(userId);
    expect(row.platform).toBe('android');

    const audit = await AuditLog.findOne({ action: 'device.registered', targetId: userId });
    expect(audit).toBeTruthy();
    expect(audit.actorType).toBe('user');
  });

  it('rejects an unauthenticated registration', async () => {
    const res = await request(app).post(`${API}/devices`).send({ token: 'fcm-token-unauth-xyz' });
    expect(res.status).toBe(401);
    expect(await DeviceToken.countDocuments()).toBe(0);
  });

  it('rejects a malformed body', async () => {
    const { accessToken } = await registerUser();
    const res = await request(app)
      .post(`${API}/devices`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ token: 'short', platform: 'nintendo' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  it('is idempotent — re-registering the same token keeps one row', async () => {
    const { accessToken } = await registerUser();
    const body = { token: 'fcm-token-repeat-123456', platform: 'ios' };

    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${accessToken}`).send(body);
    const first = await DeviceToken.findOne({ token: body.token });
    await new Promise((r) => setTimeout(r, 10));
    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${accessToken}`).send(body);

    expect(await DeviceToken.countDocuments({ token: body.token })).toBe(1);
    const second = await DeviceToken.findOne({ token: body.token });
    expect(second.lastSeenAt.getTime()).toBeGreaterThanOrEqual(first.lastSeenAt.getTime());
  });

  it('reassigns a token to the current user on device handoff', async () => {
    const userA = await registerUser();
    const userB = await registerUser();
    const token = 'fcm-token-handoff-999999';

    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${userA.accessToken}`).send({ token });
    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${userB.accessToken}`).send({ token });

    const rows = await DeviceToken.find({ token });
    expect(rows).toHaveLength(1);
    expect(String(rows[0].userId)).toBe(userB.userId);
  });

  it('supports multiple devices per user and lists them', async () => {
    const { accessToken } = await registerUser();
    for (const token of ['fcm-token-dev-a-1111', 'fcm-token-dev-b-2222', 'fcm-token-dev-c-3333']) {
      await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${accessToken}`).send({ token });
    }
    const res = await request(app).get(`${API}/devices`).set('Authorization', `Bearer ${accessToken}`);
    expect(res.status).toBe(200);
    expect(res.body.items).toHaveLength(3);
  });
});

describe('device token removal', () => {
  it('removes the caller’s own token', async () => {
    const { accessToken } = await registerUser();
    const token = 'fcm-token-toremove-1234';
    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${accessToken}`).send({ token });

    const res = await request(app)
      .delete(`${API}/devices`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ token });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ removed: true });
    expect(await DeviceToken.countDocuments({ token })).toBe(0);
  });

  it('will not remove another user’s token', async () => {
    const userA = await registerUser();
    const userB = await registerUser();
    const token = 'fcm-token-notyours-5678';
    await request(app).post(`${API}/devices`).set('Authorization', `Bearer ${userA.accessToken}`).send({ token });

    const res = await request(app)
      .delete(`${API}/devices`)
      .set('Authorization', `Bearer ${userB.accessToken}`)
      .send({ token });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ removed: false });
    expect(await DeviceToken.countDocuments({ token })).toBe(1);
  });

  it('rejects an unauthenticated removal', async () => {
    const res = await request(app).delete(`${API}/devices`).send({ token: 'whatever-token-here' });
    expect(res.status).toBe(401);
  });
});

describe('notification dispatch', () => {
  it('is configured in the test environment', () => {
    expect(isFcmConfigured()).toBe(true);
  });

  it('pushes to every registered device of the user', async () => {
    const { userId } = await registerUser();
    await DeviceToken.create([
      { userId, token: 'dispatch-token-1' },
      { userId, token: 'dispatch-token-2' },
    ]);
    fb.sendEachForMulticast.mockResolvedValue({
      responses: [{ success: true }, { success: true }],
    });

    const result = await sendToUser(userId, {
      title: 'Donation confirmed',
      body: 'Your donation of $50 has been confirmed.',
      data: { type: 'donation_confirmed', targetUrl: '/campaigns/abc' },
    });

    expect(fb.sendEachForMulticast).toHaveBeenCalledTimes(1);
    const arg = fb.sendEachForMulticast.mock.calls[0][0];
    expect(arg.tokens.sort()).toEqual(['dispatch-token-1', 'dispatch-token-2']);
    expect(arg.notification).toEqual({ title: 'Donation confirmed', body: 'Your donation of $50 has been confirmed.' });
    expect(arg.data).toEqual({ type: 'donation_confirmed', targetUrl: '/campaigns/abc' });
    // Android must get a high-priority notification block on the app's channel
    // so the system tray shows it while backgrounded / terminated.
    expect(arg.android.priority).toBe('high');
    expect(arg.android.notification).toMatchObject({ channelId: 'kaalmo_default', priority: 'high' });
    expect(result.sent).toBe(2);
  });

  it('notifyUser stores an in-app notification AND fires a push', async () => {
    const { userId } = await registerUser();
    await DeviceToken.create({ userId, token: 'notify-token-1' });
    fb.sendEachForMulticast.mockResolvedValue({ responses: [{ success: true }] });

    await notifyUser({
      userId,
      type: 'campaign_approve',
      title: 'Campaign approved',
      body: 'Your campaign is live.',
      targetUrl: '/organizer',
    });

    expect(await Notification.countDocuments({ userId, type: 'campaign_approve' })).toBe(1);
    await vi.waitFor(() => expect(fb.sendEachForMulticast).toHaveBeenCalled());
    const arg = fb.sendEachForMulticast.mock.calls[0][0];
    expect(arg.data.type).toBe('campaign_approve');
    expect(arg.data.targetUrl).toBe('/organizer');
  });

  it('push data carries the originating notification id for deep-link + mark-read', async () => {
    const { userId } = await registerUser();
    await DeviceToken.create({ userId, token: 'notif-id-token-1' });
    fb.sendEachForMulticast.mockResolvedValue({ responses: [{ success: true }] });

    await notifyUser({
      userId,
      type: 'donation_confirmed',
      title: 'Donation confirmed',
      body: 'Thank you',
      targetUrl: '/campaigns/abc',
    });

    const notif = await Notification.findOne({ userId, type: 'donation_confirmed' });
    await vi.waitFor(() => expect(fb.sendEachForMulticast).toHaveBeenCalled());
    const arg = fb.sendEachForMulticast.mock.calls[0][0];
    expect(arg.data.notificationId).toBe(String(notif._id));
    // Still no secrets / free-form text in the data map — navigation metadata only.
    expect(Object.keys(arg.data).sort()).toEqual(['notificationId', 'targetUrl', 'type']);
  });

  it('skips push when the user disabled it, but still stores the in-app notification', async () => {
    const { userId } = await registerUser();
    await User.findByIdAndUpdate(userId, { pushEnabled: false });
    await DeviceToken.create({ userId, token: 'disabled-user-token' });

    await notifyUser({ userId, type: 'campaign_update', title: 'Update', body: 'New update' });

    expect(await Notification.countDocuments({ userId })).toBe(1);
    const result = await sendToUser(userId, { title: 'x', body: 'y' });
    expect(result.skipped).toBe('push_disabled');
    expect(fb.sendEachForMulticast).not.toHaveBeenCalled();
  });
});

describe('invalid FCM token cleanup', () => {
  it('deletes tokens the gateway reports as unregistered, keeps the rest', async () => {
    const { userId } = await registerUser();
    await DeviceToken.create([
      { userId, token: 'good-token-keep' },
      { userId, token: 'dead-token-remove' },
    ]);

    fb.sendEachForMulticast.mockImplementation(async ({ tokens }) => ({
      responses: tokens.map((t) =>
        t === 'dead-token-remove'
          ? { success: false, error: { code: 'messaging/registration-token-not-registered' } }
          : { success: true }
      ),
    }));

    const result = await sendToUser(userId, { title: 'x', body: 'y' });

    expect(result.sent).toBe(1);
    expect(result.failed).toBe(1);
    expect(result.cleaned).toBe(1);
    expect(await DeviceToken.findOne({ token: 'dead-token-remove' })).toBeNull();
    expect(await DeviceToken.findOne({ token: 'good-token-keep' })).toBeTruthy();
  });

  it('no-ops safely when the user has no devices', async () => {
    const { userId } = await registerUser();
    const result = await sendToUser(userId, { title: 'x', body: 'y' });
    expect(result.skipped).toBe('no_devices');
    expect(fb.sendEachForMulticast).not.toHaveBeenCalled();
  });
});

describe('credential safety', () => {
  it('never writes the Firebase private key to the logs', async () => {
    const logSpy = vi.spyOn(console, 'log').mockImplementation(() => {});
    const errSpy = vi.spyOn(console, 'error').mockImplementation(() => {});

    const { userId } = await registerUser();
    await DeviceToken.create({ userId, token: 'log-safety-token' });
    fb.sendEachForMulticast.mockRejectedValue(Object.assign(new Error('boom'), { code: 'messaging/internal-error' }));

    await sendToUser(userId, { title: 'x', body: 'y' });

    const everything = [...logSpy.mock.calls, ...errSpy.mock.calls].flat().map(String).join(' ');
    expect(everything).not.toContain(SECRET_KEY_MARKER);

    logSpy.mockRestore();
    errSpy.mockRestore();
  });

  it('normalizePrivateKey accepts the shapes a service-account key arrives in', () => {
    const BODY = 'AAAABBBBCCCCDDDD';
    const pem = `-----BEGIN PRIVATE KEY-----\n${BODY}\n-----END PRIVATE KEY-----\n`;

    // already-clean PEM is unchanged
    expect(normalizePrivateKey(pem)).toBe(pem);
    // \n escape sequences -> real newlines
    expect(normalizePrivateKey(`-----BEGIN PRIVATE KEY-----\\n${BODY}\\n-----END PRIVATE KEY-----\\n`)).toBe(pem);
    // stray/unbalanced surrounding quote (the real .env bug) + CRLF paste
    expect(normalizePrivateKey(`"-----BEGIN PRIVATE KEY-----\\r\\n${BODY}\\r\\n-----END PRIVATE KEY-----\\n`)).toBe(pem);
    // matched quote pair + missing trailing newline
    expect(normalizePrivateKey(`'-----BEGIN PRIVATE KEY-----\\n${BODY}\\n-----END PRIVATE KEY-----'`)).toBe(pem);
  });

  it('does not expose pushEnabled changes or tokens through an unrelated endpoint', async () => {
    const { accessToken } = await registerUser();
    const res = await request(app)
      .patch(`${API}/users/me`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ pushEnabled: false });
    expect(res.status).toBe(200);
    expect(res.body.pushEnabled).toBe(false);
    expect(res.body.passwordHash).toBeUndefined();
  });
});

describe('unconfigured environment', () => {
  it('sendToUser no-ops when FCM env is absent, in-app notification still works', async () => {
    const saved = {
      p: process.env.FIREBASE_PROJECT_ID,
      c: process.env.FIREBASE_CLIENT_EMAIL,
      k: process.env.FIREBASE_PRIVATE_KEY,
    };
    delete process.env.FIREBASE_PROJECT_ID;
    delete process.env.FIREBASE_CLIENT_EMAIL;
    delete process.env.FIREBASE_PRIVATE_KEY;
    try {
      const { userId } = await registerUser();
      await DeviceToken.create({ userId, token: 'unconfigured-token' });

      await notifyUser({ userId, type: 'security_alert', title: 'New login', body: 'A new device signed in' });

      expect(await Notification.countDocuments({ userId, type: 'security_alert' })).toBe(1);
      const result = await sendToUser(userId, { title: 'x', body: 'y' });
      expect(result.skipped).toBe('not_configured');
      expect(result.configured).toBe(false);
    } finally {
      process.env.FIREBASE_PROJECT_ID = saved.p;
      process.env.FIREBASE_CLIENT_EMAIL = saved.c;
      process.env.FIREBASE_PRIVATE_KEY = saved.k;
    }
  });
});
