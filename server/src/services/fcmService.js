// Firebase Cloud Messaging dispatch. Kept behind the same "configured or
// silent no-op" pattern as emailService: with no FIREBASE_* env the rest of
// the app (and in-app notifications) work unchanged.
//
// Credentials are read from the environment only and are NEVER logged — logs
// carry counts and FCM error codes, nothing else.

import DeviceToken from '../models/DeviceToken.js';
import User from '../models/User.js';

// FCM error codes that mean "this token is dead, stop sending to it".
const DEAD_TOKEN_CODES = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
  'messaging/invalid-argument',
]);

let messagingPromise = null;

// Evaluated live (not cached) so configuration is picked up without a restart
// and stays deterministic under test.
export function isFcmConfigured() {
  return Boolean(
    process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY
  );
}

// Lazily import and initialise firebase-admin so an unconfigured deployment
// never loads the SDK.
async function getMessaging() {
  if (!isFcmConfigured()) return null;
  if (!messagingPromise) {
    messagingPromise = (async () => {
      const { initializeApp, getApps, cert } = await import('firebase-admin/app');
      const { getMessaging: adminGetMessaging } = await import('firebase-admin/messaging');
      const app =
        getApps().find((a) => a.name === 'kaalmo-fcm') ||
        initializeApp(
          {
            credential: cert({
              projectId: process.env.FIREBASE_PROJECT_ID,
              clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
              // Support both raw multiline and \n-escaped single-line values.
              privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
            }),
          },
          'kaalmo-fcm'
        );
      return adminGetMessaging(app);
    })().catch((err) => {
      messagingPromise = null;
      console.error('[fcmService] failed to initialise Firebase Admin:', err.message);
      return null;
    });
  }
  return messagingPromise;
}

function toStringDataMap(data = {}) {
  const out = {};
  for (const [k, v] of Object.entries(data)) {
    if (v === undefined || v === null) continue;
    out[k] = typeof v === 'string' ? v : String(v);
  }
  return out;
}

// Push a notification to every registered device of one user. Best-effort:
// never throws, prunes dead tokens, returns a small summary for tests/logs.
export async function sendToUser(userId, { title, body, data } = {}) {
  const result = { configured: isFcmConfigured(), sent: 0, failed: 0, cleaned: 0, skipped: null };
  try {
    if (!result.configured) {
      result.skipped = 'not_configured';
      return result;
    }

    const user = await User.findById(userId).select('pushEnabled');
    if (!user) {
      result.skipped = 'no_user';
      return result;
    }
    if (user.pushEnabled === false) {
      result.skipped = 'push_disabled';
      return result;
    }

    const devices = await DeviceToken.find({ userId }).select('token');
    if (devices.length === 0) {
      result.skipped = 'no_devices';
      return result;
    }

    const messaging = await getMessaging();
    if (!messaging) {
      result.skipped = 'init_failed';
      return result;
    }

    const tokens = devices.map((d) => d.token);
    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: toStringDataMap(data),
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });

    const deadTokens = [];
    response.responses.forEach((r, i) => {
      if (r.success) {
        result.sent += 1;
        return;
      }
      result.failed += 1;
      if (r.error && DEAD_TOKEN_CODES.has(r.error.code)) deadTokens.push(tokens[i]);
    });

    if (deadTokens.length) {
      const del = await DeviceToken.deleteMany({ token: { $in: deadTokens } });
      result.cleaned = del.deletedCount || 0;
    }

    return result;
  } catch (err) {
    // Never let a push failure break the action that triggered it.
    console.error('[fcmService] sendToUser failed:', err.code || err.message);
    result.failed += 1;
    return result;
  }
}
