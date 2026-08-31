import rateLimit from 'express-rate-limit';

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many attempts, please try again later', fields: {} } },
});

// Password reset is a high-value target for abuse (account takeover attempts,
// mailbox flooding) — kept tighter than the general auth limiter. Per-account
// throttling is additionally enforced inside authService (Constitution Sec. 77).
export const passwordResetRateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000,
  limit: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many password reset attempts, please try again later', fields: {} } },
});

export const donationRateLimiter = rateLimit({
  windowMs: 5 * 60 * 1000,
  limit: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: { code: 'RATE_LIMITED', message: 'Too many donation attempts, please slow down', fields: {} } },
});
