import { Router } from 'express';
import * as authController from '../controllers/authController.js';
import { validate } from '../middleware/validate.js';
import { authRateLimiter, passwordResetRateLimiter } from '../middleware/rateLimit.js';
import { requireAuth } from '../middleware/auth.js';
import {
  registerSchema,
  loginSchema,
  refreshSchema,
  verifyOtpSchema,
  verifyEmailOtpSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
} from '../validators/authValidators.js';

const router = Router();

router.post('/register', authRateLimiter, validate(registerSchema), authController.register);
router.post('/login', authRateLimiter, validate(loginSchema), authController.login);
router.post('/refresh', validate(refreshSchema), authController.refresh);
router.post('/verify-email-otp', requireAuth, authRateLimiter, validate(verifyEmailOtpSchema), authController.verifyEmailOtp);
router.post('/resend-verification-email', requireAuth, authRateLimiter, authController.resendVerificationEmail);
router.post('/verify-otp', authRateLimiter, validate(verifyOtpSchema), authController.verifyOtp);
router.post('/forgot-password', passwordResetRateLimiter, validate(forgotPasswordSchema), authController.forgotPassword);
router.post('/reset-password', passwordResetRateLimiter, validate(resetPasswordSchema), authController.resetPassword);

export default router;
