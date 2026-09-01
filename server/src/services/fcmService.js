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

// A Firebase service-account private_key survives a lot of round-trips before it
// reaches us (copied out of JSON, pasted into .env, edited on Windows). Accept
// every common shape and hand firebase-admin a clean PEM:
//   - value wrapped in a stray/unbalanced " or ' (dotenv leaves an unbalanced
//     quote in place — this was the actual bug)
//   - \n / \r\n escape sequences instead of real newlines
//   - literal CR characters from a CRLF paste
//   - a missing trailing newline
// Never logged.
export function normalizePrivateKey(raw) {
  if (!raw) return raw;
  let key = raw.trim();
  // strip a matched surrounding quote pair, then any leftover stray quotes
  if ((key.startsWith('"') && key.endsWith('"')) || (key.startsWith("'") && key.endsWith("'"))) {
    key = key.slice(1, -1);
  }
  key = key.replace(/^['"]+/, '').replace(/['"]+$/, '');
  // escape sequences -> real newlines; drop carriage returns
  key = key.replace(/\\r/g, '').replace(/\\n/g, '\n').replace(/\r/g, '');
  if (!key.endsWith('\n')) key += '\n';
  return key;
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
              privateKey: normalizePrivateKey(process.env.FIREBASE_PRIVATE_KEY),
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
  // Diagnostic breadcrumb: says whether we even attempt a send. Never logs the
  // token, the notification text or any credential — only counts and FCM error
  // codes. `type` comes from the structured data map.
  const tag = `[fcmService] sendToUser user=${userId} type=${data?.type || '-'}`;
  try {
    if (!result.configured) {
      result.skipped = 'not_configured';
      console.warn(`${tag} -> SKIPPED not_configured (no FIREBASE_* env — nothing sent to Firebase)`);
      return result;
    }

    const user = await User.findById(userId).select('pushEnabled');
    if (!user) {
      result.skipped = 'no_user';
      return result;
    }
    if (user.pushEnabled === false) {
      result.skipped = 'push_disabled';
      console.warn(`${tag} -> SKIPPED push_disabled (user turned push off)`);
      return result;
    }

    const devices = await DeviceToken.find({ userId }).select('token');
    if (devices.length === 0) {
      result.skipped = 'no_devices';
      console.warn(`${tag} -> SKIPPED no_devices (user has no registered push token)`);
      return result;
    }

    const messaging = await getMessaging();
    if (!messaging) {
      result.skipped = 'init_failed';
      console.error(`${tag} -> SKIPPED init_failed (Firebase Admin failed to initialise — check credentials)`);
      return result;
    }

    const tokens = devices.map((d) => d.token);
    const response = await messaging.sendEachForMulticast({
      tokens,
      // Keep a top-level `notification` block: this makes it a *notification
      // message* so Android auto-displays a system-tray notification while the
      // app is backgrounded or terminated (a data-only message would not).
      notification: { title, body },
      data: toStringDataMap(data),
      android: {
        priority: 'high',
        notification: {
          // Target the high-importance channel MainActivity creates. Without a
          // channelId here Android 8+ relies solely on the manifest
          // default-channel metadata, which is dropped silently if that
          // channel does not exist yet in a fresh (terminated-app) process.
          channelId: 'kaalmo_default',
          priority: 'high',
          sound: 'default',
          defaultVibrateTimings: true,
        },
      },
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

    // Distinct FCM error codes (not messages) so a real-device failure is
    // diagnosable from the server log alone.
    const errorCodes = [
      ...new Set(response.responses.filter((r) => !r.success).map((r) => r.error?.code || 'unknown')),
    ];
    console.log(
      `${tag} -> SENT devices=${tokens.length} success=${result.sent} failure=${result.failed}` +
        (errorCodes.length ? ` errors=${errorCodes.join(',')}` : '') +
        (result.cleaned ? ` cleaned=${result.cleaned}` : '')
    );

    return result;
  } catch (err) {
    // Never let a push failure break the action that triggered it.
    console.error('[fcmService] sendToUser failed:', err.code || err.message);
    result.failed += 1;
    return result;
  }
}
