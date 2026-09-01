import Beneficiary from '../models/Beneficiary.js';
import Campaign from '../models/Campaign.js';
import User from '../models/User.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { notifyUser } from '../services/notificationService.js';
import { sendBeneficiaryInviteEmail } from '../services/emailService.js';
import { isCampaignContributor } from '../services/campaignService.js';

// Statuses from which a beneficiary is allowed to (re)submit their details.
// `invited` is deliberately excluded — the beneficiary must explicitly accept
// the invitation first (acceptBeneficiaryInvite moves it to `accepted`).
const SUBMITTABLE = ['accepted', 'pending', 'rejected', 'needs_more_information'];

// The caller's own beneficiary record (most recent). 404 when they have none.
export const getMyBeneficiaryProfile = asyncHandler(async (req, res) => {
  const beneficiary = await Beneficiary.findOne({ userId: req.user.id })
    .sort({ updatedAt: -1 })
    .populate('campaignId', 'title')
    .populate('invitedBy', 'fullName');
  if (!beneficiary) throw new ApiError(404, 'NOT_FOUND', 'No beneficiary profile found for this account');
  res.json(beneficiary);
});

// Self-service / resubmission. Attaches to an existing invited/accepted record
// for this user if there is one; otherwise creates a standalone record
// (legacy behaviour). Only ever produces a 'pending' record — an admin still
// verifies it.
export const submitMyBeneficiaryProfile = asyncHandler(async (req, res) => {
  const { fullName, idDocumentUrl } = req.body;

  let beneficiary = await Beneficiary.findOne({ userId: req.user.id }).sort({ updatedAt: -1 });
  if (beneficiary && beneficiary.verificationStatus === 'verified') {
    throw new ApiError(409, 'ALREADY_VERIFIED', 'This beneficiary profile is already verified');
  }
  if (beneficiary && beneficiary.verificationStatus === 'invited') {
    throw new ApiError(409, 'NOT_ACCEPTED', 'Accept the campaign invitation before submitting your verification details');
  }
  if (beneficiary && !SUBMITTABLE.includes(beneficiary.verificationStatus)) {
    throw new ApiError(409, 'NOT_SUBMITTABLE', 'This beneficiary profile cannot be edited right now');
  }

  if (beneficiary) {
    beneficiary.fullName = fullName;
    beneficiary.idDocumentUrl = idDocumentUrl;
    beneficiary.verificationStatus = 'pending';
    beneficiary.reviewNote = undefined;
    await beneficiary.save();
  } else {
    beneficiary = await Beneficiary.create({
      userId: req.user.id,
      fullName,
      idDocumentUrl,
      verificationStatus: 'pending',
    });
  }

  // Let the organizer who invited them know it's now awaiting review.
  if (beneficiary.invitedBy) {
    await notifyUser({
      userId: beneficiary.invitedBy,
      type: 'beneficiary_submitted',
      title: 'Beneficiary submitted verification',
      body: `${fullName} submitted their verification and it is now awaiting review.`,
      targetUrl: beneficiary.campaignId ? `/campaigns/${beneficiary.campaignId}` : '/organizer',
    });
  }

  res.status(201).json(beneficiary);
});

// --- invitations ---------------------------------------------------------

// Pending beneficiary invitations addressed to the caller's email.
export const listMyBeneficiaryInvites = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id).select('email');
  const invites = await Beneficiary.find({ inviteEmail: user.email, verificationStatus: 'invited' })
    .sort({ createdAt: -1 })
    .populate('campaignId', 'title')
    .populate('invitedBy', 'fullName');
  res.json(invites);
});

// Accepting only records consent — it never verifies the beneficiary.
export const acceptBeneficiaryInvite = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id).select('email');
  const invite = await Beneficiary.findOne({ _id: req.params.id, inviteEmail: user.email });
  if (!invite) throw new ApiError(404, 'NOT_FOUND', 'Invitation not found');
  if (invite.verificationStatus !== 'invited') {
    return res.json(invite); // already handled
  }

  invite.userId = req.user.id;
  invite.verificationStatus = 'accepted';
  await invite.save();

  if (invite.invitedBy) {
    await notifyUser({
      userId: invite.invitedBy,
      type: 'beneficiary_accepted',
      title: 'Beneficiary accepted the invitation',
      body: 'Your invited beneficiary accepted and can now submit their verification.',
      targetUrl: invite.campaignId ? `/campaigns/${invite.campaignId}` : '/organizer',
    });
  }

  res.json(invite);
});

// --- organizer: assign a beneficiary to a campaign ---------------------

export const inviteCampaignBeneficiary = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  // Owner-only — assigning the beneficiary is an ownership action.
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the campaign owner can assign the beneficiary');
  }

  const inviteEmail = email.toLowerCase().trim();

  // Replace any existing non-verified beneficiary link for this campaign.
  const existing = await Beneficiary.findOne({ campaignId: campaign._id });
  if (existing && existing.verificationStatus === 'verified') {
    throw new ApiError(409, 'ALREADY_VERIFIED', 'This campaign already has a verified beneficiary');
  }
  if (existing) await Beneficiary.deleteOne({ _id: existing._id });

  const [invitee, inviter] = await Promise.all([
    User.findOne({ email: inviteEmail }),
    User.findById(req.user.id).select('fullName'),
  ]);
  const beneficiary = await Beneficiary.create({
    campaignId: campaign._id,
    invitedBy: req.user.id,
    inviteEmail,
    userId: invitee?._id,
    verificationStatus: 'invited',
  });

  campaign.beneficiaryId = beneficiary._id;
  await campaign.save();

  // Always email the address the organizer entered — this is how a recipient
  // without an account gets in. Existing users also get an in-app notification.
  await sendBeneficiaryInviteEmail({
    inviteEmail,
    inviterName: inviter?.fullName || 'An organizer',
    campaignTitle: campaign.title?.en || campaign.title?.so,
    hasAccount: !!invitee,
  });

  if (invitee) {
    await notifyUser({
      userId: invitee._id,
      type: 'beneficiary_invited',
      title: 'You were added as a campaign beneficiary',
      body: `You've been named the beneficiary for "${campaign.title?.en || campaign.title?.so}". Accept and complete verification to receive funds.`,
      targetUrl: '/verification',
    });
  }

  res.status(201).json(beneficiary);
});

// The beneficiary attached to a campaign — visible to the campaign's
// organizer / accepted co-organizers so they can see the verification state.
export const getCampaignBeneficiary = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (!(await isCampaignContributor(campaign, req.user.id))) {
    throw new ApiError(403, 'FORBIDDEN', 'Not allowed to view this campaign');
  }
  const beneficiary = await Beneficiary.findOne({ campaignId: campaign._id })
    .populate('userId', 'fullName email');
  if (!beneficiary) throw new ApiError(404, 'NOT_FOUND', 'No beneficiary assigned to this campaign');
  res.json(beneficiary);
});
