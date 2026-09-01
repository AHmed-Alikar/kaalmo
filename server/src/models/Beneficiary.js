import mongoose from 'mongoose';

// A beneficiary is created either by an organizer inviting someone to a
// campaign, or (legacy / standalone) by a user submitting their own details.
// Lifecycle:
//   invited -> accepted -> pending (submitted, awaiting admin review)
//     -> verified | rejected | needs_more_information
// `needs_more_information` and `rejected` both allow the beneficiary to
// resubmit, which moves the record back to `pending`.
const beneficiarySchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
    campaignId: { type: mongoose.Schema.Types.ObjectId, ref: 'Campaign', index: true },
    invitedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    inviteEmail: { type: String, lowercase: true, trim: true, index: true },
    fullName: { type: String },
    idDocumentUrl: { type: String },
    verificationStatus: {
      type: String,
      enum: ['invited', 'accepted', 'pending', 'verified', 'rejected', 'needs_more_information'],
      default: 'pending',
    },
    reviewNote: { type: String },
    reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    reviewedAt: { type: Date },
    verifiedAt: { type: Date },
    verifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    payoutAccountId: { type: mongoose.Schema.Types.ObjectId, ref: 'PayoutAccount' },
  },
  { timestamps: true }
);

export default mongoose.model('Beneficiary', beneficiarySchema);
