import Campaign from '../models/Campaign.js';
import Update from '../models/Update.js';
import Comment from '../models/Comment.js';
import Donation from '../models/Donation.js';
import Follow from '../models/Follow.js';
import Bookmark from '../models/Bookmark.js';
import CampaignMember from '../models/CampaignMember.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { submitCampaign, canEditCampaign, isCampaignContributor, assertTransitionAllowed, PUBLIC_STATUSES, EDIT_RETURNS_TO_REVIEW_STATUSES } from '../services/campaignService.js';
import { notifyUser } from '../services/notificationService.js';
import { logAudit } from '../services/auditLogService.js';

// Real, derivable platform numbers only — never fabricate stats for the
// landing page (Design_Rules.md Rule 43).
export const getPublicStats = asyncHandler(async (req, res) => {
  const [totals, donorCount] = await Promise.all([
    Campaign.aggregate([
      { $match: { status: { $in: PUBLIC_STATUSES } } },
      { $group: { _id: null, totalRaised: { $sum: '$raisedAmount' }, campaignCount: { $sum: 1 } } },
    ]),
    Donation.distinct('donorId', { status: 'confirmed', donorId: { $ne: null } }),
  ]);

  res.json({
    totalRaised: totals[0]?.totalRaised || 0,
    campaignCount: totals[0]?.campaignCount || 0,
    donorCount: donorCount.length,
  });
});

export const listCampaigns = asyncHandler(async (req, res) => {
  const { category, region, q, page = 1, limit = 20 } = req.query;
  const filter = { status: { $in: PUBLIC_STATUSES } };
  if (category) filter.category = category;
  if (region) filter.region = region;
  if (q) filter.$text = { $search: q };

  const skip = (Number(page) - 1) * Number(limit);
  const [items, total] = await Promise.all([
    Campaign.find(filter).sort({ createdAt: -1 }).skip(skip).limit(Number(limit)),
    Campaign.countDocuments(filter),
  ]);

  res.json({ items, total, page: Number(page), limit: Number(limit) });
});

// "My campaigns" means campaigns this user owns, PLUS campaigns where they
// hold an accepted CampaignMember (co-organizer) row — never campaigns they
// merely have some global role in common with. Each item is tagged with
// `access` so the UI can show "Owner" vs "Co-organizer" (never blur the two).
export const listMyCampaigns = asyncHandler(async (req, res) => {
  const memberships = await CampaignMember.find({ userId: req.user.id, status: 'accepted' }).select('campaignId');
  const coOrganizedIds = memberships.map((m) => m.campaignId);

  const [owned, coOrganized] = await Promise.all([
    Campaign.find({ organizerId: req.user.id }).sort({ createdAt: -1 }),
    coOrganizedIds.length ? Campaign.find({ _id: { $in: coOrganizedIds } }).sort({ createdAt: -1 }) : [],
  ]);

  const campaigns = [
    ...owned.map((c) => ({ ...c.toObject(), access: 'owner' })),
    ...coOrganized.map((c) => ({ ...c.toObject(), access: 'co-organizer' })),
  ];

  res.json(campaigns);
});

export const createCampaign = asyncHandler(async (req, res) => {
  const campaign = await Campaign.create({ ...req.body, organizerId: req.user.id, status: 'draft' });
  res.status(201).json(campaign);
});

export const getCampaign = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found or unavailable');

  const isPublic = PUBLIC_STATUSES.includes(campaign.status);
  // Non-public campaigns (draft/under_review/rejected/etc.) are visible to
  // the owner and to accepted co-organizers — a campaign-scoped check, never
  // a global role check (an unrelated co-organizer on a different campaign,
  // or any other "organizer" user, must still get 404 here).
  const isContributor = req.user && (await isCampaignContributor(campaign, req.user.id));
  if (!isPublic && !isContributor) {
    throw new ApiError(404, 'NOT_FOUND', 'Campaign not found or unavailable');
  }

  res.json(campaign);
});

export const updateCampaign = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (!(await canEditCampaign(campaign, req.user.id))) {
    throw new ApiError(403, 'FORBIDDEN', 'Campaign cannot be edited in its current status');
  }

  // Editing a campaign that's already been reviewed changes the reviewed
  // content, so it goes back through moderation rather than silently keeping
  // its approved/published/active status (Design_Rules.md Rule 18 — trust).
  const returnsToReview = EDIT_RETURNS_TO_REVIEW_STATUSES.includes(campaign.status);

  Object.assign(campaign, req.body);
  if (returnsToReview) campaign.status = 'under_review';
  await campaign.save();

  if (returnsToReview) {
    await logAudit({
      actorId: req.user.id,
      actorType: 'organizer',
      action: 'campaign.edited_returned_to_review',
      targetType: 'Campaign',
      targetId: campaign._id,
    });
    await notifyUser({
      userId: campaign.organizerId,
      type: 'campaign_status_change',
      title: 'Campaign returned to review',
      body: `"${campaign.title?.en || campaign.title?.so}" was updated and is now awaiting re-review before donors can see the changes.`,
      targetUrl: '/organizer',
    });
  }

  res.json(campaign);
});

