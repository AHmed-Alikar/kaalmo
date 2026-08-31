import User from '../models/User.js';
import Follow from '../models/Follow.js';
import Bookmark from '../models/Bookmark.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import {
  toPublicUser,
  requestOrganizerAccess,
  confirmOrganizerAccess,
} from '../services/authService.js';

export const getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');
  res.json(toPublicUser(user));
});

export const updateMe = asyncHandler(async (req, res) => {
  const allowedFields = ['fullName', 'language', 'pushEnabled'];
  const updates = {};
  for (const field of allowedFields) {
    if (req.body[field] !== undefined) updates[field] = req.body[field];
  }
  if (updates.pushEnabled !== undefined) updates.pushEnabled = !!updates.pushEnabled;

  const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true, runValidators: true });
  if (!user) throw new ApiError(404, 'NOT_FOUND', 'User not found');
  res.json(toPublicUser(user));
});

// Becoming an organizer is a two-step, email-confirmed process — this step
// only sends the confirmation email; it never grants the role by itself.
export const requestOrganizerAccessController = asyncHandler(async (req, res) => {
  const { fullName, purpose } = req.body;
  const result = await requestOrganizerAccess(req.user.id, { fullName, purpose });
  res.json(result);
});

export const confirmOrganizerAccessController = asyncHandler(async (req, res) => {
  const result = await confirmOrganizerAccess(req.user.id, req.body.code);
  res.json(result);
});

export const listFollowedCampaigns = asyncHandler(async (req, res) => {
  const follows = await Follow.find({ userId: req.user.id }).sort({ createdAt: -1 }).populate('campaignId');
  res.json(follows.map((f) => f.campaignId).filter(Boolean));
});

export const listSavedCampaigns = asyncHandler(async (req, res) => {
  const bookmarks = await Bookmark.find({ userId: req.user.id }).sort({ createdAt: -1 }).populate('campaignId');
  res.json(bookmarks.map((b) => b.campaignId).filter(Boolean));
});
