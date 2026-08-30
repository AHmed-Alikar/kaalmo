import mongoose from 'mongoose';
import Campaign from '../models/Campaign.js';
import Donation from '../models/Donation.js';
import CampaignMember from '../models/CampaignMember.js';
import { ApiError } from '../utils/ApiError.js';

// Statuses visible to the public and open to donations. Shared by
// campaignController (listing/detail) and donationController (donate
// eligibility) so both stay in sync.
export const PUBLIC_STATUSES = ['published', 'active', 'goal_reached', 'withdrawal', 'completed'];

// Allowed forward transitions per spec Section 9. Side states (rejected,
// suspended, frozen, cancelled, expired) are handled by admin/moderator
// actions elsewhere and are not part of this happy-path map.
const TRANSITIONS = {
  draft: ['submitted', 'cancelled'],
  submitted: ['under_review', 'cancelled'],
  under_review: ['approved', 'rejected'],
  approved: ['published'],
  published: ['active'],
  active: ['goal_reached', 'suspended', 'frozen', 'expired'],
  goal_reached: ['withdrawal', 'completed'],
  withdrawal: ['completed'],
};

export function assertTransitionAllowed(currentStatus, nextStatus) {
  const allowed = TRANSITIONS[currentStatus] || [];
  if (!allowed.includes(nextStatus)) {
    throw new ApiError(
      400,
      'INVALID_TRANSITION',
      `Cannot move campaign from "${currentStatus}" to "${nextStatus}"`
    );
  }
}

export async function submitCampaign(campaignId, userId) {
  const campaign = await Campaign.findById(campaignId);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(userId)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the organizer can submit this campaign');
  }

  assertTransitionAllowed(campaign.status, 'submitted');
  campaign.status = 'submitted';
  await campaign.save();
  return campaign;
}

// Statuses where the campaign is paused/closed by a moderator or by
// completion — editing is blocked outright regardless of who's asking.
const NOT_EDITABLE_STATUSES = ['suspended', 'frozen', 'cancelled', 'expired', 'completed'];

// Editing a campaign that's already been reviewed (submitted and beyond)
// sends it back through moderation, since the reviewed content just changed —
// see EDIT_RETURNS_TO_REVIEW below and updateCampaign in campaignController.
export const EDIT_RETURNS_TO_REVIEW_STATUSES = [
  'submitted',
  'under_review',
  'approved',
  'published',
  'active',
  'goal_reached',
  'withdrawal',
];

// Co-organizers can edit campaign content but only the organizer can submit,
// request withdrawals, or manage the team (spec Section 33). The organizer
// (and accepted co-organizers) can edit at any non-paused/closed status —
// editing a live campaign just sends it back to under_review rather than
// being blocked outright.
export async function canEditCampaign(campaign, userId) {
  if (NOT_EDITABLE_STATUSES.includes(campaign.status)) return false;
  if (String(campaign.organizerId) === String(userId)) return true;

  const isAcceptedCoOrganizer = await CampaignMember.exists({
    campaignId: campaign._id,
    userId,
    status: 'accepted',
  });
  return !!isAcceptedCoOrganizer;
}

export async function isCampaignContributor(campaign, userId) {
  if (String(campaign.organizerId) === String(userId)) return true;
  const isAcceptedCoOrganizer = await CampaignMember.exists({
    campaignId: campaign._id,
    userId,
    status: 'accepted',
  });
  return !!isAcceptedCoOrganizer;
}

// The campaign's raisedAmount is a derived, recomputable field — the source
// of truth is the sum of confirmed donations/PaymentTransactions (spec
// Section 17). Call this after any donation status changes to 'confirmed'.
export async function recomputeRaisedAmount(campaignId) {
  const [result] = await Donation.aggregate([
    { $match: { campaignId: new mongoose.Types.ObjectId(campaignId), status: 'confirmed' } },
    { $group: { _id: null, total: { $sum: '$amount' } } },
  ]);

  const raisedAmount = result?.total || 0;
  await Campaign.findByIdAndUpdate(campaignId, { raisedAmount });
  return raisedAmount;
}

// Admin/moderator-driven transitions (spec Section 24 — mandatory reason
// codes on reject/suspend). Separate from the organizer-driven happy path in
// TRANSITIONS above since these can move a campaign into side states.
const ADMIN_ACTIONS = {
  approve: { from: ['submitted', 'under_review'], to: 'approved' },
  start_review: { from: ['submitted'], to: 'under_review' },
  reject: { from: ['submitted', 'under_review'], to: 'rejected', reasonRequired: true },
  publish: { from: ['approved'], to: 'published' },
  suspend: { from: ['published', 'active', 'goal_reached'], to: 'suspended', reasonRequired: true },
  restore: { from: ['suspended', 'frozen'], to: 'active' },
};

export async function adminReviewCampaign(campaignId, action, reason) {
  const def = ADMIN_ACTIONS[action];
  if (!def) {
    throw new ApiError(400, 'INVALID_ACTION', `Unknown admin action "${action}"`);
  }

  const campaign = await Campaign.findById(campaignId);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');

  if (!def.from.includes(campaign.status)) {
    throw new ApiError(400, 'INVALID_TRANSITION', `Cannot ${action} a campaign in status "${campaign.status}"`);
  }

  if (def.reasonRequired && !reason) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'A reason is required for this action', { reason: 'required' });
  }

  campaign.status = def.to;
  await campaign.save();
  return campaign;
}
