import mongoose from 'mongoose';

// One row per (user, device) FCM registration token. A user may have several
// (phone + tablet). `token` is globally unique — if the same device token is
// re-registered under a different account (device resale / re-login), the row
// is reassigned to the current user rather than duplicated.
const deviceTokenSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    token: { type: String, required: true, unique: true },
    platform: { type: String, enum: ['ios', 'android', 'web'], default: undefined },
    lastSeenAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

export default mongoose.model('DeviceToken', deviceTokenSchema);
