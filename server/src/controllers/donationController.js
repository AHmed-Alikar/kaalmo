import Campaign from '../models/Campaign.js';
import Donation from '../models/Donation.js';
import Payment from '../models/Payment.js';
import { asyncHandler } from '../utils/asyncHandler.js';
import { ApiError } from '../utils/ApiError.js';
import { PaymentService } from '../integrations/payments/PaymentService.js';
import { PUBLIC_STATUSES, recomputeRaisedAmount } from '../services/campaignService.js';
import { logAudit } from '../services/auditLogService.js';
import { notifyUser } from '../services/notificationService.js';

// Shape returned both for a fresh donation and for an idempotent replay.
function donationResult(donation, raisedAmount) {
  return {
    donation,
    payment: { paymentId: donation.paymentId, status: 'confirmed' },
    raisedAmount,
    note: 'Donation confirmed.',
  };
}

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

  // amount / provider / message / isAnonymous are validated by createDonationSchema.
  const { amount, isAnonymous, message, provider, phone } = req.body;
  if (provider === 'evc_plus' && !phone) {
    throw new ApiError(400, 'VALIDATION_ERROR', 'Enter the phone number to charge for EVC Plus', { phone: 'required' });
  }

  // Idempotency — a retried request (same `Idempotency-Key`) must not charge
  // twice. Scope the key to the caller so one client can't observe another's.
  const rawKey = req.get('Idempotency-Key');
  const idempotencyKey = rawKey ? `${req.user?.id || 'guest'}:${rawKey.trim()}`.slice(0, 200) : null;
  if (idempotencyKey) {
    const existingPayment = await Payment.findOne({ idempotencyKey, campaignId: campaign._id });
    if (existingPayment) {
      const existingDonation = await Donation.findOne({ paymentId: existingPayment._id });
      if (existingDonation) {
        const raisedAmount = await recomputeRaisedAmount(campaign._id);
        return res.status(201).json(donationResult(existingDonation, raisedAmount));
      }
      // Payment recorded but no donation (previous attempt failed/declined) —
      // let it fall through and try again with a fresh payment.
    }
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

  if (idempotencyKey) {
    await Payment.updateOne({ _id: paymentId }, { idempotencyKey });
  }

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
    actorType: req.user?.id ? 'user' : 'system',
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

  res.status(201).json(donationResult(donation, raisedAmount));
});

export const listMyDonations = asyncHandler(async (req, res) => {
  const donations = await Donation.find({ donorId: req.user.id })
    .sort({ createdAt: -1 })
    .populate('campaignId', 'title coverImageUrl category');
  res.json(donations);
});
