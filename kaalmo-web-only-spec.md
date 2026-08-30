# Kaalmo — Somalia-First Fundraising Web Platform
### Complete Product & Technical Specification (MERN Stack — Web Only)

*Prepared as a practical, developer-ready blueprint — idea → architecture → MVP → scale.*

---

## 1. Project Vision

**What it is:** Kaalmo is a Somalia-first digital fundraising platform — conceptually similar to GoFundMe, but built around how Somalis actually raise and give money: through trusted community networks, mobile money, diaspora remittance habits, and word-of-mouth verification rather than institutional trust.

**Problem it solves:** Today, most Somali fundraising happens informally — WhatsApp forwards, Facebook posts, hawala transfers to a relative's number. This works, but it has no transparency, no proof funds were used correctly, no protection against fraud, and no way for a diaspora donor abroad to verify a campaign before sending money. Formal platforms like GoFundMe don't support Somali mobile money rails (EVC Plus, eDahab, Zaad), don't work well in Somali/English, and have no local trust or verification layer.

**What Somalis need:** A place where a family can post a medical emergency and have it verified by community elders or documents; where a diaspora member in Minneapolis or London can donate directly with a card and see exactly how funds are used; where mobile money is a first-class payment method, not an afterthought.

**Target users:** Somali families and individuals inside Somalia, Somali diaspora donors (US, UK, EU, Gulf, Kenya), local NGOs/mosques/schools, and community organizers running public-interest projects (wells, clinics, classrooms).

**Differentiation from GoFundMe:** Mobile-money-first payments, Somali+English bilingual UX, low-bandwidth-friendly design, community/elder-style verification layer suited to Somali trust culture, and a campaign taxonomy that treats community/mosque/school projects as first-class citizens, not edge cases.

**Unique value proposition:** *"The fastest, most trusted way for Somalis anywhere to raise and give money for what matters — verified, transparent, and built for how Somalia actually pays."*

**Long-term vision:** Become the default fundraising and community-giving infrastructure for Somalia and the Somali diaspora — eventually expanding into recurring giving (sadaqah/waqf-style ongoing support), NGO partnerships, and regional expansion into East Africa.

**Real-world examples the product must serve well:**
1. A woman needing $8,000 for cancer treatment in Nairobi.
2. A family who lost their home in a Mogadishu fire needing emergency shelter funds.
3. A student needing university tuition for the next semester.
4. A young man needing funds to study abroad.
5. A family needing funeral/burial costs within 48 hours (time-critical, culturally urgent).
6. A village community raising money to dig a well.
7. A school needing a computer lab.
8. A rural clinic needing medical equipment.
9. An NGO running a seasonal food-distribution project.
10. A mosque needing renovation funds.
11. Diaspora-led disaster relief after flooding or drought.

---

## 2. Product Concept

**Core problem:** Somalis lack a trusted, transparent, locally-payable way to raise money for personal and community needs — so they default to unverifiable informal channels.

**Target audience:** (a) Organizers — individuals or community members raising funds; (b) Donors — local Somalis and diaspora members; (c) Beneficiaries — the person/institution funds are for; (d) NGOs/community groups running public campaigns.

**User personas:**
- **Amina, 34, Mogadishu** — needs $3,000 for her son's surgery. Has a smartphone, weak internet, uses EVC Plus daily. Wants something simple, in Somali, that her community can trust enough to donate to.
- **Yusuf, 41, diaspora, Minneapolis** — sends money home regularly via hawala. Wants to donate by card, see proof the campaign is real, and get updates on impact.
- **Hodan, 26, Hargeisa** — university-educated, organizes fundraisers for her extended family and community. Comfortable with apps, wants analytics and an easy way to withdraw funds.
- **Sheikh Cabdi, mosque committee** — represents an institutional beneficiary needing a verified organizational account.

**Jobs-to-be-done:** "Help me raise money quickly and be believed." / "Help me give money safely to someone I trust is real." / "Help me track and prove how funds were used."

**Value proposition:** Faster trust, local payment rails, bilingual and low-bandwidth by design, culturally-aware campaign categories.

**Positioning:** Not a GoFundMe clone — a *trust-and-payments layer* purpose-built for the Somali context.

**Product statement:**
> "Kaalmo helps Somali families, communities, and diaspora donors to raise and give money for urgent and community needs, by combining local-payment-first fundraising with a trust and verification system suited to Somali culture."

---

## 3. Market & Somalia Context

| Factor | Implication for Design |
|---|---|
| Mobile-first users, many on Android/low-end devices | Responsive web app, lightweight assets, mobile-friendly design |
| Unreliable/limited internet | Aggressive caching, low-res image defaults, offline-tolerant forms (draft autosave), skeleton loading over spinners |
| Mobile money dominant (EVC Plus, eDahab, Zaad, Sahal) | Mobile money must be a first-class payment method, not "alternative payment" |
| Bank penetration low but growing (Salaam Bank, Premier Bank, Dahabshiil) | Bank transfer supported for organizations/larger donations |
| Card payments mainly used by diaspora | Card checkout targeted at international/diaspora donor flows |
| Somali is the primary spoken language; English used by educated urban/diaspora users | Full bilingual UI, campaign content dual-language optional |
| High fraud sensitivity / trust deficit | Verification badges, visible organizer identity, community vouching, transparent fund-usage updates |
| Diaspora sends significant remittances already | Familiar "sending money home" mental model — reuse it, don't reinvent it |
| Regional differences (Somaliland, Puntland, South-Central) | Region field on campaigns; be neutral/non-political in categorization |
| Currency: USD is commonly quoted informally, Somali Shilling used locally | Support USD as primary campaign currency (most trusted for large amounts) with SOS display option |
| Low-bandwidth UX | Text-first fallback, compressed images, lazy-loaded media |

**Growth path:** Somalia-first → Somali diaspora hubs (US, UK, EU, Gulf, Kenya) → East Africa neighboring markets → broader international donor access.

---

## 4. User Roles

