// Raw HTTP transport for the WaafiPay gateway, isolated from the provider
// adapter so the provider's success/decline/timeout handling can be unit
// tested without a live gateway. No behaviour change from the previous inline
// implementation.
//
// Node's built-in fetch() (undici) hangs indefinitely against WaafiPay's
// endpoint in this environment despite curl/https.request working fine —
// using the plain https module here sidesteps that.

import https from 'node:https';
import { ApiError } from '../../utils/ApiError.js';

const REQUEST_TIMEOUT_MS = 30_000;

export function isWaafiPayConfigured() {
  return Boolean(process.env.WAAFIPAY_BASE_URL && process.env.WAAFIPAY_API_KEY);
}

export function callWaafiPay(serviceName, serviceParams) {
  const baseUrl = process.env.WAAFIPAY_BASE_URL;
  if (!isWaafiPayConfigured()) {
    return Promise.reject(new ApiError(501, 'PROVIDER_NOT_IMPLEMENTED', 'EVC Plus is not configured yet'));
  }

  const body = JSON.stringify({
    schemaVersion: '1.0',
    requestId: String(Date.now()) + Math.floor(Math.random() * 1000),
    timestamp: new Date().toISOString(),
    channelName: 'WEB',
    serviceName,
    serviceParams: {
      merchantUid: process.env.WAAFIPAY_MERCHANT_UID,
      apiUserId: process.env.WAAFIPAY_API_USER_ID,
      apiKey: process.env.WAAFIPAY_API_KEY,
      ...serviceParams,
    },
  });

  return new Promise((resolve, reject) => {
    const req = https.request(
      baseUrl,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(body) },
      },
      (res) => {
        let raw = '';
        res.on('data', (chunk) => {
          raw += chunk;
        });
        res.on('end', () => {
          try {
            resolve(JSON.parse(raw));
          } catch {
            reject(new ApiError(502, 'PAYMENT_GATEWAY_ERROR', 'EVC Plus returned an unexpected response. Please try again.'));
          }
        });
      }
    );

    req.on('error', () => {
      reject(new ApiError(502, 'PAYMENT_GATEWAY_ERROR', 'Could not reach EVC Plus right now. Please try again.'));
    });
    req.setTimeout(REQUEST_TIMEOUT_MS, () => {
      req.destroy();
      reject(new ApiError(504, 'PAYMENT_TIMEOUT', 'EVC Plus did not respond in time. Please try again.'));
    });

    req.write(body);
    req.end();
  });
}
