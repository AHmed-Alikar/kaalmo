import mongoose from 'mongoose';

const userSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true },
    email: { type: String, required: true, unique: true, index: true, lowercase: true, trim: true },
    phone: { type: String, required: true, unique: true, index: true, trim: true },
    passwordHash: { type: String, required: true },
    roles: {
      type: [String],
      enum: ['donor', 'organizer', 'beneficiary', 'admin', 'moderator', 'support'],
      default: ['donor'],
    },
    language: { type: String, enum: ['so', 'en'], default: 'so' },
    emailVerified: { type: Boolean, default: false },
    phoneVerified: { type: Boolean, default: false },
    identityVerified: { type: Boolean, default: false },
    status: { type: String, enum: ['active', 'suspended', 'banned'], default: 'active' },
    // Set whenever the password changes (e.g. password reset). Refresh tokens
    // issued before this moment are rejected in authService.refresh().
    passwordChangedAt: { type: Date },
    // Master switch for push (FCM) delivery. In-app notifications are always
    // stored regardless.
    pushEnabled: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export default mongoose.model('User', userSchema);
