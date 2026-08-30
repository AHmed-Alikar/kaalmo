import { z } from 'zod';

export const createTicketSchema = z.object({
  subject: z.string().min(3, 'Subject is too short').max(200),
  message: z.string().min(5, 'Message is too short').max(2000),
  guestName: z.string().max(120).optional(),
  guestEmail: z.string().email('Enter a valid email address').optional(),
});

export const replyTicketSchema = z.object({
  message: z.string().min(1, 'Reply cannot be empty').max(2000),
});

export const updateTicketStatusSchema = z.object({
  status: z.enum(['open', 'in_progress', 'resolved', 'closed']),
});
