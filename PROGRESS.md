# Kaalmo — Horumarka Mashruuca (Progress Tracker)

> La cusboonaysiiyay: 2026-08-29 (dhinac saddex-iyo-tobnaad)
> Tani waa faylka lagu raad-raaco waxa la dhisay, waxa socda, iyo waxa weli ku dhiman marka loo eego `kaalmo-web-only-spec.md` iyo `Design_Rules.md`.

---

## 1. Guud ahaan xaaladda hadda

| Qayb | Xaalad |
|---|---|
| **Backend (server/)** | 🟢 MVP-core + trust/moderation + social features (Follow/Save/Reports/Team/Notifications) + **EVC Plus (WaafiPay) dhab ah** waa dhammaystiran |
| **Frontend (client/)** | 🟢 Bogagga oo dhan ee la qorsheeyay waa la dhisay oo dhab ah ula xiran yihiin backend-ka; **i18n dhab ah — dhammaan 39 bog + shared components (StatusPill/VerificationBadge/ProgressBar/ImageUpload/DashboardLayout nav) waa la buuxiyay** |
| **Admin Dashboard** | 🟢 Dhammaan qaybaha — Overview, Campaigns, Verification Queue, Users, Reports, **Fraud & Risk (rule-based dhab ah)**, **Support Tickets (dhab ah)**, Audit Logs — waa la dhammaystiray, ma jiro sample data hadhay |
| **Payment Providers** | 🟢 **EVC Plus (Hormuud, WaafiPay gateway) — dhab ah, USSD push**; donations waa la iska xaqiijiyaa (auto-confirm), admin approval lama baahna |
| **Deployment** | 🔴 Wali lama bilaabin |

## 0g. Somali/English i18n — dhammaystiran (2026-08-29, dhinac saddex-iyo-tobnaad → afar-iyo-tobnaad)

**Codsi:** "implement i18n and make the navbar like 2 flag of drop-down" → kadibna "some content are still english" → "Dhammaan mid mar ahaan" (dhammaan bogagga hal mar).

- ✅ `client/src/context/LanguageContext.jsx` — `language` state ('so'/'en'), `t(key)` translation function, `setLanguage()`. Guest: keydiya `localStorage`. User la galay: si toos ah ayuu ugu qoraa `PATCH /users/me { language }` (backend-ku horay ayuu u diyaar ahaa)
- ✅ `client/src/i18n/translations.js` — qaamuus fure-based ah oo ~250 fure ka badan leh, Soomaali iyo Ingiriisi labaduba dhab ah (af dabiici ah, ma aha turjumaad tooska ah — Rule 34/35). Waxaa sidoo kale ku jira `categoryLabel()`/`regionLabel()` helper si loo turjumo qiimaha DB-ga (Campaign.category/region) iyada oo aan la beddelin qiimaha la keydiyay
- ✅ **Baaxadda hadda — DHAMMAAN 39 bog** (Home, Explore, CampaignDetail, HowItWorks, Safety, HelpCenter, Legal, Contact, Login, Register, CheckEmail, Donor Dashboard/Donate/DonationConfirmed/Saved/Followed/Notifications/Settings, Organizer Dashboard/Analytics/Team/Withdrawals/EditCampaign/wizard-ka 3-tallaabo/Invites/Onboard, Beneficiary Verification, Support MyTickets, iyo dhammaan 9-da bog ee Admin) + shared components (`StatusPill`, `VerificationBadge`, `ProgressBar`, `ImageUpload`, `DashboardLayout` sidebar nav) — dhammaan si buuxda ayaa loogu xiray `t()`
- ✅ Navbar language control — laga beddelay qoraal "Somali | English" una beddelay **dropdown laba calan ah** (🇸🇴 Soomaali / 🇬🇧 English), la taaban karo si fudud, calaanka la doortay wuxuu leeyahay check-mark
- ✅ Settings page (`/donor/settings`) waxaa lagu daray doorasho luqad oo la mid ah (fori isla dabaqa, kama sugayo "Save changes")
- ✅ La tijaabiyay end-to-end browser dhab ah: Home, Explore (categories + regions + campaign cards), Login, Admin Overview oo dhan — dhammaan si sax ah ayay ugu beddelmeen Soomaali, dib u load garayn wuu sii ahaa, server-ka `User.language` ayaa la xaqiijiyay
- ✅ `npx vite build` — production build guulaystay, ma jirin syntax error 39-ka bog ee la wax ka beddelay
- **Meelo aan la turjumin (documented gap)**: qoraalka la-abuuray server-ka (Notification.title/body, fraud signal-yada `subject`/`signal` strings) weli waa Ingiriisi tooska ah — turjumaaddoodu waxay u baahan tahay isbeddel backend ah (template bilingual ah), ma aha wax laga qaban karo frontend kaliya
- Fiiro celin dheeraad ah: waxaa sidoo kale la saxay bug hore u jiray — mobile-ka hero title-ku wuxuu ahaa 82px (ka weyn desktop-ka 68px), taasoo sababtay overflow — hadda waa 32px/48px sax ah

