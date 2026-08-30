import SupportTicket from '../models/SupportTicket.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { logAudit } from '../services/auditLogService.js';
import { notifyUser } from '../services/notificationService.js';

// Public — reachable from the Contact page whether or not the sender is
// logged in (optionalAuth). A guest must supply a name+email so support can
// reach back; a logged-in user's ticket is tied to their account instead.
export const createTicket = asyncHandler(async (req, res) => {
  const { subject, message, guestName, guestEmail } = req.body;

  if (!req.user && (!guestName || !guestEmail)) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'Name and email are required', {
      guestName: guestName ? undefined : 'required',
      guestEmail: guestEmail ? undefined : 'required',
    });
  }

  const ticket = await SupportTicket.create({
    userId: req.user?.id,
    guestName: req.user ? undefined : guestName,
    guestEmail: req.user ? undefined : guestEmail,
    subject,
    message,
  });

  res.status(201).json(ticket);
});

export const listMyTickets = asyncHandler(async (req, res) => {
  const tickets = await SupportTicket.find({ userId: req.user.id }).sort({ updatedAt: -1 });
  res.json(tickets);
});

export const getMyTicket = asyncHandler(async (req, res) => {
  const ticket = await SupportTicket.findOne({ _id: req.params.id, userId: req.user.id });
  if (!ticket) throw new ApiError(404, 'NOT_FOUND', 'Support ticket not found');
  res.json(ticket);
});

export const replyToMyTicket = asyncHandler(async (req, res) => {
  const ticket = await SupportTicket.findOne({ _id: req.params.id, userId: req.user.id });
  if (!ticket) throw new ApiError(404, 'NOT_FOUND', 'Support ticket not found');

  ticket.replies.push({ authorId: req.user.id, authorRole: 'user', message: req.body.message });
  // A reply from the user means the conversation is active again.
  if (['resolved', 'closed'].includes(ticket.status)) ticket.status = 'open';
  await ticket.save();

  res.status(201).json(ticket);
});

// --- Admin ---

export const listSupportTickets = asyncHandler(async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;
  const filter = {};
  if (status) filter.status = status;

  const skip = (Number(page) - 1) * Number(limit);
  const [items, total] = await Promise.all([
    SupportTicket.find(filter).sort({ updatedAt: -1 }).skip(skip).limit(Number(limit)).populate('userId', 'fullName email'),
    SupportTicket.countDocuments(filter),
  ]);

  res.json({ items, total, page: Number(page), limit: Number(limit) });
});

export const getSupportTicket = asyncHandler(async (req, res) => {
  const ticket = await SupportTicket.findById(req.params.id).populate('userId', 'fullName email');
  if (!ticket) throw new ApiError(404, 'NOT_FOUND', 'Support ticket not found');
  res.json(ticket);
});

export const replyToSupportTicket = asyncHandler(async (req, res) => {
  const ticket = await SupportTicket.findById(req.params.id);
  if (!ticket) throw new ApiError(404, 'NOT_FOUND', 'Support ticket not found');

  ticket.replies.push({ authorId: req.user.id, authorRole: 'admin', message: req.body.message });
  if (ticket.status === 'open') ticket.status = 'in_progress';
  await ticket.save();

  await logAudit({
    actorId: req.user.id,
    action: 'support_ticket.replied',
    targetType: 'SupportTicket',
    targetId: ticket._id,
  });

  if (ticket.userId) {
    await notifyUser({
      userId: ticket.userId,
      type: 'support_reply',
      title: 'Support replied to your ticket',
      body: `"${ticket.subject}" has a new reply from support.`,
      targetUrl: '/support',
    });
  }

  res.status(201).json(ticket);
});

export const updateSupportTicketStatus = asyncHandler(async (req, res) => {
  const ticket = await SupportTicket.findById(req.params.id);
  if (!ticket) throw new ApiError(404, 'NOT_FOUND', 'Support ticket not found');

  ticket.status = req.body.status;
  await ticket.save();

  await logAudit({
    actorId: req.user.id,
    action: 'support_ticket.status_changed',
    targetType: 'SupportTicket',
    targetId: ticket._id,
    metadata: { status: ticket.status },
  });

  res.json(ticket);
});
