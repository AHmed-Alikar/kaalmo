import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import User from '../models/User.js';
import Verification from '../models/Verification.js';
import { ApiError } from '../utils/ApiError.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwt.js';
import { sendVerificationEmail, sendOrganizerConfirmationEmail, sendPasswordResetEmail } from './emailService.js';
import { logAudit } from './auditLogService.js';

const EMAIL_OTP_TTL_MS = 15 * 60 * 1000; // 15 minutes — email verification / organizer-request codes

// Password reset — see Constitution Sec. 24 (short-lived, single-use) and Sec. 77/78.
const RESET_OTP_TTL_MS = 15 * 60 * 1000; // reset code lifetime
const RESET_MAX_ATTEMPTS = 5; // wrong-guess attempts per code before it is burned
const RESET_MAX_PER_WINDOW = 3; // forgot-password requests per account per window
const RESET_RESEND_WINDOW_MS = 15 * 60 * 1000;
const BCRYPT_COST = 12; // matches register()

function generateOtp() {
  return crypto.randomInt(0, 1000000).toString().padStart(6, '0');
}

function issueTokens(user) {
  const payload = { sub: user._id.toString(), roles: user.roles };
  return {
    accessToken: signAccessToken(payload),
    refreshToken: signRefreshToken(payload),
  };
}

function toPublicUser(user) {
  return {
    id: user._id,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    roles: user.roles,
    language: user.language,
    emailVerified: user.emailVerified,
    phoneVerified: user.phoneVerified,
    identityVerified: user.identityVerified,
    status: user.status,
    pushEnabled: user.pushEnabled,
  };
}

export async function register({ fullName, email, phone, password, language }) {
  const existing = await User.findOne({ $or: [{ email }, { phone }] });
  if (existing) {
    throw new ApiError(409, 'ALREADY_EXISTS', 'An account with this email or phone already exists');
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await User.create({ fullName, email, phone, passwordHash, language });

  const code = generateOtp();
  await Verification.create({
    userId: user._id,
    type: 'email',
    status: 'pending',
    token: code,
    expiresAt: new Date(Date.now() + EMAIL_OTP_TTL_MS),
  });
  const emailResult = await sendVerificationEmail(user, code);
  if (!emailResult.delivered && !emailResult.dev) {
    // Don't block account creation on email delivery — but make the failure
    // visible instead of silently pretending the email went out.
    console.warn(`[authService] Verification email failed to send for ${user.email}:`, emailResult.error);
  }

  const tokens = issueTokens(user);
  return { user: toPublicUser(user), ...tokens };
}

export async function login({ email, password }) {
  const user = await User.findOne({ email });
  if (!user) {
    throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    throw new ApiError(401, 'INVALID_CREDENTIALS', 'Email or password is incorrect');
  }

  if (user.status !== 'active') {
    throw new ApiError(403, 'ACCOUNT_DISABLED', 'This account is suspended or banned');
  }

  const tokens = issueTokens(user);
  return { user: toPublicUser(user), ...tokens };
}

export async function refresh({ refreshToken }) {
  let payload;
  try {
    payload = verifyRefreshToken(refreshToken);
  } catch {
    throw new ApiError(401, 'INVALID_TOKEN', 'Refresh token is invalid or expired');
  }

  const user = await User.findById(payload.sub);
  if (!user || user.status !== 'active') {
    throw new ApiError(401, 'INVALID_TOKEN', 'Refresh token is invalid or expired');
  }

  // Any refresh token minted before the last password change is dead — this is
  // how a password reset invalidates existing sessions (Constitution Sec. 24/25).
  // JWT `iat` is second-resolution, so compare at the same granularity.
  if (user.passwordChangedAt && payload.iat < Math.floor(user.passwordChangedAt.getTime() / 1000)) {
    throw new ApiError(401, 'INVALID_TOKEN', 'Refresh token is invalid or expired');
  }

  return issueTokens(user);
}

export async function verifyEmailOtp(userId, code) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');

  if (user.emailVerified) {
    return { verified: true };
  }

  const record = await Verification.findOne({ userId: user._id, type: 'email', status: 'pending' }).sort({
    createdAt: -1,
  });

  if (!record || record.expiresAt < new Date()) {
    throw new ApiError(400, 'INVALID_CODE', 'This code has expired. Please request a new one.');
  }

  if (record.token !== code) {
    throw new ApiError(400, 'INVALID_CODE', 'That code is incorrect. Please check your email and try again.');
  }

  record.status = 'approved';
  await record.save();
  user.emailVerified = true;
  await user.save();

  return { verified: true };
}

