# Kaalmo — Server

Node.js/Express + MongoDB backend for the Kaalmo fundraising platform (see `kaalmo-web-only-spec.md` for the full product/technical spec).

## Setup

```bash
cd server
npm install
cp .env.example .env
```

Edit `.env` and set `MONGODB_URI` to a real MongoDB Atlas connection string. Also set real values for `JWT_ACCESS_SECRET` and `JWT_REFRESH_SECRET` (any long random string) before running anything beyond local dev.

### Sending real emails (optional)

By default, verification emails are only logged to the console (dev mode). To send real emails:

1. Create a free account at [resend.com](https://resend.com) and get an API key.
2. Set `RESEND_API_KEY` in `.env`.
3. Without a verified sending domain, Resend's test mode only delivers to the email address on your own Resend account — verify a domain in Resend to send to any address.

## Run

```bash
npm run dev
```

The server will fail to start until `MONGODB_URI` points to a reachable database.

## Test

```bash
npm test
```

Vitest + supertest against an in-memory MongoDB (`mongodb-memory-server` — first run downloads a MongoDB binary). No live DB or network required.

## What's implemented (this phase)

- Mongoose models: User, Campaign, Beneficiary, Donation, Payment, PaymentTransaction, Withdrawal, PayoutAccount, Update, Comment, Verification.
- Auth: register, login, refresh, email verification (dev-mode console email), password reset. Phone/SMS OTP endpoint is stubbed (`501 NOT_IMPLEMENTED`) until an SMS gateway is chosen.

### Password reset

- `POST /api/v1/auth/forgot-password` — body `{ email }`. Always responds `200 { "sent": true }` (never reveals whether the email is registered). If the account exists and is active, a 6-digit code is emailed (15-minute expiry). Limited to 5 requests/hour/IP and 3 requests/15-minutes per account.
- `POST /api/v1/auth/reset-password` — body `{ email, code, password }`. On success: `200 { "reset": true }`, the password is re-hashed with bcrypt, `emailVerified` is set, and all refresh tokens issued before the reset stop working (`passwordChangedAt`). No auth tokens are returned — the user logs in again. All failure modes (unknown email, wrong/expired code, ≥5 wrong attempts) return the same `400 INVALID_CODE`; a weak password returns `400 VALIDATION_ERROR`.
- The reset code is stored only as a bcrypt hash in the existing `Verification` collection (`type: 'password_reset'`); the plaintext code is never persisted or logged. Requesting a new code invalidates any previous pending one.
- Campaign CRUD + lifecycle transition guard (`draft → submitted → under_review → ...`), updates, comments.
- Standardized error shape: `{ "error": { "code", "message", "fields" } }`.
- Security basics: helmet, CORS allowlist, rate limiting on auth/donation routes, bcrypt password hashing, JWT access+refresh.

### Payments

- `PaymentService` abstraction → providers `manual` (auto-confirm / admin-recorded) and `evc_plus` (EVC Plus / Hormuud via the WaafiPay gateway — synchronous USSD-push, no webhook). Both resolve to a final status before `POST /campaigns/:id/donate` returns.
- Donation body is schema-validated; `Donation` ↔ `Payment` ↔ `PaymentTransaction` stay amount-consistent; `Campaign.raisedAmount` is recomputed from confirmed donations (never destructively overwritten). `PaymentTransaction` is append-only with a unique `providerTransactionId`.
- **Idempotency:** send an `Idempotency-Key` request header with a donation — a retry with the same key returns the original result instead of charging again.
- `GET /api/v1/payments/config` → `{ providers, currency, minAmount }` so clients don't hard-code a provider.
- Env (all optional; unset ⇒ `evc_plus` returns `501` and `manual` still works): `WAAFIPAY_BASE_URL`, `WAAFIPAY_MERCHANT_UID`, `WAAFIPAY_API_USER_ID`, `WAAFIPAY_API_KEY`. Credentials are only ever placed in the outbound gateway request body and are never logged.

### Push notifications (FCM)

- `POST /api/v1/devices` `{ token, platform? }`, `DELETE /api/v1/devices` `{ token }`, `GET /api/v1/devices` — all `requireAuth`, scoped to the caller. Multiple devices per user; a re-registered token is reassigned to the current user.
- `notifyUser(...)` (single chokepoint for all notification events) records the in-app `Notification` and additionally fires an FCM push (fire-and-forget). Dead tokens reported by FCM are pruned automatically.
- Per-user master switch `User.pushEnabled` (via `PATCH /users/me`). In-app notifications are stored regardless.
- Env (optional; unset ⇒ push is a silent no-op, in-app notifications unaffected): `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`. The service-account key is read from env only and never logged.

## Not yet implemented

- Card / bank payment providers; payout-provider integration for withdrawals.
- Real SMS/OTP gateway.
- Live end-to-end EVC Plus charge verification (needs a real handset + PIN) and a provisioned Firebase project for real push delivery.

## Example requests

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Amina Ali","email":"amina@example.com","phone":"+252611234567","password":"supersecret"}'

curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"amina@example.com","password":"supersecret"}'
```