## 0f. Admin features — Fraud & Risk + Support Tickets (2026-08-29, dhinac laba-iyo-tobnaad)

**Codsi:** "implement all the admin features remained make all the features live" — labadii qayb ee kaliya sample data ahaa (Fraud & Risk, Support Tickets) hadda dhab ayay noqdeen.

### Support Tickets — dhab ah, u dhammaystiran
- ✅ `SupportTicket` model (subject/message/status/replies thread), `POST /support-tickets` (public — guest ama user), `GET/POST /support-tickets/mine[/:id/replies]` (donor/organizer-side), `GET/POST/PATCH /admin/support-tickets` (admin list/reply/status)
- ✅ **Contact page** (`/contact`) hadda dhab ahaan ticket ayay abuuraysaa (horay waxay ahayd fake "message received" oo aan xogta keydin) — guest (magac+email) ama user (xiriirsan account-kooda)
- ✅ Bog cusub — **`/support`** (donor/organizer-ku halkan ayuu ka arki karaa ticket-yadiisa, thread-ka oo dhan, jawaab ka celin) — waxaa lagu daray DONOR_NAV iyo ORGANIZER_NAV
- ✅ Admin Support Tickets page — filter status (open/in_progress/resolved/closed), expand thread, jawaab celin, status beddelid — la tijaabiyay end-to-end browser dhab ah
- ✅ Admin Overview KPI cusub: "Open support tickets"

### Fraud & Risk — signal-yo dhab ah, rule-based (ma aha ML)
- ✅ `server/src/services/fraudService.js` — saddex signal oo xogta dhabta ah lagu xisaabiyo mar kasta oo la soo dalbado (`GET /admin/fraud-signals`), ma keydiyo xaalad "dismissed" (signal-ku wuxuu iska baxaa marka pattern-ku joogsado):
  1. **Donation velocity** — campaign helay ≥5 donation oo la xaqiijiyay hal saac gudahood
  2. **New account + high goal** — account cusub (<48 saac) oo sameeyay campaign goal-kiisu ≥$2,000
  3. **Repeat donor** — donor isku mid ah oo ≥4 jeer isla campaign-ka ku deeqay 24 saac gudahood
- ✅ Admin Fraud & Risk page — signal kasta wuxuu leeyahay link "Review" oo kuu geeya campaign-ka/user-ka dhabta ah (horay "Review" button-ku disabled ayuu ahaa)
- ✅ La tijaabiyay dhab ahaan: 6 donation oo degdeg ah la sameeyay → velocity signal si sax ah ayuu u soo baxay

## 0e. Feature cusub (2026-08-28, dhinac kow-iyo-tobnaad)

**Codsi:** "Campaign walba donation-yadii ugu dambeeyay + tirada qofka ka qeyb qaatay la muujiyo. Mida kale: haddii 1000 qof donation sameeyaan, admin-ku mid-mid u aqbalidoodu way adag tahay — xal keen."

