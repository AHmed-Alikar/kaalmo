import { z } from 'zod';

export const createReportSchema = z.object({
  targetType: z.enum(['campaign', 'user', 'comment']),
  targetId: z.string().min(1),
  reason: z.string().min(5).max(500),
});

export const reviewReportSchema = z.object({
  status: z.enum(['under_review', 'reviewed', 'resolved', 'dismissed']),
  reviewNote: z.string().max(500).optional(),
});