| Role | Core Purpose | Key Permissions | Key Restrictions |
|---|---|---|---|
| **Donor** | Gives money | Browse, donate, comment, follow, bookmark, view own donation history/receipts | Cannot edit campaigns, cannot see other donors' private info |
| **Organizer** | Creates & runs a campaign | Create/edit/publish/pause/close campaign, invite co-organizers, post updates, request withdrawal | Cannot self-verify; cannot withdraw without beneficiary+payment verification |
| **Beneficiary** | The person/entity funds are for | Accept invitation, submit verification docs, connect payout account, view progress | Cannot edit campaign content unless also organizer |
| **Co-organizer** | Assists organizer | Post updates, view donations/analytics, edit campaign content | Cannot request withdrawals or delete campaign (organizer-only) |
| **Admin** | Platform operator | Full access: users, campaigns, payments, withdrawals, verification, settings | Web dashboard only, no native mobile app |
| **Moderator / Trust & Safety** | Reviews risk | Review/approve/reject/freeze campaigns, handle reports, manage fraud queue | Cannot access platform-wide financial settings or fee configuration |
| **Support Agent** | Customer support | View tickets, view limited user/campaign info, respond to inquiries | No access to withdrawal approval or fraud actions |

Each role gets a dashboard scoped to only what it needs — organizer dashboards emphasize campaign performance; admin dashboards emphasize risk and financial oversight.

---

## 5. Web vs Mobile Strategy

```text
Donor         → Responsive Web App
Organizer     → Responsive Web App
Beneficiary   → Responsive Web App
Co-organizer  → Responsive Web App
Admin         → Web Admin Dashboard
Moderator     → Web Admin Dashboard
```

**Why mobile matters:** Discovery, sharing to WhatsApp/social, donating on the go, push notifications for campaign updates, and photo/video capture for campaign creation all fit mobile usage patterns better than desktop web.

**Why responsive web works:** Long-form campaign writing, document review, analytics dashboards, and administration are handled in one web platform, with layouts optimized for both large and small screens.

**Admin Web:** Admin work involves sensitive financial approvals, fraud review, and document verification, so it remains within the secure web admin dashboard.

**Backend:** A Node.js/Express REST API serves the React web application. All business logic, validation, and financial rules live server-side; the web client is a presentation layer. An OpenAPI contract keeps the client and backend in sync.

---

## 6. Technology Stack

### MVP Stack

