import DeviceToken from '../models/DeviceToken.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { logAudit } from '../services/auditLogService.js';

// Register (or refresh) an FCM device token for the current user. Upsert by
// token so re-registration is idempotent; if the token was previously tied to
// another account (device handoff / re-login) it is reassigned here.
export const registerDevice = asyncHandler(async (req, res) => {
  const { token, platform } = req.body;

  const existing = await DeviceToken.findOne({ token });
  const reassigned = existing && String(existing.userId) !== String(req.user.id);

  await DeviceToken.findOneAndUpdate(
    { token },
    { userId: req.user.id, token, platform, lastSeenAt: new Date() },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );

  if (!existing || reassigned) {
    await logAudit({
      actorId: req.user.id,
      actorType: 'user',
      action: 'device.registered',
      targetType: 'User',
      targetId: req.user.id,
      metadata: { platform: platform || 'unknown', reassigned: !!reassigned },
    });
  }

  res.status(200).json({ registered: true });
});

// Remove one token (logout / "sign out this device"). Scoped to the caller —
// a user can only delete their own tokens. Token comes in the body because
// FCM tokens are long and contain URL-unsafe characters.
export const removeDevice = asyncHandler(async (req, res) => {
  const { token } = req.body;
  const del = await DeviceToken.deleteOne({ token, userId: req.user.id });

  if (del.deletedCount) {
    await logAudit({
      actorId: req.user.id,
      actorType: 'user',
      action: 'device.removed',
      targetType: 'User',
      targetId: req.user.id,
    });
  }

  res.status(200).json({ removed: del.deletedCount > 0 });
});

// The caller's own registered devices.
export const listMyDevices = asyncHandler(async (req, res) => {
  const items = await DeviceToken.find({ userId: req.user.id }).sort({ lastSeenAt: -1 }).select('-__v');
  res.json({ items });
});
