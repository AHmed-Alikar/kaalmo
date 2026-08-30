import mongoose from 'mongoose';

// Each reply records who wrote it and their role at the time, so the thread
// stays legible even if the admin's role changes later.
const replySchema = new mongoose.Schema(
  {
    authorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    authorRole: { type: String, enum: ['user', 'admin'], required: true },
    message: { type: String, required: true, maxlength: 2000 },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

// Submitted from the public Contact page (spec Section 24). `userId` is set
// when the sender is logged in; guestName/guestEmail cover anonymous
// submissions so support can still reach back out.
const supportTicketSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', index: true },
    guestName: { type: String, maxlength: 120 },
    guestEmail: { type: String, maxlength: 200, lowercase: true, trim: true },
    subject: { type: String, required: true, maxlength: 200 },
    message: { type: String, required: true, maxlength: 2000 },
    status: {
      type: String,
      enum: ['open', 'in_progress', 'resolved', 'closed'],
      default: 'open',
      index: true,
    },
    replies: [replySchema],
  },
  { timestamps: true }
);

export default mongoose.model('SupportTicket', supportTicketSchema);