### 1. Campaign Detail — "Recent donations" + supporter count
- ✅ **`GET /campaigns/:id/donations`** (public) — soo celisa 10-kii donation ee ugu dambeeyay (confirmed kaliya) + `supporterCount` (tirada donation-yada la xaqiijiyay). Magaca donor-ka anonymous ah lama muujiyo (waa la ilaaliyaa ballan-qaadkii donation-ka lagu siiyay)
- ✅ Campaign Detail page: qeyb cusub "Recent donations (N)" oo tusaysa magaca/Anonymous, message-ka, lacagta, taariikhda — iyo "N supporters" oo ku dhow progress bar-ka
- La tijaabiyay browser dhab ah: donation cusub → admin confirm → campaign page-ku isla markiiba wuxuu tusayaa "$50 · Barakat iyo caafimaad! · 1 supporter"

### 2. Admin Donations — Bulk confirm (xalka dhibaatada 1000 donation)
- ✅ **`POST /admin/payments/confirm-batch`** — aqbal liis `paymentIds`, mid kasta si madax-banaan ayaa loo xaqiijiyaa (mid fashilma kuwa kale kuma xanibo), `raisedAmount` campaign kasta oo saameeyay hal mar ayaa la dib-xisaabiyaa
- ✅ Admin Donations page: checkbox kasta oo saf ah + "select all" header-ka, bar cusub oo muujisa "N selected" + "Confirm N selected", modal xaqiijin ah, natiijo cad (X confirmed / Y failed oo error-yada la muujiyo)
- Hadda admin-ku wuxuu dooran karaa 50-100 donation hal mar (page kasta), waxaana loo baahan yahay dhowr click oo kaliya halkii uu 1000 modal kala qaadi lahaa
- La tijaabiyay end-to-end (curl + browser): 3 donation oo hal mar la xaqiijiyay, `confirmedCount:3, failedCount:0`

### Fiiro celin: Talo mustaqbal ah
Marka la helo real payment provider (EVC Plus/eDahab), habka "manual confirm" (mid-mid ama batch) wuu iska baabi'i doonaa — webhook-yada provider-ku si otomaatig ah ayay u xaqiijin doonaan donation-yada, iyada oo aan admin toos ahaan loo baahnayn. Ilaa markaas, bulk-confirm-ku waa xalka ugu wanaagsan ee available-ka ah scale-ka sare.

## 0d. Bug muhiim ah — la xaliyay (2026-08-28, dhinac tobnaad)

**Calaamad:** Donation-yadu "pending" ayay ku sii xiran yihiin — user-ku wuxuu weydiiyay yaa xaqiijinaya donation-ka, halka admin-ku uu ka xaqiijinayo, oo sheegay "sidaas uma eka mid sax ah."

**Sababta run ah:** `POST /admin/payments/:paymentId/confirm` endpoint-ku backend-ka wuu jiray oo la tijaabiyay curl kaliya — laakiin **ma jirin bog frontend ah** oo admin-ku ku arki karo donation-yada pending-ka ah! Habka kaliya ee la confirm gareyn karay wuxuu ahaa API call toos ah.

**Xalka:**
- ✅ **`GET /admin/donations`** — endpoint cusub (filter by status: pending/confirmed/failed/refunded), populate campaign+donor+payment
- ✅ **Bog cusub — Admin > Donations** (`/admin/donations`) — table leh Date/Campaign/Donor/Amount/Method/Status/Action, tabs status-ka, modal xaqiijin ah oo tusaya amount+campaign+donor ka hor "Confirm payment" (Design_Rules.md Rule 15/16 — financial confirmation)
- ✅ Admin Overview KPI cusub: "Donations awaiting confirmation" oo isku xiran bogga cusub
- ✅ **Bug kale oo la helay oo la xaliyay**: `seed.js` ma tirtirin jirin `Donation`/`Payment`/`Withdrawal`/`Follow`/etc marka la dib-seed-gareeyo — sidaas darteed test data qadiimi ah ayaa isugu ururi jiray (safaf "—" oo campaign tirtiran leh). Hadda seed-ku dhammaan collections-ka macaamilka/bulshada wuu tirtiraa
- La tijaabiyay end-to-end browser dhab ah: donation guest ah → admin donations page → confirm modal → xaqiijin → status wuxuu u gudbay "Confirmed" isla markiiba

