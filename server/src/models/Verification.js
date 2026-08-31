import mongoose from 'mongoose';

const verificationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
    beneficiaryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Beneficiary', index: true },
    type: {
      type: String,
      enum: ['email', 'phone', 'identity', 'beneficiary', 'payment', 'organization', 'organizer_request', 'password_reset'],
      required: true,
    },
    status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
    documentUrls: { type: [String], default: [] },
    reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    token: { type: String }, // email verification / organizer OTP: plaintext code. password_reset: bcrypt hash of the code.
    // Wrong-guess counter — only used by the password_reset flow (max attempts enforced in authService).
    attempts: { type: Number, default: 0 },
    expiresAt: { type: Date },
  },
  { timestamps: true }
);

export default mongoose.model('Verification', verificationSchema);
