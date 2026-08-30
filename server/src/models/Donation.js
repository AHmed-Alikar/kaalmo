import mongoose from 'mongoose';

const donationSchema = new mongoose.Schema(
  {
    campaignId: { type: mongoose.Schema.Types.ObjectId, ref: 'Campaign', required: true, index: true },
    donorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true, sparse: true },
    amount: { type: Number, required: true, min: 0.01 },
    currency: { type: String, default: 'USD' },
    isAnonymous: { type: Boolean, default: false },
    message: { type: String },
    paymentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Payment', index: true },
    paymentTransactionId: { type: mongoose.Schema.Types.ObjectId, ref: 'PaymentTransaction' },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'failed', 'refunded'],
      default: 'pending',
      index: true,
    },
  },
  { timestamps: true }
);

export default mongoose.model('Donation', donationSchema);
