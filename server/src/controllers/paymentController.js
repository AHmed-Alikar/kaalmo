import { asyncHandler } from '../utils/asyncHandler.js';
import { isWaafiPayConfigured } from '../integrations/payments/waafiPayClient.js';

// Public. Lets a client (web or mobile) render the payment-method picker from
// the server instead of hard-coding a provider. `manual` is always available
// (admin-recorded / offline); `evc_plus` only when the gateway is configured.
export const getPaymentConfig = asyncHandler(async (req, res) => {
  const providers = ['manual'];
  if (isWaafiPayConfigured()) providers.push('evc_plus');

  res.json({
    providers,
    currency: 'USD',
    minAmount: 0.01,
  });
});
