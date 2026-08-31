import { z } from 'zod';

export const registerDeviceSchema = z.object({
  token: z.string().min(10).max(4096),
  platform: z.enum(['ios', 'android', 'web']).optional(),
});

export const removeDeviceSchema = z.object({
  token: z.string().min(10).max(4096),
});