export async function resendVerificationEmail(userId) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');
  if (user.emailVerified) {
    throw new ApiError(409, 'ALREADY_VERIFIED', 'This email address is already verified');
  }

  await Verification.deleteMany({ userId: user._id, type: 'email', status: 'pending' });

  const code = generateOtp();
  await Verification.create({
    userId: user._id,
    type: 'email',
    status: 'pending',
    token: code,
    expiresAt: new Date(Date.now() + EMAIL_OTP_TTL_MS),
  });
  const result = await sendVerificationEmail(user, code);

  if (!result.delivered) {
    throw new ApiError(
      502,
      'EMAIL_SEND_FAILED',
      'The verification email could not be sent. Please try again shortly or contact support.'
    );
  }

  return { sent: true };
}

// --- Password reset (Constitution Sec. 24) ---
//
// Two steps: forgotPassword() emails a 6-digit code; resetPassword() consumes
// it. Security invariants:
//  - The response NEVER reveals whether an email is registered (no enumeration).
//  - The code is stored only as a bcrypt hash; the plaintext lives only in the
//    email and the single request that verifies it. It is never logged.
//  - 15-minute expiry, single-use, max 5 wrong guesses, one active code at a
//    time, and a per-account request throttle on top of the IP rate limiter.
//  - A successful reset stamps user.passwordChangedAt, which kills every
//    previously issued refresh token (see refresh()).

export async function forgotPassword({ email }) {
  const user = await User.findOne({ email });

  // Silent no-op for unknown or disabled accounts — same response, no email,
  // no DB write. Suspended/banned users don't get to reset their way back in.
  if (user && user.status === 'active') {
    const windowStart = new Date(Date.now() - RESET_RESEND_WINDOW_MS);
    const recentRequests = await Verification.countDocuments({
      userId: user._id,
      type: 'password_reset',
      createdAt: { $gte: windowStart },
    });

    if (recentRequests < RESET_MAX_PER_WINDOW) {
      // Invalidate (don't delete) any still-pending code so it still counts
      // toward the throttle window above, and leaves a trail.
      await Verification.updateMany(
        { userId: user._id, type: 'password_reset', status: 'pending' },
        { status: 'rejected' }
      );

      const code = generateOtp();
      const tokenHash = await bcrypt.hash(code, BCRYPT_COST);
      await Verification.create({
        userId: user._id,
        type: 'password_reset',
        status: 'pending',
        token: tokenHash,
        attempts: 0,
        expiresAt: new Date(Date.now() + RESET_OTP_TTL_MS),
      });

      const result = await sendPasswordResetEmail(user, code);
      if (!result.delivered && !result.dev) {
        // Don't change the response on a delivery failure — that would leak
        // that the address exists. Make it visible in the logs only.
        console.warn(`[authService] Password reset email failed to send for ${user.email}:`, result.error);
      }

      await logAudit({
        actorId: user._id,
        actorType: 'user',
        action: 'auth.password_reset_requested',
        targetType: 'User',
        targetId: user._id,
      });
    }
  }

  return { sent: true };
}

