import Notification from '../models/Notification.js';
import { sendToUser as fcmSendToUser } from './fcmService.js';

// Single chokepoint for user-facing notifications. Always records an in-app
// Notification; additionally fires an FCM push (best-effort) when configured.
// `data` is an optional string map passed through to the push payload for
// mobile deep-linking.
export async function notifyUser({ userId, type, title, body, targetUrl, data }) {
  let notificationId;
  try {
    const doc = await Notification.create({ userId, type, title, body, targetUrl });
    notificationId = doc?._id ? String(doc._id) : undefined;
  } catch (err) {
    // A failed notification must never break the action that triggered it.
    console.error('[notificationService] failed to create notification:', err.message);
  }

  // Fire-and-forget so push latency never shows up in the request. fcmService
  // has its own error handling and is a no-op when FCM is not configured.
  // The data map carries only structured navigation metadata (never secrets or
  // sensitive text): the mobile client routes on `type` + `targetUrl` and marks
  // the originating in-app notification read via `notificationId`.
  Promise.resolve(
    fcmSendToUser(userId, {
      title,
      body,
      data: {
        type,
        ...(notificationId ? { notificationId } : {}),
        ...(targetUrl ? { targetUrl } : {}),
        ...(data || {}),
      },
    })
  ).catch((err) => console.error('[notificationService] push dispatch failed:', err.message));
}
