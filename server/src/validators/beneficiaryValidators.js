import { z } from 'zod';

export const submitBeneficiarySchema = z.object({
  fullName: z.string().min(2).max(100),
  idDocumentUrl: z.string().url().optional(),
});

// Organizer invites a beneficiary to a campaign by email.
export const inviteBeneficiarySchema = z.object({
  email: z.string().email(),
});

// Admin review of a submitted beneficiary.
export const reviewBeneficiarySchema = z.object({
  status: z.enum(['verified', 'rejected', 'needs_more_information']),
  reviewNote: z.string().max(1000).optional(),
});