| Layer | Choice | Why |
|---|---|---|
| Frontend Web | React.js + Vite, Tailwind CSS, React Router | Fast dev velocity, huge ecosystem, Tailwind keeps UI consistent without heavy design overhead |
| Backend | Node.js + Express.js | Matches MERN requirement, huge middleware ecosystem, easy JSON API development |
| Database | MongoDB + Mongoose | Flexible schema fits evolving campaign/verification data; document model fits campaign+updates+comments naturally |
| Auth | JWT (access + refresh tokens) | Stateless, scales horizontally, works identically across web/mobile |
| File storage | Object storage (S3-compatible, e.g. Cloudflare R2 or AWS S3) | Needed for campaign images/videos and verification documents; cheap and scalable |
| Email | Transactional email provider (e.g. Resend/SendGrid) | Needed for verification, receipts, notifications |
| SMS/OTP | Local-capable SMS gateway (e.g. Africa's Talking or a Somalia-reachable provider) | Needed for phone verification — must be validated against actual Somali carrier reachability |

### Future Scale Stack (not MVP)

| Addition | Purpose |
|---|---|
| Redis | Caching, rate limiting, session/token blacklist, job queues |
| Background job queue (BullMQ on Redis) | Async webhook processing, notification dispatch, report generation |
| Push notifications (FCM) | Real-time mobile alerts |
| CDN | Faster media delivery globally |
| Monitoring (Sentry, Prometheus/Grafana) | Error tracking, performance monitoring |
| Centralized logging (e.g. ELK/Loki) | Audit and debugging at scale |
| Analytics pipeline | Product analytics beyond basic admin counts |

**Explicitly not in MVP:** Redis, job queues, push notifications, advanced analytics, multi-region deployment, GraphQL. These are added once real usage justifies the operational overhead.

---

## 7. Complete Feature Specification

### Organizer
Create / edit / publish / pause / close fundraiser; set goal; add story, images, video; add beneficiary; add co-organizer; post updates; view donations & analytics; thank donors; request withdrawal; manage profile.

### Donor
Browse; search; filter; view campaign; donate; anonymous donation; donation message; payment history; receipts; share; follow; receive updates; bookmark.

### Beneficiary
Accept invitation; verify identity; connect payout account; view progress; view withdrawal status.

### Admin
Dashboard; user management; campaign management; donation management; payment management; withdrawal management; verification management; fraud detection; reports; categories; content moderation; disputes; support tickets; audit logs; platform settings; analytics.

### Trust & Safety
Report campaign/user; identity/phone/email/beneficiary/payment verification; campaign moderation; fraud detection; risk scoring; suspicious activity alerts; campaign/withdrawal freeze; account suspension; appeals.

### Social
Sharing; comments; updates; likes/support; followers; referral tracking; social previews (Open Graph cards for WhatsApp/Facebook shares — critical for Somali sharing culture).

**Example — Organizer "Post Update" feature spec:**
- *Business purpose:* Updates are the #1 trust signal after initial verification — donors who see progress updates donate again and share more.
- *User story:* As an organizer, I want to post a photo/text update so donors know their money is being used well.
- *Acceptance criteria:* Update requires text (min 10 chars); optional image; visible to all campaign followers; triggers notification to donors.
- *UX flow:* Dashboard → Campaign → Updates tab → "Post Update" → text/image → Publish → confirmation toast.
- *API:* `POST /api/v1/campaigns/:id/updates`
- *DB impact:* New document in `Updates` collection referencing `campaignId`.
- *Security:* Organizer/co-organizer only; image upload scanned/validated; rate-limited to prevent spam.
- *MVP priority:* Must Have.

---

## 8. Campaign Types / Projects

**Categories:** Medical, Education, Emergency, Family, Funeral, Community, Mosque, School, Orphan Support, Disaster Relief, Business/Startup, NGO, Public Projects, Other.

Each category can have **subcategories** (e.g. Medical → Surgery, Treatment, Medication, Disability Support) and **tags** (free-text, admin-moderated, used for search/discovery).

**Campaign status values:** `draft`, `submitted`, `under_review`, `approved`, `published`, `active`, `goal_reached`, `withdrawal`, `completed`, `rejected`, `suspended`, `frozen`, `cancelled`, `expired`.

**Verification badges:** Identity Verified, Beneficiary Verified, Payment Verified, Organization Verified — shown as icons on the campaign card and detail page.

**Discovery surfaces:** Featured campaigns (admin-curated), Trending (velocity-based ranking), Successful (goal-reached, social proof), Near You (region-based, optional).

---

## 9. Campaign Lifecycle

```text
DRAFT → SUBMITTED → UNDER_REVIEW → APPROVED → PUBLISHED → ACTIVE
→ GOAL_REACHED → WITHDRAWAL → COMPLETED
```

Side states: `REJECTED`, `SUSPENDED`, `FROZEN`, `CANCELLED`, `EXPIRED`.

| Status | Meaning |
|---|---|
| DRAFT | Organizer is still editing; not visible to anyone else |
| SUBMITTED | Organizer has submitted for review; locked from further edits except minor fields |
| UNDER_REVIEW | Moderator actively checking documents/story/beneficiary |
| APPROVED | Passed review, ready to go live |
| PUBLISHED | Live and publicly visible, may still be pre-donation |
| ACTIVE | Actively receiving donations |
| GOAL_REACHED | Funding goal met (campaign can still receive donations unless organizer closes it) |
| WITHDRAWAL | Beneficiary/organizer has requested payout, admin reviewing |
| COMPLETED | Funds disbursed, campaign archived as successful |
| REJECTED | Failed review with reason shown to organizer, can resubmit after fixes |
| SUSPENDED | Temporarily hidden due to a report/investigation |
| FROZEN | Donations/withdrawals blocked pending fraud investigation |
| CANCELLED | Organizer withdrew the campaign voluntarily |
| EXPIRED | Passed end date without reaching goal or being closed |

---

## 10. User Experience / UX

**Organizer journey:** Register → Verify account → Create fundraiser → Add info → Upload media → Add beneficiary → Submit → Verification → Approval → Publish → Share → Receive donations → Post updates → Request withdrawal → Receive funds.

Friction points to design against: verification feels slow/bureaucratic (mitigate with clear progress indicators + expected review time); uploading documents on slow connections (mitigate with client-side compression + resumable upload); uncertainty about "did my campaign go live?" (mitigate with proactive SMS/push at every status change).

**Donor journey:** Discover → View campaign → Read story → Check verification → Donate → Payment → Confirmation → Receipt → Follow → Receive updates.

Friction points: trust hesitation before donating (mitigate with prominent badges + visible organizer identity + real update history); payment failure anxiety, especially with mobile money (mitigate with clear retry flow and instant confirmation via SMS); wanting to donate anonymously without losing receipt access (support anonymous-to-public but authenticated-to-platform).

---

## 11. Pages & Screens Inventory

**Public Web:** Home, Explore, Search, Categories, Campaign Details, About, How It Works, Safety, FAQ, Contact, Terms, Privacy, Help Center.

**Auth:** Register, Login, Forgot Password, Reset Password, Email Verification, Phone Verification/OTP.

**Organizer:** Dashboard, My Campaigns, Create Campaign (multi-step), Edit Campaign, Preview, Analytics, Donations, Updates, Beneficiary, Team, Withdrawals, Settings.

**Donor:** Dashboard, Donation History, Saved Campaigns, Followed Campaigns, Notifications, Profile, Settings.

**Admin (Web only):** Dashboard, Users, Campaigns, Campaign Review, Donations, Payments, Withdrawals, Reports, Fraud/Risk, Verification, Categories, Moderation, Support, Audit Logs, System Settings, Analytics.

**Responsive Web:** Donor/Organizer/Beneficiary/Co-organizer functionality is available through the responsive web application. No native mobile app.

**Per-screen spec pattern (apply to every screen above):**
- *Purpose* — what job this screen does
- *Main components* — key UI blocks
- *User actions* — what can be tapped/submitted
- *API calls* — which endpoints it hits
- *Data displayed* — fields shown
- *Empty / Loading / Error / Success states* — explicit UI for each

**Example — Campaign Details screen:**
- *Purpose:* Convince a visiting donor to trust and donate.
- *Main components:* Hero image/video, progress bar, goal/raised amount, organizer identity block, verification badges, story, updates feed, comments, donate CTA, share buttons.
- *User actions:* Donate, Follow, Bookmark, Share, Comment, Report.
- *API calls:* `GET /api/v1/campaigns/:id`, `GET /api/v1/campaigns/:id/updates`, `GET /api/v1/campaigns/:id/comments`.
- *Data displayed:* Title, story, goal, raised amount, donor count, days left, badges, organizer name/photo, category.
- *Empty state:* "No updates yet" placeholder with organizer-facing prompt to post one.
- *Loading state:* Skeleton card matching final layout.
- *Error state:* "Campaign not found or unavailable" with link back to Explore.
- *Success state:* Post-donation confirmation modal with share prompt.

---

## 12. UI / Design System

**Color strategy:** A warm, trustworthy primary (deep teal or Somali-flag-adjacent blue) paired with a warm accent (gold/amber) for CTAs and progress bars — avoids the cold, corporate blue-and-white "banking dashboard" look. Success/verification states use green sparingly and meaningfully (badges only, not decoration).

**Typography:** A humanist sans-serif (e.g. Inter or similar) for Latin script, paired with a Somali/Arabic-legible font fallback stack; generous line-height for readability at small sizes on low-end phones.

**Core components:** Buttons (primary/secondary/ghost, large tap targets for mobile), Campaign Card (image, progress bar, title, raised/goal, badge row), Donation Component (amount presets + custom, payment method selector), Progress Bar (percentage + raised/goal text, not just visual), Verification Badge (icon + label, tappable to explain what it means), Forms (large inputs, inline validation, Somali/English labels), Modals (donation flow, share flow), Alert States (success/warning/error, plain language, no jargon), Empty States (friendly illustration + clear next action), Dashboard Layout (sidebar nav on web, bottom nav on mobile).

**Design principle:** Every screen should visually answer "is this real and safe?" before it asks "will you give money?" — badges, organizer photo, and update recency are given more visual weight than typical fundraising sites give them.

---

## 13. Localization

Language switcher: **Somali | English**, persisted per user, defaulting by device locale.

- Somali and English content fields on campaigns (title/story) — English optional, Somali default.
- Currency formatting: USD primary (e.g. `$1,250`), with an optional SOS-equivalent display using a periodically updated exchange rate.
- Date formatting: locale-aware (DD/MM/YYYY common in Somalia).
- Number formatting: comma-grouped, no unnecessary decimals for whole-dollar donations.
- RTL: not needed for Somali (Latin script) but the design system should keep RTL support in mind (logical CSS properties, no hardcoded left/right) so Arabic can be added later without a rewrite.
- Local terminology: use familiar terms — "Ururin" (fundraiser/collection), "Deeqda" (donation), "Qaabilaha" (beneficiary) — validated with native speakers before launch, not machine-translated.

---

## 14. Payment System

This is the highest-risk, highest-priority part of the system. **No specific payment provider integration details are assumed here** — mobile money aggregators, bank APIs, and card processors available in Somalia should be verified directly with current provider documentation before implementation, since availability, fees, and KYC requirements change.

### Payment Abstraction Layer

```text
PaymentService (interface)
├── MobileMoneyProvider (EVC Plus / eDahab / Zaad — verify current API availability)
├── BankProvider (local bank transfer/collection)
├── CardProvider (international card processor with Somalia reach — verify)
└── ManualProvider (admin-recorded offline donation, for MVP fallback)
```

Each provider implements a common interface: `createPaymentIntent()`, `confirmPayment()`, `handleWebhook()`, `refund()`. The core donation flow never talks to a provider directly — it talks to `PaymentService`, which routes to the right provider. This means adding Provider C later requires **zero changes** to campaign/donation logic, only a new provider adapter + config.

**Flow:** Payment Intent created → Donor redirected/prompted to provider (STK-push-style for mobile money) → Provider webhook confirms → `PaymentTransaction` marked `confirmed` → `Donation` marked `confirmed` → Campaign `raisedAmount` incremented → Receipt generated → Donor notified.

**Must handle:** pending payments (mobile money confirmation can take 10–60s), failed payments (clear retry UX), idempotency (webhook may fire more than once — dedupe by provider transaction ID), signature verification on every webhook, refunds (organizer/admin-initiated, pre-withdrawal only), chargebacks (card only), multi-currency (USD primary), fee transparency (show donor exactly what platform fee, if any, applies before confirming).

**Financial integrity rule:** `PaymentTransaction` records are **append-only/immutable** — corrections are made via new reversal/adjustment records referencing the original, never by editing or deleting a transaction row. This is non-negotiable for audit and dispute resolution.

---

## 15. Withdrawal / Payout System

```text
Campaign raises funds
→ Beneficiary verification confirmed
→ Organizer/Beneficiary submits withdrawal request
→ Admin/risk review (auto-approve under threshold + manual above threshold)
→ Payout routed via PaymentService to chosen payout method
→ Payout confirmed by provider webhook
→ Withdrawal marked COMPLETED, campaign ledger updated
```

- **Payout methods:** Mobile money payout (organizer/beneficiary's registered number), bank payout (for larger/institutional withdrawals).
- **Beneficiary verification is a hard prerequisite** — no withdrawal can be requested until beneficiary identity + payout account are verified.
- **Withdrawal limits:** Configurable per-transaction and daily/weekly caps, tighter for newly verified accounts, loosened after track record.
- **States:** `pending`, `under_review`, `approved`, `processing`, `completed`, `failed`, `frozen`.
- **Manual review triggers:** First withdrawal on a new campaign, amount above threshold, risk score above a configured level, mismatched beneficiary/payout name.
- **Audit trail:** Every state transition logged with actor (system/admin ID), timestamp, and reason — immutable log, never overwritten.

---

## 16. Database Design (MongoDB)

Below: representative schema for each core entity (fields, types, indexes, relationships). Full field lists should be extended per implementation, but this defines the authoritative shape.

**Users**
```js
{
  _id: ObjectId,
  fullName: String,
  email: { type: String, unique: true, index: true },
  phone: { type: String, unique: true, index: true },
  passwordHash: String,
  roles: [String], // ['donor','organizer','beneficiary','admin','moderator','support']
  language: String, // 'so' | 'en'
  emailVerified: Boolean,
  phoneVerified: Boolean,
  identityVerified: Boolean,
  status: String, // active, suspended, banned
  createdAt: Date, updatedAt: Date
}
```
Indexes: `email` unique, `phone` unique, `roles`.

**Campaigns**
```js
{
  _id: ObjectId,
  organizerId: { type: ObjectId, ref: 'User', index: true },
  beneficiaryId: { type: ObjectId, ref: 'Beneficiary' },
  title: { so: String, en: String },
  story: { so: String, en: String },
  category: { type: String, index: true },
  subcategory: String,
  tags: [String],
  goalAmount: Number,
  raisedAmount: { type: Number, default: 0 },
  currency: { type: String, default: 'USD' },
  coverImageUrl: String,
  mediaUrls: [String],
  status: { type: String, index: true },
  verificationBadges: [String],
  region: String,
  endDate: Date,
  createdAt: Date, updatedAt: Date
}
```
Indexes: `organizerId`, `status`, `category`, text index on `title`/`story` for search.

**CampaignMembers** (co-organizers): `{ campaignId, userId, role: 'co-organizer', invitedAt, acceptedAt }`

**Beneficiaries**
```js
{ _id, userId, fullName, idDocumentUrl, verificationStatus, verifiedAt, verifiedBy, payoutAccountId }
```

**Donations**
```js
{
  _id, campaignId: { ref:'Campaign', index:true }, donorId: { ref:'User', index:true, sparse:true },
  amount: Number, currency: String, isAnonymous: Boolean, message: String,
  paymentTransactionId: { ref:'PaymentTransaction' }, status: String, createdAt: Date
}
```

**Payments / PaymentTransactions / PaymentWebhooks** — separate collections: `Payments` (high-level intent), `PaymentTransactions` (immutable ledger entries per provider event), `PaymentWebhooks` (raw webhook payload + signature verification result, retained for audit/dispute even after processing).

**Withdrawals**
```js
{ _id, campaignId, requestedBy, amount, payoutAccountId, status, reviewedBy, reviewedAt, providerTransactionId, createdAt }
```

**PayoutAccounts**: `{ _id, ownerId, type: 'mobile_money'|'bank', accountNumberMasked, providerName, verified }`

**Updates / Comments / Likes / Followers / Bookmarks** — straightforward reference collections keyed by `campaignId` + `userId`, each indexed on `campaignId`.

**Notifications**: `{ _id, userId, type, payload, channel, read, createdAt }`

**Reports**: `{ _id, reporterId, targetType: 'campaign'|'user', targetId, reason, status, createdAt }`

**FraudCases**: `{ _id, subjectType, subjectId, riskScore, signals: [String], status, assignedTo, createdAt }`

**Verifications**: `{ _id, userId or beneficiaryId, type: 'email'|'phone'|'identity'|'beneficiary'|'payment'|'organization', status, documentUrls, reviewedBy, createdAt }`

**AuditLogs**: `{ _id, actorId, actorType, action, targetType, targetId, metadata, createdAt }` — immutable, append-only.

**SupportTickets, Referrals, Fees, Categories** — standard supporting collections.

### Embedded vs Referenced

- **Embed** when data is small, bounded, and always read together with the parent (e.g. a campaign's `verificationBadges` array, a user's `roles` array).
- **Reference** when data grows unboundedly (donations, comments, updates on a popular campaign can reach thousands — must be separate, paginated collections), when data is shared across parents (a `User` referenced by many `Donations`), or when data has independent lifecycle/audit needs (all financial records — always referenced, never embedded, to preserve immutability and indexability).

---

## 17. Database Relationships

```text
User
 ├── Campaigns (organizerId)
 │    ├── Donations (campaignId)
 │    │    └── PaymentTransaction (paymentTransactionId)
 │    ├── Updates (campaignId)
 │    ├── Comments (campaignId)
 │    ├── CampaignMembers (co-organizers)
 │    └── Withdrawals (campaignId)
 ├── Donations (donorId)
 ├── Notifications (userId)
 ├── Reports (reporterId)
 └── Verifications (userId)

Beneficiary
 ├── Campaign (beneficiaryId)
 └── PayoutAccount (payoutAccountId)
```

Every financial reference (`Donation → PaymentTransaction`, `Withdrawal → PaymentTransaction`) is one-directional and immutable once confirmed — the campaign's `raisedAmount` is a derived, recomputable field, never the source of truth (the source of truth is the sum of confirmed `PaymentTransactions`).

---

## 18. API Specification (Representative)

Base: `/api/v1`

| Endpoint | Method | Auth | Purpose |
|---|---|---|---|
| `/auth/register` | POST | Public | Create account |
| `/auth/login` | POST | Public | Get access+refresh tokens |
| `/auth/refresh` | POST | Refresh token | Rotate access token |
| `/auth/verify-otp` | POST | Public | Confirm phone OTP |
| `/users/me` | GET/PATCH | User | View/update own profile |
| `/campaigns` | GET | Public | List/search/filter campaigns |
| `/campaigns` | POST | Organizer | Create campaign (draft) |
| `/campaigns/:id` | GET | Public | Campaign detail |
| `/campaigns/:id` | PATCH | Organizer/Co-organizer | Edit campaign |
| `/campaigns/:id/submit` | POST | Organizer | Submit for review |
| `/campaigns/:id/publish` | POST | Admin | Publish approved campaign |
| `/campaigns/:id/donate` | POST | Donor or guest | Create donation + payment intent |
| `/campaigns/:id/updates` | GET/POST | Public read / Organizer write | Campaign updates |
| `/campaigns/:id/comments` | GET/POST | Public read / Donor write | Comments |
| `/payments/webhook/:provider` | POST | Provider signature | Payment confirmation |
| `/withdrawals` | POST | Organizer/Beneficiary | Request payout |
| `/withdrawals/:id/review` | PATCH | Admin | Approve/reject |
| `/reports` | POST | Authenticated user | Report campaign/user |
| `/admin/campaigns/:id/review` | PATCH | Admin/Moderator | Approve/reject/suspend |
| `/admin/fraud-cases` | GET | Admin | Fraud queue |
| `/notifications` | GET | User | List own notifications |

Every write endpoint requires: authentication (JWT), authorization (role/ownership check), input validation (schema-based, e.g. Zod/Joi), and returns standardized error shapes:
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "...", "fields": {} } }
```

---

## 19. Authentication & Authorization

- **JWT-based:** short-lived access token (~15 min) + long-lived refresh token (rotated on use, stored httpOnly secure cookie for web / secure storage for mobile).
- Password hashing: bcrypt/argon2, never reversible.
- Email verification via signed time-limited link; phone verification via OTP (rate-limited, expiring).
- Password reset: signed token, single-use, short expiry, invalidates active sessions on completion.
- **RBAC** for coarse role checks (`isAdmin`, `isOrganizer`) plus **permission-based** checks for fine-grained ownership rules (e.g. "can this user edit *this specific* campaign" — organizer or accepted co-organizer only).
- Device/session management: list active sessions, allow remote logout, refresh token invalidation on password change.

---

## 20. Security Architecture

HTTPS everywhere (HSTS enforced) · bcrypt/argon2 password hashing · short-lived signed JWTs with rotation · per-IP and per-account rate limiting on auth and donation endpoints · strict input validation on every endpoint (schema validation before any DB write) · Mongoose parameterized queries (no raw query injection) · output encoding + CSP headers against XSS · CSRF tokens on cookie-based web sessions · locked-down CORS allowlist (web + native mobile app origins only) · secure, httpOnly, sameSite cookies for refresh tokens · file upload validation (type/size allowlist, virus scan where feasible, stored outside web root, served via signed URLs) · webhook signature verification on every payment provider callback + replay protection via idempotency keys · encryption at rest for sensitive fields (ID documents, payout account numbers — masked in UI) · secrets in environment/secret manager, never in source control · structured audit logging of all admin and financial actions · brute-force protection (progressive lockout + CAPTCHA after repeated failures) · account takeover protection (notify on new device login, allow session revocation).

---

## 21. Fraud Prevention

**Signals monitored:** new account age, suspicious campaign content patterns, unusual donation velocity, multiple accounts from same device/IP, device fingerprinting, IP reputation, sudden fundraising spikes inconsistent with campaign history, mismatched beneficiary identity documents, repeated failed payment attempts.

```text
Risk Score: LOW → MEDIUM → HIGH → CRITICAL
```

| Score | System Action |
|---|---|
| LOW | Allow — normal automated flow |
| MEDIUM | Review — flagged for moderator queue, campaign stays live |
| HIGH | Freeze — campaign/withdrawal paused pending manual review |
| CRITICAL | Reject — campaign taken down, account flagged, admin notified immediately |

Fraud scoring runs at campaign submission, at each donation above a threshold, and at every withdrawal request — not just once at onboarding.

---

## 22. Verification System

```text
Email Verified → Phone Verified → Identity Verified → Beneficiary Verified
→ Payment Verified → Organization Verified
```

Displayed as badges on campaign cards/detail pages, e.g.:
```text
✓ Identity Verified   ✓ Beneficiary Verified   ✓ Payment Verified
```
Higher verification tiers unlock higher donation/withdrawal limits and "Featured" eligibility — verification is both a trust signal *and* a risk-control lever.

---

## 23. Notifications

**Events:** campaign approved/rejected, new donation, goal reached, new update, withdrawal approved/completed, payment failed, account security alert, new comment.

**Channels:** Email, SMS, Push (future), In-app.

**MVP:** In-app + Email for all events; SMS for the highest-urgency ones only (payment confirmation, withdrawal completed, security alerts) to control SMS cost.

---

## 24. Admin Dashboard (Web Only)

**KPIs:** total users, active campaigns, total donations, total volume, pending withdrawals, open fraud cases, open reports, verification queue size.

**Moderation:** review/approve/reject/suspend/freeze/restore campaigns, with mandatory reason codes on every reject/suspend action (feeds analytics on why campaigns fail review).

**User management:** search, view profile + activity history, suspend, ban, manually verify, review linked campaigns/donations.

**Financial management:** payments ledger, donations ledger, withdrawals queue, fee configuration, refunds, failed transaction investigation view.

---

## 25. Analytics

**Organizer:** views, donations, conversion rate, total raised, average donation, donor count, referral source breakdown (which share channel drove donations — important for WhatsApp-heavy sharing behavior).

**Admin:** GMV/total volume, platform revenue, active users (DAU/MAU), campaign success rate, donation conversion rate, fraud rate, average withdrawal processing time, payment success rate by provider.

---

## 26. Business Model

| Model | Description | Fit for Somalia-first MVP |
|---|---|---|
| Transaction fee (%) | Small % taken from each donation | Strong — transparent, scales with usage, standard model donors understand |
| Platform fee (flat) | Fixed fee per donation | Weaker — disproportionately hurts small donations, common in Somali giving |
| Optional donor tip | Donor chooses to add a tip to support platform | Good supplementary model, not sufficient alone at launch |
| Premium campaigns | Paid boosted visibility | Post-MVP — organizers unlikely to pay before trusting the platform |
| Organization accounts | Subscription for NGOs/mosques/schools | Post-MVP, once institutional trust is established |
| Featured campaigns | Paid placement | Post-MVP |

**Recommendation:** A low, transparent **transaction fee (e.g. 3–5%)** shown clearly at checkout, plus an **optional donor tip** to offset platform costs — mirrors GoFundMe's model but keeps the core fee low to respect Somali sensitivity around "who profits from a family's emergency."

**Example calculation:** $10,000 raised on a campaign, 4% platform fee = $400 platform revenue, $9,600 net to beneficiary (before payment processing costs, which should be itemized separately once real provider fees are confirmed).

---

## 27. Legal & Compliance Considerations

*This is not legal advice — it flags what the project must account for, not how to satisfy it. Formal legal review is required before handling real funds.*

**Technical requirements:** KYC data capture fields for organizers/beneficiaries, AML-style transaction monitoring hooks (velocity/threshold flags), immutable audit trail, data export/erasure support for privacy requests, configurable donation limits pending compliance review.

**Legal requirements (need qualified legal counsel):** applicable payment/money-transfer regulations in Somalia and any diaspora jurisdictions served, data privacy obligations, terms of service and privacy policy drafting, refund/dispute policy, tax treatment of donations, NGO/charity registration requirements for institutional beneficiaries, statutory record-keeping periods for financial transactions.

---

## 28. MVP Definition

**Must Have:** Auth (email+phone), campaign create/submit/review/publish, donation flow with at least one working payment method, campaign detail page with story/media/progress, basic verification (identity + beneficiary), withdrawal request + admin approval, admin dashboard (users, campaigns, payments, withdrawals, moderation), Somali+English UI, updates + comments, in-app + email notifications.

**Should Have:** Multiple payment providers, follow/bookmark, referral tracking, basic fraud risk scoring, SMS notifications for critical events, campaign analytics for organizers.

**Nice to Have:** Featured/trending algorithms, organization accounts, premium placements, advanced fraud ML scoring.

**Not in MVP:** Multi-currency beyond USD/SOS display, Arabic/RTL, recurring donations, in-app messaging between donor/organizer, public API for third parties.

```text
MVP v1   → Core flow above, single payment provider, manual-heavy admin review
MVP v1.1 → Second payment provider, SMS notifications, basic analytics
MVP v2   → Fraud scoring automation, organization accounts
```

---

## 29. MVP User Flow

```text
Register → Create Campaign → Submit → Admin Approves → Publish → Share
→ Donor Opens Campaign → Donate → Payment Gateway → Webhook
→ Donation Confirmed → Campaign Balance Updated → Organizer Dashboard
→ Withdrawal Request → Admin Review → Payout
```

---

## 30. Development Roadmap

| Phase | Goal | Key Work |
|---|---|---|
| 1. Planning | Lock scope | Requirements, architecture, wireframes, DB design, API design |
| 2. Project Setup | Dev-ready repo | Git repo structure, MERN scaffolding, env config, CI/CD pipeline |
| 3. Authentication | Secure accounts | Register/login, JWT, email+phone verification |
| 4. User Profiles | Identity layer | Profile CRUD, role assignment |
| 5. Campaign System | Core CRUD | Create/edit/submit/lifecycle state machine |
| 6. Public Campaign Pages | Discovery | Explore, search, filters, campaign detail |
| 7. Donation System | Give money | Donation flow, receipts, donor history |
| 8. Payment Integration | Real money | Provider adapter(s), webhooks, idempotency |
| 9. Withdrawal System | Payout | Request → review → payout flow |
| 10. Admin Dashboard | Operate platform | Moderation, financial oversight, user mgmt |
| 11. Trust & Safety | Reduce fraud | Verification, reporting, risk scoring |
| 12. Notifications | Keep users informed | Email + in-app, SMS for critical events |
| 13. Mobile App | Reach & convenience | responsive web application for donor/organizer/beneficiary roles |
| 14. Testing | Confidence | Unit/integration/E2E, payment/webhook testing |
| 14. Deployment | Ship it | Production infra, monitoring, beta rollout |

Each phase's **Definition of Done** = feature works end-to-end on staging, covered by tests, reviewed, and documented — not just "code written."

---

## 31. Testing Strategy

Unit tests (services, validators, fee calculations) · Integration tests (API endpoints against a test DB) · Payment tests (mocked provider responses for success/failure/timeout/duplicate-webhook scenarios — critical to test idempotency explicitly) · Webhook tests (signature verification, replay protection) · Auth/authorization tests (role and ownership boundary checks, including negative tests — e.g. co-organizer cannot withdraw) · Security tests (injection, XSS, rate-limit enforcement) · E2E tests (full donor and organizer journeys via Playwright/Cypress) · Mobile tests (widget tests + key flow integration tests in Flutter).

Payment testing deserves special weight: simulate delayed mobile money confirmation, duplicate webhook delivery, and partial failure (payment succeeds at provider but webhook never arrives) — the system must reconcile via a periodic status-check job, not rely on webhooks alone.

---

## 32. Deployment Architecture

**MVP deployment:**
```text
Users → Responsive React Web Frontend (static hosting/CDN) → API (single Node.js instance, containerized)
→ MongoDB (managed, e.g. Atlas) 
Payment Gateway → Webhook → Backend
Object Storage (media) · Email/SMS providers
```

**Production scale architecture:**
```text
Users → CDN → Frontend → API Load Balancer → Node.js instances (horizontally scaled)
→ MongoDB (replica set/sharded) 
                 ↕
     Redis (cache, queues, rate limiting)
     Background job workers (webhook processing, notifications)
