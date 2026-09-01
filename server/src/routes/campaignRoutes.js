import { Router } from 'express';
import * as campaignController from '../controllers/campaignController.js';
import * as donationController from '../controllers/donationController.js';
import * as campaignMemberController from '../controllers/campaignMemberController.js';
import * as beneficiaryController from '../controllers/beneficiaryController.js';
import { requireAuth, optionalAuth } from '../middleware/auth.js';
import { requireRole } from '../middleware/rbac.js';
import { validate } from '../middleware/validate.js';
import { donationRateLimiter } from '../middleware/rateLimit.js';
import {
  createCampaignSchema,
  updateCampaignSchema,
  createUpdateSchema,
  createCommentSchema,
} from '../validators/campaignValidators.js';
import { inviteMemberSchema } from '../validators/campaignMemberValidators.js';
import { inviteBeneficiarySchema } from '../validators/beneficiaryValidators.js';
import { createDonationSchema } from '../validators/donationValidators.js';

const router = Router();

router.get('/', campaignController.listCampaigns);
router.get('/stats', campaignController.getPublicStats);
// Donations across the caller's own + accepted co-organized campaigns.
router.get('/mine/donations', requireAuth, campaignController.listMyCampaignDonations);
// No global role gate — a co-organizer (global role stays whatever it was)
// must be able to see campaigns they were invited to. The controller itself
// scopes the result to req.user.id (owned + accepted co-organizer rows only).
router.get('/mine', requireAuth, campaignController.listMyCampaigns);
router.post('/', requireAuth, requireRole('organizer', 'admin'), validate(createCampaignSchema), campaignController.createCampaign);
router.get('/:id', optionalAuth, campaignController.getCampaign);
router.patch('/:id', requireAuth, validate(updateCampaignSchema), campaignController.updateCampaign);
router.delete('/:id', requireAuth, campaignController.deleteCampaign);
router.post('/:id/cancel', requireAuth, campaignController.cancelCampaign);
router.post('/:id/submit', requireAuth, campaignController.submitCampaignForReview);

router.get('/:id/updates', campaignController.listUpdates);
router.post('/:id/updates', requireAuth, validate(createUpdateSchema), campaignController.postUpdate);

router.get('/:id/comments', campaignController.listComments);
router.post('/:id/comments', requireAuth, validate(createCommentSchema), campaignController.postComment);

router.post('/:id/donate', optionalAuth, donationRateLimiter, validate(createDonationSchema), donationController.createDonation);
router.get('/:id/donations', campaignController.listCampaignDonations);

router.get('/:id/interactions', requireAuth, campaignController.getMyCampaignInteractions);
router.post('/:id/follow', requireAuth, campaignController.followCampaign);
router.delete('/:id/follow', requireAuth, campaignController.unfollowCampaign);
router.post('/:id/save', requireAuth, campaignController.saveCampaign);
router.delete('/:id/save', requireAuth, campaignController.unsaveCampaign);

router.get('/:id/members', requireAuth, requireRole('organizer', 'admin'), campaignMemberController.listMembers);
router.post('/:id/members', requireAuth, requireRole('organizer', 'admin'), validate(inviteMemberSchema), campaignMemberController.inviteMember);
router.delete('/:id/members/:memberId', requireAuth, requireRole('organizer', 'admin'), campaignMemberController.removeMember);

// Beneficiary assignment for a campaign.
router.get('/:id/beneficiary', requireAuth, beneficiaryController.getCampaignBeneficiary);
router.post('/:id/beneficiary', requireAuth, requireRole('organizer', 'admin'), validate(inviteBeneficiarySchema), beneficiaryController.inviteCampaignBeneficiary);

export default router;