// Deleting is only offered for 'draft' campaigns (never public, never
// donated to) — owner-only, matching Design_Rules.md Rule 10 (ownership
// actions stay owner-only, never available to a co-organizer).
export const deleteCampaign = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the campaign owner can delete this campaign');
  }
  if (campaign.status !== 'draft') {
    throw new ApiError(400, 'INVALID_TRANSITION', 'Only draft campaigns can be deleted — cancel a submitted campaign instead.');
  }

  await Campaign.deleteOne({ _id: campaign._id });
  await logAudit({
    actorId: req.user.id,
    actorType: 'organizer',
    action: 'campaign.deleted',
    targetType: 'Campaign',
    targetId: campaign._id,
  });

  res.json({ deleted: true });
});

// Cancelling is the destructive action for a campaign that's already been
// submitted but not yet live — the TRANSITIONS map in campaignService only
// allows 'cancelled' from 'draft'/'submitted', so a published/active
// campaign can't be self-cancelled here (matches real fundraising platforms:
// once money is flowing, stopping it goes through a moderator, not a
// one-click organizer action). Owner-only, same as delete.
export const cancelCampaign = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the campaign owner can cancel this campaign');
  }

  assertTransitionAllowed(campaign.status, 'cancelled');
  campaign.status = 'cancelled';
  await campaign.save();

  await logAudit({
    actorId: req.user.id,
    actorType: 'organizer',
    action: 'campaign.cancelled',
    targetType: 'Campaign',
    targetId: campaign._id,
  });

  res.json(campaign);
});

export const submitCampaignForReview = asyncHandler(async (req, res) => {
  const campaign = await submitCampaign(req.params.id, req.user.id);
  res.json(campaign);
});

export const listUpdates = asyncHandler(async (req, res) => {
  const updates = await Update.find({ campaignId: req.params.id }).sort({ createdAt: -1 });
  res.json(updates);
});

export const postUpdate = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (!(await isCampaignContributor(campaign, req.user.id))) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the organizer or co-organizer can post updates');
  }

  const update = await Update.create({ ...req.body, campaignId: campaign._id, authorId: req.user.id });

  const followers = await Follow.find({ campaignId: campaign._id }).select('userId');
  await Promise.all(
    followers.map((f) =>
      notifyUser({
        userId: f.userId,
        type: 'campaign_update',
        title: 'New update',
        body: `${campaign.title?.en || campaign.title?.so} posted a new update.`,
        targetUrl: `/campaigns/${campaign._id}`,
      })
    )
  );

  res.status(201).json(update);
});

// Toggle — POST to follow, DELETE to unfollow. Following is what powers the
// donor's "Followed campaigns" page and campaign-update notifications.
export const followCampaign = asyncHandler(async (req, res) => {
  await Follow.findOneAndUpdate(
    { userId: req.user.id, campaignId: req.params.id },
    { userId: req.user.id, campaignId: req.params.id },
    { upsert: true }
  );
  res.json({ following: true });
});

export const unfollowCampaign = asyncHandler(async (req, res) => {
  await Follow.deleteOne({ userId: req.user.id, campaignId: req.params.id });
  res.json({ following: false });
});

export const saveCampaign = asyncHandler(async (req, res) => {
  await Bookmark.findOneAndUpdate(
    { userId: req.user.id, campaignId: req.params.id },
    { userId: req.user.id, campaignId: req.params.id },
    { upsert: true }
  );
  res.json({ saved: true });
});

export const unsaveCampaign = asyncHandler(async (req, res) => {
  await Bookmark.deleteOne({ userId: req.user.id, campaignId: req.params.id });
  res.json({ saved: false });
});

// Tells the campaign detail page whether the current viewer already
// follows/has saved this campaign, so buttons render in the right state.
export const getMyCampaignInteractions = asyncHandler(async (req, res) => {
  const [following, saved] = await Promise.all([
    Follow.exists({ userId: req.user.id, campaignId: req.params.id }),
    Bookmark.exists({ userId: req.user.id, campaignId: req.params.id }),
  ]);
  res.json({ following: !!following, saved: !!saved });
});

// Public: last confirmed donations + a supporter count, so a visiting donor
// can see the campaign is real and active (Design_Rules.md Rule 19 — "how
// much has been raised" and social proof). Anonymous donors' names are
// never exposed, matching the promise made at donation time.
export const listCampaignDonations = asyncHandler(async (req, res) => {
  const { limit = 10 } = req.query;
  const campaignId = req.params.id;

  const [donations, supporterCount] = await Promise.all([
    Donation.find({ campaignId, status: 'confirmed' })
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .populate('donorId', 'fullName'),
    Donation.countDocuments({ campaignId, status: 'confirmed' }),
  ]);

  const items = donations.map((d) => ({
    _id: d._id,
    amount: d.amount,
    currency: d.currency,
    message: d.message,
    createdAt: d.createdAt,
    donorName: d.isAnonymous ? null : d.donorId?.fullName || null,
  }));

  res.json({ items, supporterCount });
});

export const listComments = asyncHandler(async (req, res) => {
  const comments = await Comment.find({ campaignId: req.params.id }).sort({ createdAt: -1 });
  res.json(comments);
});

export const postComment = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');

  const comment = await Comment.create({ ...req.body, campaignId: campaign._id, userId: req.user.id });
  res.status(201).json(comment);
});