## 0c. Bug muhiim ah — la xaliyay (2026-08-28, dhinac sagaalaad)

**Calaamad:** Organizer OTP-gu wuu guulaystay ("confirmed:true", roles-ka DB-gu wuu isbedelay), laakiin marka user-ku isku dayay inuu campaign abuuro, wuxuu helayay `"You do not have permission to perform this action"` — xitaa Navbar-ku wuxuu tusayay "Organizer dashboard".

**Sababta:** JWT access token-ku roles-ka wuxuu ku xardhan yahay **markii token-ku la sameeyay** (login/register time). Marka `confirmOrganizerAccess` uu DB-ga ku daro `organizer` role-ka, token-ka browser-ku sii haysto (oo la sameeyay ka hor) **weli wuxuu sii ahaa** `roles: ['donor']` — JWT-yadu ma isbedelaan iyaga laftooda. `requireRole('organizer')` wuxuu hubiyaa token-ka claim-kiisa, mana hubiyo DB-ga si toos ah, sidaas darteed diiday.

**Xalka:**
- `confirmOrganizerAccess()` hadda wuxuu soo celiyaa **`accessToken`/`refreshToken` cusub** (`issueTokens(user)`) marka role-ka la daro — isla habka `becomeOrganizer`-kii hore u lahaa (kaas oo OTP-gu bedelay)
- `AuthContext` waxaa lagu daray `applyTokens()` — wuxuu keydiyaa token-yada cusub `localStorage`, kadibna wuxuu cusboonaysiiyaa `user` state-ka
- `Onboard.jsx` hadda wuxuu isticmaalaa `applyTokens(data)` halkii uu isticmaali lahaa `refreshUser()` oo kaliya (taasoo GET /users/me kaliya samayn jirtay, token-ka aan beddelin)
- La tijaabiyay end-to-end (curl): token cusub → campaign abuur **guulaystay**; token hore → sii **fashilmay** sida la filayay (stale claim)

## 0b. Cusboonaysiinta ugu dambeysay (2026-08-28, dhinac siddeedaad)

**Codsi:** "Marka user-ku organizer rabo inuu noqdo, email-ka la diray sidoo kale OTP ka dhig."

- ✅ **Organizer confirmation — laga beddelay link una beddelay 6-digit OTP code** (isku qaab email verification-ka)
  - `requestOrganizerAccess()` hadda wuxuu soo saaraa OTP code (15 daqiiqo expiry) halkii uu token URL soo saari lahaa
  - **`POST /users/me/confirm-organizer-access`** (`requireAuth`, `{code}`) halkii uu ahaan lahaa `GET /users/organizer-access/confirm/:token`
  - `/organizer/confirm` page-kii hore (link-based) waa la tirtiray — `OrganizerConfirm.jsx` waa la saaray
  - `/organizer/onboard` — ka dib marka form-ka (magaca + ujeeddada) la gudbiyo, isla boggaas ayaa hadda ku muuqda **OTP input form** (isku qaab `/check-email`) — marka code-ku sax noqdo, `refreshUser()` + si toos ah ayaa loogu gudbiyaa `/organizer/new/basics`
  - La tijaabiyay end-to-end (curl): request → code qaldan → `INVALID_CODE` → code sax ah → `confirmed:true` → roles-ka user-ku hadda waa `['donor','organizer']`

## 0a. Cusboonaysiinta ugu dambeysay (2026-08-28, dhinac todobaad)

**Codsi:** "Email verification hadda ka dhig mid OTP ah, ma ahan link — user-ka bog u geli input-ka geli karo."