Payment Gateway → Webhook → Backend (idempotent handler)
Object Storage + CDN · Email · SMS · Push · Monitoring/Logging
```

---

## 33. Scalability

| Users | What changes |
|---|---|
| 1,000 | Single API instance + managed MongoDB fine; no caching needed yet |
| 10,000 | Add indexes review, basic Redis caching for hot campaign pages, CDN for media |
| 100,000 | Horizontal API scaling behind load balancer, background job queue for notifications/webhooks, read replicas for MongoDB, rate limiting becomes essential |
| 1,000,000+ | Database sharding strategy, multi-region CDN, dedicated payment-processing service, full observability stack, likely split monolith into payments/campaigns/notifications services |

Ongoing regardless of scale: proper compound indexes on `campaignId`, `status`, `createdAt` fields; image optimization/resizing pipeline; background jobs for anything not required synchronously (emails, SMS, non-critical notifications).

---

## 34. Project Folder Structure

```text
server/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── services/        # PaymentService, FraudService, etc.
│   ├── models/          # Mongoose schemas
│   ├── routes/
│   ├── middleware/      # auth, rbac, rateLimit, errorHandler
│   ├── validators/
│   ├── utils/
│   ├── jobs/             # background/cron
│   ├── integrations/     # payment provider adapters, SMS, email
│   └── app.ts

