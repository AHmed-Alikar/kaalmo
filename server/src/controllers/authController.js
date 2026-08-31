import { asyncHandler } from '../utils/asyncHandler.js';
import * as authService from '../services/authService.js';

export const register = asyncHandler(async (req, res) => {
  const result = await authService.register(req.body);
  res.status(201).json(result);
});

export const login = asyncHandler(async (req, res) => {
  const result = await authService.login(req.body);
  res.status(200).json(result);
});

export const refresh = asyncHandler(async (req, res) => {
  const result = await authService.refresh(req.body);
  res.status(200).json(result);
});

export const verifyEmailOtp = asyncHandler(async (req, res) => {
  const result = await authService.verifyEmailOtp(req.user.id, req.body.code);
  res.status(200).json(result);
});

export const verifyOtp = asyncHandler(async (req, res) => {
  const result = await authService.verifyOtp(req.body);
  res.status(200).json(result);
});

export const resendVerificationEmail = asyncHandler(async (req, res) => {
  const result = await authService.resendVerificationEmail(req.user.id);
  res.status(200).json(result);
});

export const forgotPassword = asyncHandler(async (req, res) => {
  const result = await authService.forgotPassword(req.body);
  res.status(200).json(result);
});

export const resetPassword = asyncHandler(async (req, res) => {
  const result = await authService.resetPassword(req.body);
  res.status(200).json(result);
});