- ✅ **Email verification — laga beddelay link una beddelay 6-digit OTP code**
  - `register()` iyo `resendVerificationEmail()` hadda waxay soo saaraan **lambar 6-god ah** (`generateOtp()`, 15 daqiiqo expiry) halkii ay token URL soo saari lahaayeen
  - Email-ka wuxuu hadda tusayaa lambarka si cad (font weyn), ma ahan link la riixi karo
  - **`POST /auth/verify-email-otp`** (`requireAuth`, body `{code}`) — halkii uu ahaan lahaa `GET /auth/verify-email/:token` (public link-consumption)
  - **`/verify-email` page-kii hore (link-based) waa la tirtiray** — `VerifyEmail.jsx` file-ka waa la saaray, route-ka App.jsx-ka
  - **`/check-email` page-ka hadda waa OTP entry form** — 6-god input (auto-format numbers-only), "Verify email" button, "Resend" link — dhammaan hal bog, isla markaana marka code-ku saxsanaado, `refreshUser()` ayaa loo yeeraa oo user-ku si toos ah ugu gudbaa app-ka (ma jiro link click ama tab kale)
  - La tijaabiyay end-to-end (curl + browser dhab ah): wrong code → `INVALID_CODE`, saxda ah → `verified:true`, re-verify (idempotent) → guul, resend → code cusub

## 0. Cusboonaysiinta ugu dambeysay (2026-08-28, dhinac lixaad)

**Codsi:** "frontend howlha dhiman dhameystir, logada ii badal isticmal logo.png, backend wixii la qaban karo ka qabo, payments gadaal u dhig, ha implement gareynin." (i18n-ka waxaa dib loo dhigay codsi kale oo dambe.)

### Logo
- ✅ `logo.png` (aad soo dirtay) waxaa lagu daray `client/public/logo.png`, `Logo.jsx` component cusub oo Navbar iyo Footer isku mid ah isticmaalaan
- Fiiro: adigu qudhaadu dib ayaad u beddeshay `Logo.jsx` (icon-ka size + magaca "Kaalmo" oo laga saaray) — waan sii wadnay isaga oo la taaban maayo

### Backend — feature cusub (payments lama taaban)
- ✅ **Reports** — `Report` model, `POST /reports` (user), `GET/PATCH /admin/reports` (admin review: reviewed/dismissed)
- ✅ **Follow/Save (bookmark) campaigns** — `Follow`/`Bookmark` models, toggle endpoints (`POST/DELETE /campaigns/:id/follow`, `/save`), `GET /campaigns/:id/interactions`, `GET /users/me/{followed,saved}-campaigns`
- ✅ **Co-organizer Team system** — `CampaignMember` model, invite-by-email (`POST /campaigns/:id/members`), list/remove, invitee-side accept flow (`GET/POST /campaign-invites/...`), email invite (Resend) + in-app notification. Co-organizers oo `accepted` ah hadda waxay heli karaan **edit + post-update** permissions campaign-ka (`canEditCampaign`/`isCampaignContributor` la cusboonaysiiyay)
- ✅ **In-app Notifications** — `Notification` model, `GET /notifications/mine`, mark-read/mark-all-read; waxaa la dhajiyay: campaign approve/reject/publish/suspend/restore, payment confirmed, beneficiary verified/rejected, withdrawal reviewed, account status change, team invite, campaign update posted (dhammaan followers-ka)

### Bug-yo la xaliyay (muhiim ah)
- ✅ **CampaignDetail crash on 401**: haddii `/interactions` (donor-specific) uu 401 noqdo, `Promise.all` ayaa xanibi jiray dhammaan xogta campaign-ka, isaga oo tusaya "Campaign not found" xitaa marka campaign-ku jiro dhab ahaantii. Hadda `interactions` si madax-banaan ayuu u dalbanayaa (fail-silent), campaign-ka core-kiisu marnaba kuma xirna
- ✅ **Ma jirin access-token auto-refresh**: access token-ku wuxuu dhacaa 15 daqiiqo — ka dib, API calls oo dhan 401 bay noqon jireen iyada oo aan lagu tijaabin refresh token-ka. Waxaan ku darray axios response interceptor (`client.js`) oo isku dayo `/auth/refresh` hal mar, dib u celiya codsiga; haddii refresh-kuna fashilmo, session-ka si sax ah ayaa loo tirtiraa (`kaalmo:session-expired` event → `AuthContext` state cusboonaysiin)

