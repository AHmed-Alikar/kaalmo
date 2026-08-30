import Campaign from '../models/Campaign.js';
import CampaignMember from '../models/CampaignMember.js';
import User from '../models/User.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { sendTeamInviteEmail } from '../services/emailService.js';
import { notifyUser } from '../services/notificationService.js';

// Only the organizer can invite/remove team members — co-organizers can
// assist with content but not manage the team or finances (spec Section 33).
export const inviteMember = asyncHandler(async (req, res) => {
  const { email } = req.body;
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the organizer can invite team members');
  }

  const inviter = await User.findById(req.user.id);
  const inviteEmail = email.toLowerCase().trim();
  if (inviteEmail === inviter.email) {
    throw new ApiError(400, 'VALIDATION_ERROR', "You can't invite yourself", { email: 'invalid' });
  }

  const existing = await CampaignMember.findOne({ campaignId: campaign._id, inviteEmail });
  if (existing) {
    throw new ApiError(409, 'ALREADY_INVITED', 'This person has already been invited to this campaign');
  }

  const invitee = await User.findOne({ email: inviteEmail });
  const member = await CampaignMember.create({
    campaignId: campaign._id,
    userId: invitee?._id,
    inviteEmail,
    invitedBy: req.user.id,
    status: 'pending',
  });

  await sendTeamInviteEmail({
    inviteEmail,
    inviterName: inviter.fullName,
    campaignTitle: campaign.title?.en || campaign.title?.so,
    hasAccount: !!invitee,
  });

  if (invitee) {
    await notifyUser({
      userId: invitee._id,
      type: 'team_invite',
      title: 'Campaign invitation',
      body: `${inviter.fullName} invited you to help manage "${campaign.title?.en || campaign.title?.so}".`,
      targetUrl: '/organizer/invites',
    });
  }

  res.status(201).json(member);
});

export const listMembers = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the organizer can view the team list');
  }

  const members = await CampaignMember.find({ campaignId: campaign._id }).sort({ createdAt: -1 });
  res.json(members);
});

export const removeMember = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');
  if (String(campaign.organizerId) !== String(req.user.id)) {
    throw new ApiError(403, 'FORBIDDEN', 'Only the organizer can remove team members');
  }

  await CampaignMember.deleteOne({ _id: req.params.memberId, campaignId: campaign._id });
  res.json({ removed: true });
});

export const listMyInvites = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  const invites = await CampaignMember.find({ inviteEmail: user.email, status: 'pending' })
    .sort({ createdAt: -1 })
    .populate('campaignId', 'title')
    .populate('invitedBy', 'fullName');
  res.json(invites);
});

// Accepting a co-organizer invite grants access to this one campaign only —
// it must NEVER change the user's global account role. A co-organizer is a
// campaign-scoped collaborator (CampaignMember.status === 'accepted'), not a
// global "organizer". Authorization elsewhere (canEditCampaign,
// isCampaignContributor) already checks this membership directly and never
// looks at user.roles for co-organizer access, so no role/token change is
// needed here for permissions to take effect.
export const acceptInvite = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  const member = await CampaignMember.findOne({ _id: req.params.memberId, inviteEmail: user.email });
  if (!member) throw new ApiError(404, 'NOT_FOUND', 'Invitation not found');
  if (member.status === 'accepted') {
    return res.json({ member });
  }

  member.status = 'accepted';
  member.userId = req.user.id;
  member.acceptedAt = new Date();
  await member.save();

  res.json({ member });
});
