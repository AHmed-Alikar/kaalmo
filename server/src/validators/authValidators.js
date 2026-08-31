import { z } from 'zod';

// Shared so registration and password reset enforce identical password rules
// (bcrypt's own limit is 72 bytes).
const passwordField = z.string().min(8).max(72);

export const registerSchema = z.object({
  fullName: z.string().min(2).max(100),
  email: z.string().email(),
  phone: z.string().min(7).max(20),
  password: passwordField,
  language: z.enum(['so', 'en']).optional().default('so'),
});

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export const verifyOtpSchema = z.object({
  phone: z.string().min(7).max(20),
  code: z.string().min(4).max(8),
});

export const verifyEmailOtpSchema = z.object({
  code: z.string().length(6),
});

export const forgotPasswordSchema = z.object({
  email: z.string().email(),
});

export const resetPasswordSchema = z.object({
  email: z.string().email(),
  code: z.string().length(6),
  password: passwordField,
});
