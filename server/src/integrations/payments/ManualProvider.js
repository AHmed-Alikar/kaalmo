// Admin-recorded offline donation — the MVP fallback provider when no real
// payment gateway is wired up yet. An admin manually confirms that money was
// received (e.g. via hawala or in person) and records it here.

import Payment from '../../models/Payment.js';
import PaymentTransaction from '../../models/PaymentTransaction.js';

export const manualProvider = {
  async createPaymentIntent({ campaignId, donorId, amount, currency }) {
    const payment = await Payment.create({
      campaignId,
      donorId,
      amount,
      currency,
      provider: 'manual',
      status: 'pending',
    });
    return { paymentId: payment._id, status: payment.status };
  },

  async confirmPayment({ paymentId, providerTransactionId, adminId }) {
    const payment = await Payment.findById(paymentId);
    if (!payment) throw new Error('Payment not found');

    const transaction = await PaymentTransaction.create({
      paymentId: payment._id,
      provider: 'manual',
      providerTransactionId: providerTransactionId || `manual-${payment._id}-${Date.now()}`,
      amount: payment.amount,
      currency: payment.currency,
      status: 'confirmed',
      rawPayload: { confirmedBy: adminId },
    });

    payment.status = 'confirmed';
    await payment.save();

    return { payment, transaction };
  },

  // Unified entry point used by donationController — creates the intent and
  // immediately auto-confirms it (no real money movement to wait on).
  async charge(params) {
    const intent = await this.createPaymentIntent(params);
    const { transaction } = await this.confirmPayment({ paymentId: intent.paymentId });
    return { paymentId: intent.paymentId, status: 'confirmed', transaction };
  },

  async handleWebhook() {
    // Manual provider has no webhooks — confirmation happens via admin action.
    return { handled: false };
  },

  async refund({ paymentId }) {
    const payment = await Payment.findById(paymentId);
    if (!payment) throw new Error('Payment not found');
    payment.status = 'refunded';
    await payment.save();
    return { payment };
  },
};
