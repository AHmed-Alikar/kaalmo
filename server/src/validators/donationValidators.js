import { z } from 'zod';

// Body for POST /api/v1/campaigns/:id/donate. Currency is never accepted from
// the client — it is taken from the campaign in the controller.
export const createDonationSchema = z.object({
  // Minimum donation is 0.01 (one cent) — same rule on web and mobile.
  amount: z.number().min(0.01).max(1_000_000),
  provider: z.enum(['manual', 'evc_plus']).optional().default('manual'),
  phone: z.string().min(7).max(20).optional(),
  message: z.string().max(500).optional(),
  isAnonymous: z.boolean().optional().default(false),
});