client/
├── src/
│   ├── components/
│   ├── pages/
│   ├── features/         # feature-sliced: campaigns/, donations/, admin/
│   ├── hooks/
│   ├── services/         # API clients
│   ├── store/
│   ├── utils/
│   └── App.tsx

```

Keeping `features/` organized by domain (campaigns, donations, admin, auth) makes it easier for one person or a small team to maintain the web codebase.

---

## 35. Real-World Scenarios

| # | Scenario | Organizer | Beneficiary | Goal | Payment | Verification | Withdrawal |
|---|---|---|---|---|---|---|---|
| 1 | Medical — cancer treatment | Family member | Patient | $8,000 | Mobile money + card (diaspora) | Identity + medical doc | Staged, as treatment progresses |
| 2 | Education — university fees | Student or parent | Student | $2,500 | Mobile money | Identity + admission letter | Lump sum to school account |
| 3 | Emergency — house fire | Community leader | Family | $3,000 | Mobile money | Identity + incident report | Fast-tracked, urgent review |
| 4 | Community — well | Village committee | Community org | $6,000 | Bank + mobile money | Organization verification | Milestone-based |
| 5 | School — computer lab | Headmaster | School | $5,000 | Bank | Organization verification | Lump sum |
| 6 | Funeral — burial costs | Family member | Family | $1,000 | Mobile money | Identity, expedited review | Immediate on approval |
| 7 | Diaspora-led disaster relief | Diaspora organizer | Affected community | $15,000 | Card + mobile money | Organization + identity | Staged distribution |
| 8 | Mosque renovation | Committee member | Mosque | $10,000 | Bank + mobile money | Organization verification | Milestone-based |
| 9 | Orphan support (ongoing) | NGO organizer | Orphan/guardian | $4,000/yr | Card + mobile money | Organization + beneficiary | Recurring (post-MVP) |
| 10 | Small business restart | Individual | Self | $1,500 | Mobile money | Identity verification | Lump sum |

---

## 36. Product Differentiation

| Feature | Impact | Difficulty | Cost | MVP Priority |
|---|---|---|---|---|
| Mobile money as primary payment | High | Medium | Medium | Must Have |
| Somali/English bilingual UX | High | Low | Low | Must Have |
| Beneficiary verification badges | High | Medium | Low | Must Have |
| Organizer identity transparency | High | Low | Low | Must Have |
| Low-bandwidth optimized UI | Medium | Low | Low | Must Have |
| Diaspora-friendly card checkout | High | Medium | Medium | Should Have |
| Community/mosque/school campaign types | Medium | Low | Low | Must Have |
| WhatsApp-optimized share cards | High | Low | Low | Should Have |
| Transparent fund-usage updates | High | Low | Low | Must Have |
| Region-based discovery | Medium | Medium | Low | Should Have |
| Elder/community vouching system | Medium | High | Medium | Nice to Have |
| Organization accounts (NGOs) | Medium | Medium | Medium | Nice to Have |
| Recurring giving (sadaqah-style) | Medium | High | Medium | Nice to Have |
| Milestone-based fund release | Medium | High | Medium | Nice to Have |
| SMS-first notifications | Medium | Low | Medium (SMS cost) | Should Have |

---

## 37. Success Metrics / KPIs

**North Star Metric:** Total verified donation volume successfully disbursed to beneficiaries.

- **Acquisition:** new organizer signups, new donor signups, traffic by channel (WhatsApp share is likely dominant).
- **Activation:** % of organizers who complete campaign submission, % of donors who complete first donation.
- **Engagement:** returning donor rate, updates posted per campaign, comments/likes per campaign.
- **Donation:** conversion rate (viewers → donors), average donation size, donation completion rate by payment method.
- **Retention:** repeat donor rate, repeat organizer rate.
- **Trust:** % of campaigns verified before first donation, report rate, fraud rate.
- **Financial:** total volume, platform revenue, average withdrawal processing time, payment success rate.

---

## 38. Risks

| Risk | Impact | Probability | Mitigation |
|---|---|---|---|
| Fraud (fake campaigns/beneficiaries) | High | High | Verification tiers, risk scoring, community reporting |
| Payment provider failure/instability | High | Medium | Multi-provider abstraction layer, reconciliation jobs |
| Low donor trust at launch | High | High | Visible verification, transparent updates, small early success stories |
| Fake or duplicate campaigns | High | High | Manual review at MVP, escalate to automated detection later |
| Regulatory/compliance gaps | High | Medium | Early legal consultation, conservative KYC/AML posture |
| Low organizer adoption | High | Medium | Community partnerships (mosques, diaspora associations), referral incentives |
| SMS/mobile money provider reachability gaps | Medium | Medium | Verify provider coverage before committing, keep manual/admin-recorded fallback |
| Connectivity issues causing failed donations | Medium | High | Idempotent payment flow, clear retry UX, draft autosave |
| Diaspora payment friction (card declines, currency confusion) | Medium | Medium | Clear USD pricing, multiple card processor fallback |
| Data privacy incident (ID documents leaked) | High | Low | Encryption at rest, access-controlled document storage, minimal retention policy |

---

## 39. Kaalmo vs GoFundMe

| Area | GoFundMe | Kaalmo (Somalia Platform) |
|---|---|---|
| Target market | Global, broad | Somalia-first, diaspora-connected |
| Language | English (+ some localization) | Somali + English by design |
| Payments | Cards, PayPal | Mobile money-first, plus bank and card |
| Trust model | Platform-level verification, tipping | Community-aware verification badges, organizer transparency |
| Mobile | App available | Web + Mobile App (feature parity for core roles) |
| Admin | Internal, not user-facing | Web-only admin dashboard, no mobile admin |
| Campaign categories | General life events, broad | Somalia-relevant categories (mosque, funeral, community wells, diaspora relief) as first-class types |
| Connectivity assumptions | Assumes reliable broadband | Designed for low-bandwidth, mobile-data-constrained use |

Kaalmo is not a clone — it borrows the *proven mechanics* of crowdfunding (campaign → story → donate → update) but rebuilds the *trust and payment layer* around Somali realities.

---

## 40. Final Product Blueprint

```text
PRODUCT: Somalia-first trusted fundraising platform
↓
USERS: Donor, Organizer, Beneficiary, Co-organizer, Admin, Moderator, Support
↓
FEATURES: Campaign lifecycle, donations, updates, verification, withdrawals, moderation
↓
UX: Bilingual, low-bandwidth, trust-signal-forward
↓
FRONTEND: React (web) + Flutter (mobile)
↓
BACKEND: Node.js + Express, shared REST API
↓
DATABASE: MongoDB, immutable financial ledger design
↓
PAYMENTS: Abstracted multi-provider layer, mobile-money-first
↓
SECURITY: JWT auth, RBAC, encrypted sensitive data, audit logging
↓
TRUST & SAFETY: Tiered verification, risk scoring, reporting, moderation queue
↓
ADMIN: Web-only dashboard for full platform oversight
↓
MOBILE: Full parity for donor/organizer/beneficiary/co-organizer roles
↓
TESTING: Unit, integration, payment/webhook, E2E, mobile
↓
DEPLOYMENT: Containerized MVP → horizontally scaled production
↓
GROWTH: Somalia → diaspora hubs → East Africa
```

### Recommended MVP Scope
Auth + verification (email, phone, identity, beneficiary) → campaign create/review/publish lifecycle → single working payment provider (mobile money) with donation + receipt flow → withdrawal request + admin approval → web admin dashboard covering moderation, users, payments, withdrawals → Somali/English UI → basic in-app + email notifications → Responsive React web app covering donor, organizer, beneficiary, and co-organizer core flows.

### Step-by-Step Development Plan
1. Finalize DB schema and API contract (this document → OpenAPI spec).
2. Scaffold repos (server, client, mobile) with CI from day one.
3. Build auth + verification end-to-end before anything else — everything depends on it.
4. Build campaign CRUD + lifecycle state machine with admin review screens in parallel.
5. Integrate one payment provider fully (intent → webhook → confirmation → ledger) before adding a second.
6. Build donation flow + campaign detail page on top of the working payment integration.
7. Build withdrawal flow, reusing the payment abstraction layer.
8. Build admin dashboard last-mile (moderation queue, fraud flags, financial views).
9. Add updates/comments/notifications.
10. Optimize and harden the responsive web application once the web API is stable.
11. Run full payment/webhook/security test pass before any real-money beta.
12. Closed beta with a small set of real, verified campaigns before public launch.

### Definition of Done — MVP Beta-Ready
- A real user can register, get verified, create and submit a campaign, get it approved, and publish it.
- A donor can donate real money via at least one payment method and receive a confirmed receipt.
- Campaign balance updates correctly and reconciles with the payment ledger (no drift between `raisedAmount` and confirmed `PaymentTransactions`).
- A beneficiary can be verified and a withdrawal can be requested, reviewed, and paid out successfully.
- Admin can moderate campaigns, view financials, and handle a reported campaign end-to-end.
- Core security controls are in place: HTTPS, hashed passwords, rate limiting, webhook signature verification, input validation on all endpoints.
- Somali and English UI both work across all core screens.
- Automated tests cover auth, campaign lifecycle, donation flow, and payment webhook handling.

---

*Note: local payment provider names, exact fees, KYC/AML requirements, and SMS gateway coverage in Somalia should be verified against current, authoritative sources before implementation — these change and were intentionally not assumed in this specification.*