### Frontend — bogag cusub oo la dhisay
- ✅ Donor: **Saved campaigns**, **Followed campaigns**, **Notifications** (bell + list, mark-read), **Settings** (fullName edit)
- ✅ Organizer: **Team** (invite/list/remove co-organizers), **Invites** (qof kasta oo casuumaad helay wuu aqbali karaa)
- ✅ Admin: **Reports** (list open reports, mark reviewed/dismissed)
- ✅ Beneficiary Verification page: **ID document upload** hadda dhab ah (`ImageUpload` la xiray)
- ✅ Campaign Detail page: **Follow**, **Save**, **Report** (modal+form), **Share** (copy link) — dhammaan dhab ah
- ✅ Navbar: **notification bell** oo leh unread-count badge
- ✅ Organizer/Donor nav-yada waxaa loo beddelay shared `nav.js` files si loo yareeyo duplication-ka

### La dib-dhigay (user codsaday)
- ⏸️ **Somali/English i18n dhab ah** — waxaa la dib-dhigay codsi kale ("i18n dib u dhig, waxa kale qabo"). Navbar-ka waxaa lagu celiyay static text-kii hore (ma jiro `LanguageContext`)

---

## 2. Waxa la Dhammeeyay ✅ (cusub — 2026-08-28, dhinac shanaad)

### Organizer onboarding — email confirmation dhab ah (labo-tallaabo)
- ✅ **La beddelay batoon-kii "Continue as organizer" (hal click)** oo isla markiiba role-ka bixin jiray, waxaana lagu beddelay **labo-tallaabo oo email-ku xaqiijiyo**:
  1. `/organizer/onboard` — form (full name + "what are you raising money for") → `POST /users/me/request-organizer-access` — waxay **kaliya diraa email confirmation ah**, role-ka **ma bixiso**
  2. Email-ka gudihiisa link → `/organizer/confirm?token=...` → `GET /users/organizer-access/confirm/:token` — **kaliya halkan** ayaa role-ka `organizer` loo daraa user-ka
- ✅ Idempotent (sida email verification-ka), token 24h expiry, guard `ALREADY_ORGANIZER` haddii horeba organizer yahay, guard `EMAIL_NOT_VERIFIED` haddii account-ka aan la xaqiijin
- ✅ La tijaabiyay end-to-end (curl): request → role weli `['donor']` → confirm → role hadda `['donor','organizer']` → re-confirm idempotent → re-request `409 ALREADY_ORGANIZER`

## 2c. Waxa la Dhammeeyay ✅ (cusub — 2026-08-28, dhinac afraad)

### Organizer onboarding — xaqiijin cad ka hor role-ka (la beddelay 2c, eeg 2 kore)
- ✅ **La beddelay auto-onboard-kii hore** — hore, riixida "Start a fundraiser" si toos ah (iyada oo aan la sugin xaqiijin) ayay user-ka uga dhigi jirtay organizer isla markiiba (`useEffect` auto-run). Hadda `/organizer/onboard` waxay tusaysaa bog xaqiijin ah oo leh batoon "Continue as organizer" — role-ka **kuma dhaco** ilaa user-ku uu si cad u riixo. Haddii user-ku laabto isaga oo aan riixin, roles-kiisu wuu sii ahaan doonaa `['donor']`. La tijaabiyay browser dhab ah.

## 2b. Waxa la Dhammeeyay ✅ (cusub — 2026-08-28, dhinac saddexaad)

### Shuruudda organizer noqoshada
- ✅ **Email verification hadda waa shuruud** ka hor inta user-ku `become-organizer` sameyn karo — `POST /users/me/become-organizer` wuxuu soo celiyaa `403 EMAIL_NOT_VERIFIED` haddii aan la xaqiijin. Frontend-ku horeba wuu maareeyaa arrintan (login gate-ka `ProtectedRoute`), backend check-gan waa defense-in-depth. Go'aan la go'aamiyay: shuruud fudud (email kaliya) si loo yareeyo fake accounts, iyada oo aan lagu darin culeys dheeraad ah user-ka.

## 2b. Waxa la Dhammeeyay ✅ (cusub — 2026-08-28, dhinac labaad)

