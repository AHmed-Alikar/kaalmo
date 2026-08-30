# Kaalmo — Security Audit Report

> Audit date: 2026-08-30
> Scope: Full-stack review (React/Vite client, Node/Express + MongoDB/Mongoose server, WaafiPay/Resend integrations)
> Methodology: Static code review (evidence-based, file:line cited). No live exploitation, no destructive testing, no calls to third-party services performed during this audit.

---

## Executive Summary

Kaalmo's core security architecture is **fundamentally sound**: passwords are hashed with bcrypt (cost 12), JWTs use HS256 with no algorithm-confusion risk, mass-assignment is blocked on nearly every mutating endpoint via Zod schemas that strip unknown fields, ownership checks are present on essentially all resource controllers, admin routes are correctly role-gated, file uploads are validated by MIME allow-list with randomized filenames, CORS uses an explicit origin allowlist (never a wildcard with credentials), and audit logging is append-only with good coverage of admin/financial actions.

However, this audit found **one Critical financial-integrity vulnerability** that must be fixed before this platform processes real money: the donor-facing "manual" payment path auto-confirms donations with **zero verification that any money changed hands**, letting anyone inflate a campaign's public `raisedAmount` for free. This is a direct, load-bearing regression from a decision made earlier in this project's history to remove admin approval from the donation flow — the removal correctly applies to the real EVC Plus (WaafiPay) path, which genuinely verifies payment via the provider, but it was never scoped away from the `manual` provider, which has no external verification step at all.

Beyond that, the audit found several **Medium-severity** gaps typical of an MVP-stage product (no refresh-token rotation/revocation, a withdrawal race condition, OTP codes logged in cleartext in unconfigured-email environments, missing query-parameter validation on list endpoints) and a handful of **Low/Informational** items. None of the Medium/Low findings are exploitable for direct financial loss or account takeover on their own, but several compound with the Critical finding and should be fixed in the same pass.

**Production decision: NOT PRODUCTION READY** (blocked solely on the Critical finding below; everything else is High/Medium priority follow-up, not a blocker).

---

## Architecture & Attack Surface

```
Browser (React/Vite)
      ↓ HTTPS (dev: HTTP on localhost)
      ↓
Node.js / Express API (server/src)
      ├── Auth: JWT access (15m) + refresh (30d), bcrypt password hashing, OTP email verification
      ├── Authorization: role-based (donor/organizer/beneficiary/admin/moderator/support) +
      │     campaign-scoped CampaignMember (co-organizer) authorization
      ├── Validation: Zod schemas via middleware/validate.js on request bodies
      ├── File uploads: multer, local disk (server/uploads/), MIME allow-list
      └── MongoDB (Mongoose) — Atlas-hosted, credentials via env
External Services:
      ├── WaafiPay (EVC Plus mobile money) — synchronous HTTPS charge, no webhook wired
      └── Resend (transactional email) — OTP codes, notifications
```