export async function resetPassword({ email, code, password }) {
  // One generic failure for every "can't use this code" case, so a caller
  // can't tell an unknown email from a wrong/expired code.
  const invalidCode = () =>
    new ApiError(400, 'INVALID_CODE', 'This reset code is invalid or has expired. Please request a new one.');

  const user = await User.findOne({ email });
  if (!user) throw invalidCode();

  const record = await Verification.findOne({
    userId: user._id,
    type: 'password_reset',
    status: 'pending',
  }).sort({ createdAt: -1 });

  if (!record || record.expiresAt < new Date() || record.attempts >= RESET_MAX_ATTEMPTS) {
    throw invalidCode();
  }

  const matches = await bcrypt.compare(code, record.token);
  if (!matches) {
    record.attempts += 1;
    if (record.attempts >= RESET_MAX_ATTEMPTS) record.status = 'rejected';
    await record.save();
    throw invalidCode();
  }

  // Burn this code and any siblings.
  record.status = 'approved';
  await record.save();
  await Verification.updateMany(
    { userId: user._id, type: 'password_reset', status: 'pending', _id: { $ne: record._id } },
    { status: 'rejected' }
  );

  user.passwordHash = await bcrypt.hash(password, BCRYPT_COST);
  user.passwordChangedAt = new Date();
  // Receiving the emailed code proves control of the address.
  user.emailVerified = true;
  await user.save();

  await logAudit({
    actorId: user._id,
    actorType: 'user',
    action: 'auth.password_reset_completed',
    targetType: 'User',
    targetId: user._id,
  });

  // Deliberately no tokens — the user re-authenticates with the new password.
  return { reset: true };
}

// Becoming an organizer requires its own dedicated email confirmation — a
// separate, deliberate step from general account email verification — so
// nobody ends up with organizer access just by loading a page (spec intent:
// "isn't easily becoming an organizer"). Requesting access never grants the
// role by itself; only submitting the emailed code does.
export async function requestOrganizerAccess(userId, { fullName, purpose } = {}) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');

  if (!user.emailVerified) {
    throw new ApiError(403, 'EMAIL_NOT_VERIFIED', 'Please verify your email address first');
  }
  if (user.roles.includes('organizer')) {
    throw new ApiError(409, 'ALREADY_ORGANIZER', 'This account already has organizer access');
  }

  if (fullName && fullName.trim() && fullName.trim() !== user.fullName) {
    user.fullName = fullName.trim();
    await user.save();
  }

  await Verification.deleteMany({ userId: user._id, type: 'organizer_request', status: 'pending' });

  const code = generateOtp();
  await Verification.create({
    userId: user._id,
    type: 'organizer_request',
    status: 'pending',
    token: code,
    expiresAt: new Date(Date.now() + EMAIL_OTP_TTL_MS),
  });

  const result = await sendOrganizerConfirmationEmail(user, code, purpose?.trim());
  if (!result.delivered) {
    throw new ApiError(
      502,
      'EMAIL_SEND_FAILED',
      'The confirmation email could not be sent. Please try again shortly.'
    );
  }

  return { sent: true };
}

export async function confirmOrganizerAccess(userId, code) {
  const user = await User.findById(userId);
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');

  // The JWT access token carries the roles claim from whenever it was
  // issued — updating the DB role alone leaves any already-issued token
  // stale, so requireRole('organizer') keeps rejecting requests until the
  // next login. Reissue tokens here so the new role takes effect immediately.
  if (user.roles.includes('organizer')) {
    return { confirmed: true, ...issueTokens(user) };
  }

  const record = await Verification.findOne({ userId: user._id, type: 'organizer_request', status: 'pending' }).sort({
    createdAt: -1,
  });

  if (!record || record.expiresAt < new Date()) {
    throw new ApiError(400, 'INVALID_CODE', 'This code has expired. Please request a new one.');
  }

  if (record.token !== code) {
    throw new ApiError(400, 'INVALID_CODE', 'That code is incorrect. Please check your email and try again.');
  }

  record.status = 'approved';
  await record.save();

  user.roles.push('organizer');
  await user.save();

  return { confirmed: true, ...issueTokens(user) };
}

// Phone/SMS OTP is stubbed until an SMS gateway with confirmed Somali carrier
// reachability is chosen (spec Section 6). Structure is in place; no real
// codes are sent or checked yet.
export async function verifyOtp() {
  throw new ApiError(501, 'NOT_IMPLEMENTED', 'Phone OTP verification is not yet available. SMS gateway integration is pending.');
}

export { toPublicUser, issueTokens };