### Email verification — mid dhab ah + login gate
- ✅ **Resend integration dhab ah** — email-yadu si dhab ah ayay ugu socdaan users-ka (domain `kalmo.ideashubsomalia.com` la xaqiijiyay)
- ✅ **Login gate**: user aan email-kiisa xaqiijin **ma heli karo app-ka** — `ProtectedRoute` wuxuu ku celiyaa `/check-email` ilaa ay xaqiijiyaan (Login.jsx sidoo kale toos ayuu ugu diraa halkaas)
- ✅ **Navbar minimal mode**: bogagga `/verify-email` iyo `/check-email`, profile icon iyo "Log out" **lama muujiyo** (log out button oo qoraal ah ayaa ku jira bogga qudhiisa si aanu user-ku u xirnaan)
- ✅ **Bug la xaliyay — idempotent verify**: link-yada email-ka waxaa "isticmaali" kara Gmail/security scanners iyaga oo aan user-ku weli riixin (prefetch) — `verifyEmail()` hadda waa idempotent, click-ka labaad ee token la isticmaalay horeba wuxuu soo celiyaa guul, ma ahan "invalid/expired"
- ✅ **Bug la xaliyay — EMAIL_FROM qaldnaa**: `.env` domain-ka aan la xaqiijin (`onboarding@resend.dev`) ayaa diidi jiray dirista third-party emails — hadda `EMAIL_FROM` wuxuu isticmaalayaa domain-ka la xaqiijiyay
- ✅ **Bug la xaliyay — resend "sent:true" been ah**: hore ayuu u sheegi jiray guul xitaa marka Resend uu fashilmo (403) — hadda waxaa la soo celiyaa error run ah (`EMAIL_SEND_FAILED`)
- ✅ **Bug la xaliyay — stale frontend state**: marka user-ku email-ka xaqiijiyo, `AuthContext` (localStorage) hore uma cusboonaysiin jirin `emailVerified`, sidaas darteed user-ku sii xiran lahaa `/check-email` xitaa ka dib verification-ka dhabta ah — hadda `refreshUser()` ayaa loo yeeray si toos ah kadib guusha verify-ka
- ✅ **Bug la xaliyay — CORS**: `.env` `CLIENT_ORIGIN` ayaa mar-mar laga saarayay dev port-yada (5180/5185) marka la beddelo settings kale — waa fiiro celin mustaqbalka ah in la hubiyo mar kasta

## 2b. Waxa la Dhammeeyay ✅ (2026-08-28, dhinac koowaad)

### Dhibaatooyin la xaliyay
- ✅ **Admin ma arki jirin campaign-yada `submitted`** — status-kan waxaa lagu daray filter-ka admin + action buttons (approve/start_review/reject); backend-ku hadda wuxuu ogolaadaa `approve` toos ah `submitted → approved`
- ✅ **Donation-yadu waxay u furnaayeen campaign kasta** (xitaa draft/suspended) — hadda waxaa la hubiyaa in campaign-ku status public/donatable ku yahay ka hor inta donation la abuurin
- ✅ **Verification badges ma ahayn kuwo dhab ah** — marka admin-ku beneficiary-ga xaqiijiyo, campaign-yada isaga la xiriira si otomaatig ah waxay helayaan badge-ka `beneficiary_verified` (iyo laga saarid haddii la diido)
- ✅ **Email verification link jabay** — `CLIENT_ORIGIN` (comma-separated liis) ayaa si qaldan loo isticmaali jiray link-ka email-ka; hadda waxaa la isticmaalaa origin-ka koowaad kaliya

### Feature cusub
- ✅ **Audit Logs — dhab ah**: `AuditLog` model (immutable), la qoro marka la sameeyo: campaign review, payment confirm, beneficiary review, user status change, withdrawal review — `GET /admin/audit-logs`, frontend-ku xog dhab ah ayuu tusayaa (ma aha sample)
- ✅ **Image upload — dhab ah**: `POST /api/v1/uploads/image` (multer, local disk storage `server/uploads/`, JPEG/PNG/WebP, 5MB max), la xiray `ImageUpload` component + Campaign Creation "Basics" step (cover photo)
- ✅ **Organizer onboarding — la fududeeyay**: "Start a fundraiser" hadda si otomaatig ah ayuu user-ka uga dhigayaa organizer (ma jiro click dheeraad ah oo xaqiijin ah), toos ayuuna ugu gudbiyaa campaign creation-ka. `StartFundraiserLink` component wuxuu go'aamiyaa meesha loo diri lahaa iyadoo ku xiran xaalada user-ka (logged-out/donor/organizer)
- ✅ **Email verification frontend**: `/verify-email` (link-ka email-ka wuu shaqeeyaa), `/check-email` (confirmation page + resend), `POST /auth/resend-verification-email`

