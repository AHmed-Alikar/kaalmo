import Campaign from '../models/Campaign.js';
import Donation from '../models/Donation.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { PaymentService } from '../integrations/payments/PaymentService.js';
import { PUBLIC_STATUSES, recomputeRaisedAmount } from '../services/campaignService.js';
import { logAudit } from '../services/auditLogService.js';
import { notifyUser } from '../services/notificationService.js';

const SUPPORTED_PROVIDERS = ['manual', 'evc_plus'];

// Donations never wait on admin approval — 'manual' auto-confirms and
// 'evc_plus' (EVC Plus via WaafiPay) charges the donor's mobile money account
// synchronously via a USSD push. Either way the donor knows the outcome
// (confirmed or declined) before this request returns (spec Section 14).
export const createDonation = asyncHandler(async (req, res) => {
  const campaign = await Campaign.findById(req.params.id);
  if (!campaign) throw new ApiError(404, 'NOT_FOUND', 'Campaign not found');

  if (!PUBLIC_STATUSES.includes(campaign.status)) {
    throw new ApiError(400, 'CAMPAIGN_NOT_OPEN', 'This campaign is not currently open for donations');
  }

  const { amount, isAnonymous, message, provider = 'manual', phone } = req.body;
  if (!amount || amount <= 0) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'Donation amount must be greater than zero', { amount: 'required' });
  }
  if (!SUPPORTED_PROVIDERS.includes(provider)) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'Unsupported payment method', { provider: 'invalid' });
  }
  if (provider === 'evc_plus' && !phone) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'Enter the phone number to charge for EVC Plus', { phone: 'required' });
  }

  const campaignTitle = campaign.title?.en || campaign.title?.so || 'a Kaalmo campaign';
  const { paymentId, transaction } = await PaymentService.charge(provider, {
    campaignId: campaign._id,
    donorId: req.user?.id,
    amount,
    currency: campaign.currency,
    phone,
    description: `Donation to ${campaignTitle}`,
  });

  const donation = await Donation.create({
    campaignId: campaign._id,
    donorId: req.user?.id,
    amount,
    currency: campaign.currency,
    isAnonymous: !!isAnonymous,
    message,
    paymentId,
    paymentTransactionId: transaction._id,
    status: 'confirmed',
  });

  const raisedAmount = await recomputeRaisedAmount(campaign._id);

  await logAudit({
    actorId: req.user?.id,
    action: 'payment.confirmed',
    targetType: 'Donation',
    targetId: donation._id,
    metadata: { amount: donation.amount, campaignId: campaign._id, provider },
  });

  if (donation.donorId) {
    await notifyUser({
      userId: donation.donorId,
      type: 'donation_confirmed',
      title: 'Donation confirmed',
      body: `Your donation of $${donation.amount} has been confirmed. Thank you for your support.`,
      targetUrl: `/campaigns/${campaign._id}`,
    });
  }

  res.status(201).json({
    donation,
    payment: { paymentId, status: 'confirmed' },
    raisedAmount,
    note: 'Donation confirmed.',
  });
});

export const listMyDonations = asyncHandler(async (req, res) => {
  const donations = await Donation.find({ donorId: req.user.id })
    .sort({ createdAt: -1 })
    .populate('campaignId', 'title coverImageUrl category');
  res.json(donations);
});