**Trust boundaries identified:**
- Browser ↔ API (every request body/query/header/cookie is untrusted input)
- API ↔ MongoDB (application-level authorization is the only access control — no per-tenant DB users)
- API ↔ WaafiPay (server-to-server HTTPS; WaafiPay's response is the source of truth for payment success)
- API ↔ Resend (outbound only; no inbound webhook from either provider is currently wired)

**Privileged users:** `admin` (full platform access), `moderator` (intended for trust/moderation, currently gated identically to `admin` via the same `requireRole('admin')` blanket — see Finding M-6), campaign `organizer` (owns campaigns), `co-organizer` (campaign-scoped via `CampaignMember`).

**Financial boundaries:** Donation creation → `raisedAmount` aggregation → Withdrawal request → Admin review. The donation-creation boundary is where the Critical finding lives.

---

## Findings

### [CRITICAL] Donor-facing "manual" payment provider auto-confirms with no payment verification

**Risk:**
Anyone — including an unauthenticated visitor — can create a donation that is immediately marked `confirmed` and folded into a campaign's public `raisedAmount`, without any money actually changing hands.

**Location:**
- `server/src/controllers/donationController.js:18-24` — `provider = 'manual'` is the default when the client omits `provider`, and the route (`server/src/routes/campaignRoutes.js:38`) uses `optionalAuth`, not `requireAuth`.
- `server/src/integrations/payments/ManualProvider.js:43-47` — `charge()` calls `createPaymentIntent()` then immediately calls its own `confirmPayment()` with no external check, returning `status: 'confirmed'`.
- `server/src/controllers/donationController.js:36-57` — the confirmed donation is persisted and `recomputeRaisedAmount()` runs immediately, updating the public campaign total.

**Attack Scenario:**
An authorized tester sends:
```
POST /api/v1/campaigns/:id/donate
Content-Type: application/json

{ "amount": 5000 }
```
with no `Authorization` header and no `provider` field. The response returns `status: "confirmed"` and the campaign's `raisedAmount` immediately increases by $5,000 — visible to every donor browsing that campaign, with no admin action, no real payment, and no record that anything is amiss (the donation looks identical to a real EVC Plus donation in every donor-facing and most admin-facing views).

**Impact:**
- Any campaign's progress bar / "raised" total can be fabricated arbitrarily, at zero cost, by anyone with network access to the API.
- A dishonest organizer can inflate their own campaign to build false social proof, or push it past `goalAmount` into `goal_reached`/withdrawal-eligible status.
- Because `Withdrawal` creation checks `raisedAmount` (not a ledger of verified real payments) for the available-balance calculation (`withdrawalController.js:44`), fabricated donations can make an organizer eligible to request a real payout against money that was never actually donated — this is the most severe downstream consequence.

**Fix:**
The `manual` provider must stop being a self-service, auto-confirmed path reachable by any donor. Two options, in order of preference:
1. **Remove `manual` as a donor-selectable provider entirely** on the public `/donate` route — require `provider === 'evc_plus'` explicitly, reject anything else with a 400. Keep `ManualProvider` only for a separate, admin-only "record an offline donation" endpoint that creates the donation as `status: 'pending'` and requires the existing `adminController.confirmManualPayment`/`confirmManualPaymentsBatch` flow to move it to `confirmed`.
2. If a manual/offline donation path must remain donor-reachable (e.g. for cash collected in person and later reported by the organizer), it must create the donation as `pending`, never auto-confirm, and require the existing admin-confirmation flow that was clearly built for exactly this purpose but is currently bypassed.

**Verification:**
After the fix, repeat the attack-scenario request. It must either be rejected (400/403) or create a `pending` donation that does **not** affect `raisedAmount` until an admin explicitly confirms it via `POST /admin/payments/:paymentId/confirm`. Add a regression test asserting `POST /campaigns/:id/donate` with `provider` omitted or `provider: "manual"` never results in `Donation.status === 'confirmed'` without an intervening admin action.

---

### [HIGH] Withdrawal available-balance check has a race condition (no transaction/lock)

**Risk:** Two near-simultaneous withdrawal requests against the same campaign can both read the same "available balance" before either write completes, allowing total approved/pending withdrawals to exceed the campaign's actual `raisedAmount`.

**Location:** `server/src/controllers/withdrawalController.js:34-61` — `available = campaign.raisedAmount - alreadyRequested` is computed via an aggregation read, then a new `Withdrawal` document is created in a separate write, with no Mongo session/transaction or atomic guard between them.

**Attack Scenario:** An authorized tester (as the campaign's organizer) fires two `POST /withdrawals` requests back-to-back (or via a simple concurrent script) for amounts that individually fit within the available balance but together exceed it. Both can succeed if they race between the aggregation read and the `Withdrawal.create()` write.

**Impact:** Total withdrawal requests can exceed the campaign's raised amount, which — depending on how strictly the payout step re-validates — could result in the platform paying out more than a campaign actually raised.

**Fix:** Wrap the read-aggregate-then-create sequence in a MongoDB transaction (`session.withTransaction`), or enforce the invariant atomically (e.g., a single `findOneAndUpdate` with a filter condition on the campaign's remaining balance, using an atomic counter field updated alongside withdrawal creation rather than recomputed via aggregation on every request).

**Verification:** Fire two concurrent withdrawal requests in a test that together exceed the available balance; assert exactly one succeeds and the other returns `INSUFFICIENT_FUNDS`.

---

### [MEDIUM] OTP codes are logged in cleartext when no email provider is configured

**Risk:** Verification and organizer-access OTP codes are written to server console output in cleartext whenever `RESEND_API_KEY` is unset — including in production if that variable is ever missing due to misconfiguration (the code only `console.warn`s, it doesn't block).

**Location:** `server/src/services/emailService.js:9-15`.

**Attack Scenario:** Anyone with access to server logs, log aggregation, or process stdout (ops tooling, a misconfigured logging pipeline, a compromised log-shipping agent) can read live OTP codes for any user and complete email verification or organizer-access confirmation on their behalf.

**Impact:** Account-verification bypass for any user, by anyone with log access — this is a real risk specifically in a misconfigured-production scenario, and a design smell even in dev.

**Fix:** Never log the raw code. In dev-without-email-provider mode, either omit the code from the logged line (log "OTP sent" without the value) or gate the fallback behind an explicit `NODE_ENV !== 'production'` check that additionally throws/fails the request in production if no email transport is configured, rather than silently degrading to console logging.

**Verification:** With `RESEND_API_KEY` unset and `NODE_ENV=production`, confirm the verification-email endpoint fails closed (500/503) rather than falling back to console logging.

---

### [MEDIUM] No donation idempotency — double-submit creates duplicate confirmed donations

**Risk:** A donor double-clicking "Donate," a client retry after a timeout, or a WaafiPay retry can create two separate confirmed `Donation` records for what the donor believes was a single payment.

**Location:** `server/src/controllers/donationController.js:36-57` — no idempotency key is accepted from the client, and each call unconditionally creates a new `Payment`/`PaymentTransaction`/`Donation`.

**Fix:** Accept an optional client-generated idempotency key (or derive one from donor+campaign+amount+short time window) and short-circuit duplicate submissions; for the real WaafiPay path additionally rely on the provider's own transaction id where available to detect a retried charge.

**Verification:** Submit the same donation request twice in quick succession; assert only one `Donation` is created.

---

### [MEDIUM] No refresh-token rotation, revocation, or logout endpoint

**Risk:** A leaked 30-day refresh token remains valid for its full lifetime with no way to revoke it short of rotating the shared JWT secret for every user on the platform.

**Location:** `server/src/services/authService.js:85-99` (`refresh` — reissues both tokens without rotating/invalidating the old refresh token), and there is no logout route in `server/src/routes/authRoutes.js`.

**Fix:** Implement refresh-token rotation with a persisted token identifier (jti) per issued refresh token, invalidate the previous token on each refresh, and add a logout endpoint that revokes the current refresh token server-side.

**Verification:** After calling `/auth/refresh`, confirm the previous refresh token can no longer be used to obtain new tokens.

---

### [MEDIUM] Banned/suspended user's existing access token stays valid until natural expiry

**Risk:** `adminController.updateUserStatus` (suspend/ban) does not revoke the user's already-issued access token; `requireAuth` only checks the JWT signature/claims, never rechecks `user.status` against the database.

**Location:** `server/src/middleware/auth.js` (no DB status check), `server/src/controllers/adminController.js:246-249`.

**Impact:** A banned user retains full access for up to 15 minutes (the access-token TTL) after being banned — bounded but real.

**Fix:** Either (a) check `user.status === 'active'` against the DB in `requireAuth` for security-sensitive routes (accepting the added DB round-trip), or (b) maintain a short-lived revocation list/cache keyed by user id that `requireAuth` checks, cleared on token expiry.

**Verification:** Ban a test user, then replay their still-unexpired access token against a protected route; confirm it's rejected.

---

### [MEDIUM] NoSQL operator injection via unvalidated query parameters on public listing endpoint

**Risk:** `middleware/validate.js` only validates `req.body`; query-string parameters are never validated anywhere. A public, unauthenticated endpoint builds a Mongo filter directly from raw query values.

**Location:** `server/src/controllers/campaignController.js:32-37` (`listCampaigns`) — `if (category) filter.category = category;` / `if (region) filter.region = region;`, with no type coercion on `req.query.category`/`req.query.region`.

**Attack Scenario:** `GET /api/v1/campaigns?category[$ne]=null` — Express's query parser turns bracket syntax into a nested object, so `req.query.category` becomes `{ $ne: null }` and is placed directly into the Mongoose filter, letting an unauthenticated caller inject Mongo query operators to bypass the intended category filter (filter-bypass/enumeration risk, not direct data exfiltration beyond what's already public).

**Fix:** Add a `validateQuery(schema)` middleware (same pattern as the existing `validate()`) and give `listCampaigns` (and the equivalent admin list endpoints — see Low finding below) a Zod schema that types `category`/`region`/`status`/`q` as plain optional strings before they reach the Mongo filter.

**Verification:** Repeat the attack-scenario request after the fix; confirm it either 400s or is coerced to a harmless string comparison that matches nothing.

---

### [MEDIUM] OTP brute-force protection is IP-based only, no per-code attempt lockout

**Risk:** The 6-digit OTP verification endpoints are only protected by a 20-requests/15-minutes **IP-based** rate limit — a distributed attempt (many source IPs) against one user's OTP within its 15-minute validity window is not stopped, and there's no per-record failed-attempt counter that invalidates a code after N wrong guesses.

**Location:** `server/src/services/authService.js` (OTP verification logic), rate limiter at `server/src/middleware/rateLimit.js:3-9`.

**Fix:** Add a failed-attempt counter on the OTP record itself; invalidate the code (force a resend) after e.g. 5 incorrect attempts, independent of source IP.

**Verification:** Attempt 6 incorrect codes against one pending verification; confirm the 6th is rejected as "too many attempts" rather than just "incorrect code."

---

### [LOW] Query-parameter injection pattern repeated on admin-only list endpoints

**Location:** `server/src/controllers/adminController.js` (`listAllCampaigns`, `listDonations`, `listBeneficiaries`), `server/src/controllers/reportController.js:19-20`, `server/src/controllers/supportTicketController.js:58-59`. Same root cause as the Medium finding above; lower severity because these routes already require `requireRole('admin')`. Fix alongside the Medium finding using the same `validateQuery` middleware.

Also: `adminController.js` `listUsers` builds a `$regex` filter directly from `req.query.q` with no length/pattern limit — a pathological regex could cause a slow query (ReDoS-adjacent). Low severity given admin-only access; recommend capping input length and/or escaping regex metacharacters.

---

### [LOW] `reviewWithdrawal` route has no Zod validation

**Location:** `server/src/routes/withdrawalRoutes.js:10` — unlike every other admin mutation route, this one has no `validate()` call; `req.body.status` is trusted directly against the Mongoose enum only.

**Fix:** Add a Zod schema (`z.object({ status: z.enum([...]), reason: z.string().optional() })`) for consistency and to keep the audit-log action string (`withdrawal.${status}`) from ever containing unexpected values.

---

### [LOW] Missing rate limiting on refresh, admin routes, support tickets, and reports

**Location:** `server/src/routes/authRoutes.js` (`/auth/refresh`), `server/src/routes/adminRoutes.js` (entire router), `POST /support-tickets`, `POST /reports`.

**Fix:** Add a general-purpose rate limiter to these routes — even a generous one (e.g. 100 req/15 min) closes the gap without affecting legitimate usage.

---

### [LOW/MEDIUM] `createWithdrawal` (the request itself) is not audit-logged

**Location:** `server/src/controllers/withdrawalController.js` — only `reviewWithdrawal` (the admin's later decision) calls `logAudit`; the organizer's initial withdrawal request is not recorded.

**Fix:** Add a `logAudit` call in `createWithdrawal` capturing who requested how much, when, and against which campaign — this closes a real gap in the financial audit trail, especially relevant given the Critical/High findings above.

---

### [INFORMATIONAL] No startup validation that JWT secrets are configured

**Location:** `server/src/utils/jwt.js`, `server/src/server.js` — if `JWT_ACCESS_SECRET`/`JWT_REFRESH_SECRET` are unset, the app boots successfully and only fails at the first sign/verify call. No weak default is used (this is not a vulnerability), but fail-fast-at-boot is better operational practice.

**Fix:** Add a startup check that throws if either secret is missing, per Design Rule "fail secure."

---

### [INFORMATIONAL] No explicit Content-Security-Policy beyond Helmet defaults

**Location:** `server/src/app.js:27`. Helmet's default CSP is present but not tailored to Kaalmo's actual origins. Lower priority for a JSON API + static-upload server than for an HTML-serving app, but worth revisiting once the client is served from behind the same reverse proxy in production.

---

### [INFORMATIONAL] `moderator` role is not actually distinguished from `admin`

**Location:** `server/src/routes/adminRoutes.js:16` — `router.use(requireAuth, requireRole('admin'))` gates the entire admin router; there is no separate, narrower gate for the `moderator` role described in the product spec (trust/verification/reports/moderation only). Not a vulnerability today (no user currently holds `moderator` without also holding `admin`, per the seed data), but worth closing before `moderator` accounts are actually issued, so a moderator can't reach financial/user-management endpoints intended for `admin` only.

---

## Areas Verified as Well-Handled (no findings)

- **Password storage**: bcrypt, cost 12, never logged or returned via API.
- **JWT signing**: HS256 via `jsonwebtoken`, no `alg: none` risk, no hardcoded secrets.
- **Mass assignment**: Zod schemas strip unknown fields on essentially every mutating endpoint (campaign create/update, user profile update, admin actions); a client cannot set `role`, `status`, `raisedAmount`, `verificationBadges`, `organizerId` etc. through normal update endpoints.
- **Ownership/IDOR**: explicit ownership checks present on campaigns, withdrawals, campaign members, payout accounts, beneficiaries, support tickets, notifications.
- **Admin route gating**: correctly blanket-protected by `requireRole('admin')`.
- **File uploads**: strict MIME allow-list, 5MB limit, cryptographically random filenames (no path traversal, no user-controlled extension), served as static (non-executable) content.
- **Secrets management**: `.env` is git-ignored and confirmed not committed; no hardcoded secrets found in source.
- **CORS**: explicit origin allowlist, never a wildcard paired with credentials.
- **Error handling**: generic client-facing error messages, no stack traces or internals leaked, consistent regardless of `NODE_ENV`.
- **Audit log immutability**: append-only, no update/delete route exists.
- **Dependencies**: all major packages (`jsonwebtoken`, `mongoose`, `express`, `multer`, `bcryptjs`, `helmet`, `express-rate-limit`, `zod`) are on current, non-deprecated major versions.
- **Webhook surface**: correctly not wired up at all yet (no live attack surface); flagged only as a reminder that signature verification is mandatory before any webhook route is added.

---

## Security Score

```
52 / 100
```

The core authentication, authorization, mass-assignment, file-upload, and secrets-handling architecture is genuinely strong for an MVP-stage product — well above what the score alone suggests. The score is dominated by the single Critical financial-integrity finding, which by itself represents a direct, unauthenticated path to fabricating money the platform believes it holds — a severity class that caps the score regardless of how well everything else scores, consistent with this audit's priority order (Security → Privacy → **Financial Integrity** → Reliability → Correctness → Performance → Convenience).

| Category | Assessment |
|---|---|
| Authentication | Strong hashing/JWT; Medium gaps in refresh-token lifecycle and OTP brute-force/logging |
| Authorization | Strong — no missing ownership checks found |
| API Security | Good validation discipline on bodies; query-param validation gap |
| Database Security | Application-level authorization solid; no injection beyond query-param gap |
| Infrastructure/Secrets | Clean — no leaked secrets, correct `.env` handling |
| **Payments/Financial Integrity** | **Critical gap** — auto-confirmed manual donations; withdrawal race condition |
| Business Logic | Otherwise sound state machines (campaign lifecycle, beneficiary verification) |
| Privacy | Reasonable; raw WaafiPay payload retention worth a policy review |
| Dependencies | Current, no red flags |
| Monitoring/Logging | Good audit-log coverage; OTP-logging gap |

---

## Production Decision

```
NOT PRODUCTION READY
```

**Reason:** One Critical finding — the donor-facing `manual` payment provider auto-confirming donations with no verification — allows anyone to fabricate confirmed money in a live campaign's raised total, and downstream, to make a campaign eligible for a real payout against funds that were never actually donated. This must be fixed (see the Critical finding's Fix section) before this platform can safely process real money.

Once the Critical finding is resolved and the High-severity withdrawal race condition is addressed, the remaining Medium/Low findings should be triaged and fixed on a normal engineering timeline — none of them block launch on their own, but several (OTP logging, refresh-token rotation, donation idempotency) should be scheduled soon after, given this platform's stated mission of being a trustworthy place to send real money.