### Frontend (client/) — React + Vite + Tailwind
- ✅ Design system dhab ah oo ku salaysan `Design_Rules.md`
- ✅ Component library: Button, Input, VerificationBadge, ProgressBar, StatusPill, CampaignCard, Navbar (role-aware), Footer, DashboardLayout, WizardSteps, EmptyState, SampleDataNotice, **ImageUpload**, **StartFundraiserLink**
- ✅ Public: Home (GoFundMe-style layout, Kaalmo colors, real stats), Explore, Campaign Detail, How It Works, Safety, Contact, Help Center, Terms, Privacy
- ✅ Auth: Login, Register, **Verify Email, Check Email** — wired
- ✅ Donor: Dashboard, Donate, Donation Confirmed
- ✅ Organizer: Onboard (auto), Dashboard, campaign wizard (Basics w/ **image upload** → Story → Review & Submit), Analytics, Withdrawals
- ✅ Beneficiary: Verification
- ✅ Admin: Overview, Campaigns (approve/reject/publish/suspend/restore incl. `submitted`), Verification Queue, Users, **Audit Logs (dhab ah)**, **Fraud & Risk (rule-based dhab ah)**, **Support Tickets (dhab ah)**

### Backend — Models — 14/14
- ✅ `User`, `Campaign`, `Beneficiary`, `Donation`, `Payment`, `PaymentTransaction`, `Withdrawal`, `PayoutAccount`, `Update`, `Comment`, `Verification`, `AuditLog`, **`SupportTicket`**, **`CampaignMember`**

---

## 3. Waxa Ku Dhiman (Weli Lama Bilaabin) 🔴

### Backend
- [ ] Real payment provider-yo dheeraad ah (eDahab, Zaad, bank, card) — EVC Plus (WaafiPay) hadda dhab ayuu yahay, kuwa kale weli lama xirin
- [ ] Webhook handling + idempotency (EVC Plus hadda synchronous ayuu yahay — ma leh webhook, mana u baahna, laakiin provider-yada mustaqbalka qaarkood way u baahnaan doonaan)
- [ ] Like (donation "support" reaction) — Follow/Bookmark waa la dhammeeyay, Like weli lama dhisin
- [ ] Notification email channel — hadda in-app kaliya; email-events (via Resend) weli lama xirin dhammaan dhacdooyinka
- [ ] Local disk storage (`server/uploads/`) waa MVP fallback — u baahan S3/Cloudflare R2 marka la geeyo production (fayl-yadu kuma hadhi doonaan disk-ka haddii server-ku dib loo geeyo)

### Frontend
- [ ] i18n backend content — Notification title/body iyo fraud signal strings waxaa server-ka lagu abuuraa Ingiriisi ah, u baahan template bilingual ah (eeg 0g)

### Deployment — 0% la bilaabay
- [ ] Dockerize server + client
- [ ] CI/CD
- [ ] Production hosting + secrets management + object storage (S3/R2)

---

## 4. Talaabada Xigta ee La Soo Jeediyay

1. Provider-yo dheeraad ah (eDahab/Zaad/bank/card) — marka la xaqiijiyo oo la ogolaado in la bilaabo
2. Email notification channel (ma ahan in-app kaliya)
3. Notification/fraud-signal backend content oo bilingual ka dhigid (haddii loo baahdo)

Fadlan ii sheeg xagee la bilaabo.

---

## 5. Sida Faylkan loo Isticmaalo

Fayl kastaa oo la sameeyo ama feature la dhammeeyo, waa in faylkan **la cusboonaysiiyo**.
