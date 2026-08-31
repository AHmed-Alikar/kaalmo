// EVC Plus (Hormuud) mobile money via the WaafiPay gateway (spec Section 14).
// USSD push flow: WaafiPay's API_PURCHASE call sends a payment prompt to the
// donor's phone and the request itself blocks until the donor enters their
// PIN (or the request times out) — the response tells us success/failure
// synchronously, so there is no separate "confirm" step or webhook to wait on.

import Payment from '../../models/Payment.js';
import PaymentTransaction from '../../models/PaymentTransaction.js';
import { ApiError } from '../../utils/ApiError.js';
import { callWaafiPay } from './waafiPayClient.js';

// Somali mobile numbers are accepted in any common local shape
// (0616123456, 616123456, +252616123456) and normalized to 252XXXXXXXXX,
// the format WaafiPay's accountNo expects.
export function normalizeSomaliPhone(raw) {
  const digits = String(raw || '').replace(/[^\d]/g, '');
  if (digits.startsWith('252') && digits.length === 12) return digits;
  if (digits.startsWith('0') && digits.length === 10) return `252${digits.slice(1)}`;
  if (digits.length === 9) return `252${digits}`;
  return null;
}

export const waafiPayProvider = {
  // Kept for interface parity with other providers — WaafiPay's model is a
  // single synchronous purchase call, so the real work happens in charge().
  async createPaymentIntent({ campaignId, donorId, amount, currency }) {
    const payment = await Payment.create({
      campaignId,
      donorId,
      amount,
      currency,
      provider: 'mobile_money',
      status: 'pending',
    });
    return { paymentId: payment._id, status: payment.status };
  },

  async charge({ campaignId, donorId, amount, currency, phone, description }) {
    const accountNo = normalizeSomaliPhone(phone);
    if (!accountNo) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Enter a valid Somali mobile money number', { phone: 'invalid' });
    }

    const payment = await Payment.create({
      campaignId,
      donorId,
      amount,
      currency,
      provider: 'mobile_money',
      status: 'pending',
    });

    const data = await callWaafiPay('API_PURCHASE', {
      paymentMethod: 'mwallet_account',
      payerInfo: { accountNo },
      transactionInfo: {
        referenceId: String(payment._id),
        invoiceId: String(payment._id),
        amount: Number(amount).toFixed(2),
        currency,
        description: description || 'Kaalmo donation',
      },
    });

    const approved = data.responseCode === '2001' && data.params?.state === 'APPROVED';

    const transaction = await PaymentTransaction.create({
      paymentId: payment._id,
      provider: 'mobile_money',
      providerTransactionId: data.params?.transactionId || `waafipay-${payment._id}-${Date.now()}`,
      amount,
      currency,
      status: approved ? 'confirmed' : 'failed',
      rawPayload: data,
    });

    payment.status = approved ? 'confirmed' : 'failed';
    await payment.save();

    if (!approved) {
      // WaafiPay's decline reason shows up in different shapes depending on the
      // failure: a short code in responseMsg (e.g. RCS_USER_REJECTED), or a
      // stable errorCode with a long localized sentence in responseMsg (e.g.
      // E10205 for insufficient balance, seen verbatim as "Payment Failed
      // (Haraaga xisaabtaadu kuguma filna...)"). Check both — never surface
      // either raw to the donor (Design_Rules.md Rule 17/29).
      const friendly =
        FAILURE_MESSAGES[data.responseMsg] ||
        FAILURE_MESSAGES[data.errorCode] ||
        'The payment was declined. Please try again or use a different method.';
      throw new ApiError(402, 'PAYMENT_DECLINED', friendly, { providerMessage: data.responseMsg, providerErrorCode: data.errorCode });
    }

    return { paymentId: payment._id, status: 'confirmed', transaction };
  },

  async confirmPayment() {
    // No-op: WaafiPay purchases are confirmed synchronously in charge().
    throw new ApiError(400, 'NOT_SUPPORTED', 'EVC Plus payments are confirmed automatically and cannot be confirmed manually');
  },

  async handleWebhook() {
    // Not used — WaafiPay's API_PURCHASE response is authoritative and synchronous.
    return { handled: false };
  },

  async refund({ paymentId }) {
    const payment = await Payment.findById(paymentId);
    if (!payment) throw new ApiError(404, 'NOT_FOUND', 'Payment not found');
    // Real reversal requires WaafiPay's refund service call — not yet wired up.
    payment.status = 'refunded';
    await payment.save();
    return { payment };
  },
};

const FAILURE_MESSAGES = {
  // Keyed by responseMsg (short-code failures)
  RCS_INSUFFICIENT_BALANCE: 'Insufficient EVC Plus balance for this donation.',
  RCS_USER_REJECTED: 'The payment was cancelled on your phone.',
  RCS_TIMEOUT: 'You did not respond to the payment prompt in time. Please try again.',
  // Keyed by errorCode (failures where responseMsg is a long localized
  // sentence instead of a short code) — E10205 observed verbatim as
  // "Payment Failed (Haraaga xisaabtaadu kuguma filna, haraagaagu waa: )".
  E10205: 'Insufficient EVC Plus balance for this donation.',
};
