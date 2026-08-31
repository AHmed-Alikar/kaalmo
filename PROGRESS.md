# Kaalmo — Horumarka Mashruuca (Progress Tracker)

> La cusboonaysiiyay: 2026-08-30 (Mobile FCM Push — Flutter client (firebase_core/messaging), token lifecycle, foreground/background/terminated + tap→route, notification channel; analyze clean, 255 test pass. Firebase project config + real-device test hadhay)
> Tani waa faylka lagu raad-raaco waxa la dhisay, waxa socda, iyo waxa weli ku dhiman marka loo eego `kaalmo-web-only-spec.md` iyo `Design_Rules.md`.

---

## 1. Guud ahaan xaaladda hadda

| Qayb | Xaalad |
|---|---|
| **Backend (server/)** | 🟢 MVP-core + trust/moderation + social features (Follow/Save/Reports/Team/Notifications) + **EVC Plus (WaafiPay) dhab ah** + **dib-u-dejinta furaha sirta ah (password reset) dhab ah** waa dhammaystiran |
| **Frontend (client/) — Web** | 🟢 Bogagga oo dhan ee la qorsheeyay waa la dhisay oo dhab ah ula xiran yihiin backend-ka; **i18n dhab ah — dhammaan 39 bog + shared components (StatusPill/VerificationBadge/ProgressBar/ImageUpload/DashboardLayout nav) waa la buuxiyay** |
| **Mobile (mobile/) — Flutter** | 🟢 Aasaaska + Auth + Home/Explore + Campaign Experience + Donation/Payment + My Donations + Organizer + Beneficiary + In-App Notifications + Profile/Settings/About + Support Tickets + Co-organizer Invites + **FCM Push (Flutter client: token lifecycle, foreground/background/terminated, tap→deep-link, notification channel)** + bottom-nav shell. **Beta-diyaar** (analyze clean, 255 test pass, debug APK dhisi karo). Xigta (beta ka dib): Withdrawal execution. FCM: Firebase project config (`google-services.json`) + real-device delivery test ayaa hadhay |
| **Admin Dashboard** | 🟢 Dhammaan qaybaha — Overview, Campaigns, Verification Queue, Users, Reports, **Fraud & Risk (rule-based dhab ah)**, **Support Tickets (dhab ah)**, Audit Logs — waa la dhammaystiray, ma jiro sample data hadhay |
| **Payment Providers** | 🟢 **EVC Plus (Hormuud, WaafiPay gateway) — dhab ah, USSD push** + **idempotency + donation validation + `GET /payments/config`**; donations waa la iska xaqiijiyaa (auto-confirm). Live charge verification = manual QA |
| **Push notifications (FCM)** | 🟢 Backend + **Flutter client** dhammaystiran — device token register/remove/multi-device, `notifyUser` dispatch (data: `type`/`targetUrl`/`notificationId`), invalid-token cleanup, `User.pushEnabled`, mobile: init/permission/token-sync/foreground/background/terminated/tap→route. **Live delivery = Firebase project dhab ah (`google-services.json` + `FIREBASE_*` env) + real-device test ayaa loo baahan yahay** |
| **Deployment** | 🔴 Wali lama bilaabin |

## 0s. Mobile FCM Push Notifications — Flutter client (2026-08-30)

**Codsi:** Marka dhacdo backend muhiim ah dhacdo, telefoonka Android-ka ee user-ku ha helo push notification dhab ah oo FCM ah. In-app notification-ka jira LAMA dib-u-dhisin — push waa channel-ka gaarsiinta oo dheeraad ah.

### Audit (STEP 1) — waxa horeba jiray
- ✅ **Backend (horeba dhammaystiran, 0.i marxalad):** `DeviceToken` model (`{userId, token unique, platform, lastSeenAt}`), `POST/DELETE/GET /api/v1/devices` (`requireAuth`, caller-scoped, upsert idempotent, token reassignment device-handoff), `fcmService.js` (firebase-admin lazy init env-ka kaliya, multicast, dead-token cleanup, credentials weligood laguma log-gareeyo, no-op marka aan la configure-gareyn), `notificationService.notifyUser` → in-app + push (fire-and-forget), `User.pushEnabled` master switch. 65 server test.
- ✅ **Mobile foundation (horeba jiray):** `PushService` (abstract) + `NoopPushService`, `currentPushPlatform()`, `DeviceApi` (`/devices`), `DeviceRegistrar` (start/syncOnLogin/unregisterOnLogout/token-rotation), `pushServiceProvider`/`deviceApiProvider`/`deviceRegistrarProvider`, `resolveNotificationRoute`, `.gitignore` (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`).
- ⚠️ **Xogta la helay MISSING/BROKEN:** `firebase_core`/`firebase_messaging` packages ma jirin; `FcmPushService` dhab ah ma jirin (Noop kaliya); Firebase init `main.dart` ma jirin; permission handling ma jirin; foreground/background/terminated handlers ma jirin; **`DeviceRegistrar.syncOnLogin/unregisterOnLogout` weligood LAMA WICIN** (nothing wired the registrar to auth state); Android: `google-services.json` ma jiro, Google Services Gradle plugin ma jiro, `POST_NOTIFICATIONS` permission ma jiro, notification channel/icon meta-data ma jiro; mobile push test ma jiro.

### Firebase configuration (STEP 2)
- ✅ **Code diyaar, config LAMA been-abuurin.** `main.dart` → `Firebase.initializeApp()` `try/catch` — haddii `google-services.json` la'aan yahay → `FcmPushService` wuxuu ogaadaa (`Firebase.apps.isEmpty`) oo dhammaan hababkiisu no-op yihiin → in-app notifications sidoodii u shaqeeyaan.
- ✅ **Gradle:** `settings.gradle.kts` → `com.google.gms.google-services` `4.4.2` `apply false`. `app/build.gradle.kts` → `if (file("google-services.json").exists()) apply(plugin=...)` — build-ku wuu shaqeeyaa `google-services.json` la'aan.
- ⚠️ **Loo baahan yahay gacanta:** developer-ku ha keeno `android/app/google-services.json` (Firebase Console → Android app `com.kaalmo.kaalmo_mobile`) + backend deployment `FIREBASE_PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY` (service-account JSON).

### Flutter changes (STEP 3–9)
- ✅ **`firebase_core: ^3.8.0` + `firebase_messaging: ^15.1.5`** (resolved 3.15.2 / 15.2.10) — laba package oo kaliya, sabab cad.
- ✅ **`lib/core/push/push_service.dart` la ballaariyay:** `PushService` + `PushPermission{granted,denied,notDetermined}` + `requestPermission()`/`permissionStatus()`/`onMessageOpened`/`onForegroundMessage`/`initialMessage()`. `NoopPushService` la cusboonaysiiyay.
- ✅ **`lib/core/push/push_message.dart` cusub:** `PushMessage {data, title?, body?}` + `type`/`targetUrl`/`notificationId`/`route` getters. Navigation waxaa laga soo saaraa **structured data fields** (`type`+`targetUrl`), **ma aha qoraalka la akhriyo**.
- ✅ **`lib/core/push/fcm_push_service.dart` cusub:** `FcmPushService implements PushService` — `onBackgroundMessage` (top-level `@pragma('vm:entry-point')` handler), `setForegroundNotificationPresentationOptions`, `onMessage`/`onMessageOpenedApp` → broadcast streams, `getToken`/`onTokenRefresh`/`getInitialMessage`/`requestPermission`/`deleteToken`. Dhammaan `try/catch` — token weligeed laguma print-gareeyo.
- ✅ **`lib/core/push/push_notification_service.dart` cusub (orchestrator):** hal meel oo leh push lifecycle-ka: `bootstrap()` (init + registrar.start + stream listeners + `ref.listen(authControllerProvider)` + cold-start `initialMessage`), `_onAuthenticated` (permission mar keliya + `registrar.syncOnLogin`), `_onLoggedOut` (`registrar.unregisterOnLogout` + `push.deleteToken`), `_handleForeground` (in-app feed refresh + `pushMessengerKey` SnackBar), `_handleOpened` (`refreshThenMarkRead(notificationId)` + navigate), `_routeFor` (public `/campaign/*` → toos; auth-required → `_pendingRoute` → `/login` → `_consumePending` login ka dib).
- ✅ **`resolveNotificationRouteFrom({type, targetUrl})`** — `resolveNotificationRoute(AppNotification)` waa wrapper. **Hal source of truth** — push tap iyo in-app row isku meel ayay tagaan. `campaign_comment` → `/campaign/:id/comments` lagu daray.
- ✅ **`NotificationsController.refreshThenMarkRead(id)`** — feed dib u soo qaad, kadib notification-ka la taabtay calaamadee la akhriyay.
- ✅ **`main.dart`** — `WidgetsFlutterBinding.ensureInitialized` → guarded `Firebase.initializeApp` + `onBackgroundMessage`. **`app.dart`** — `scaffoldMessengerKey: pushMessengerKey` + `pushNotificationServiceProvider.bootstrap()` (badalka `deviceRegistrar.start()`).
- ✅ **Auth wiring la hagaajiyay:** `DeviceRegistrar.syncOnLogin/unregisterOnLogout` hadda `PushNotificationService` ayaa ku wacaa `ref.listen(authControllerProvider)` transitions — login cusub → token register, logout → token remove + delete.

### Backend changes (STEP 10–11)
- ⚠️ **HAL isbeddel yar oo additive** — `server/src/services/notificationService.js`: push `data` map hadda wuxuu qaadaa `notificationId` (`String(Notification._id)`) marka lagu daro `type` + `targetUrl`. Sababta: mobile-ku ha calaamadee notification-ka saxda ah "la akhriyay" marka push la taabto + foreground dedup. Navigation architecture LAMA dib-u-qorin. `+1` server test (`push data carries the originating notification id`). Notification service-ka intiisa kale sidoodii.
- Endpoint cusub LAMA abuurin — `/devices` horeba way jireen.

### Android (STEP 14)
- ✅ `AndroidManifest.xml` — `POST_NOTIFICATIONS` permission + FCM meta-data (`default_notification_icon` → `ic_stat_notification` vector, `default_notification_color` → `@color/kaalmo_notification_accent`, `default_notification_channel_id` → `kaalmo_default`).
- ✅ `MainActivity.kt` — `kaalmo_default` channel abuur (`IMPORTANCE_HIGH`, magac/sharaxaad `strings.xml` + `values-so/strings.xml` — SO+EN). Hal channel oo caqli-gal ah.
- ✅ `res/drawable/ic_stat_notification.xml` (white bell silhouette), `res/values/colors.xml`.

### Security (STEP 12)
- ✅ Notification payload weligeed looma isticmaalo authorization — backend API auth ayaa mas'uul ah. `data` map = navigation metadata kaliya (`type`/`targetUrl`/`notificationId`) — ma jiro secret/password/OTP/PII. FCM token weligeed laguma log-gareeyo (client + server). Logout → token backend laga saaray + local delete → user-ka xiga device-kan kuma helo notification user-kii hore.

### Localization (STEP 13)
- ✅ `pushOpenAction` ("Open"/"Fur") — SO+EN parity. Android channel name/desc — `values/` + `values-so/`. ⚠️ Backend notification `title`/`body` weli Ingiriisi (data, documented gap sidii hore).

### Tests (STEP 16)
- ✅ **`flutter analyze` → No issues found.** **`flutter test` → +255 pass** (238 → +17: `test/push_notifications_test.dart`).
- Daboolan: `PushMessage` parse/coerce/route, `resolveNotificationRouteFrom` (campaign/updates/comments/organizer/invites/verification/support/withdrawal→null/unknown→null), token lifecycle (login→permission+register, refresh→re-register, logout→remove+delete, permission denied→no-throw+still register, backend fail→swallowed), tap routing (opened→navigate+markRead, unknown→`/notifications` fallback, auth-required→pending→login→consume, cold-start public→navigate, cold-start auth-required→pending), foreground (feed refresh, no mark-read), `NoopPushService` no-op.
- ✅ **Server:** `test/pushNotifications.test.js` +1 (`notificationId` payload) → **66 server test pass**.

### Limitations / Manual config
- 🔒 **Real device FCM delivery LAMA TIJAABIN** — u baahan Firebase project dhab ah + `google-services.json` + device dhab ah. Wiring dhammaantiis code + automated test (fakes) ayaa la xaqiijiyay.
- ⚠️ `google-services.json` (Android) developer-ku ha keeno; `FIREBASE_*` env backend deployment.
- ⚠️ Backend notification `title`/`body` Ingiriisi kaliya.
- ⚠️ `flutter_local_notifications` LAMA darin — foreground = SnackBar in-app + feed refresh (Android tray kaliya background/terminated ayuu muujiyaa).

## 0r. Mobile Final Completion Phase — Beta Readiness (2026-08-30)

**Codsi:** Marxaladda ugu dambaysa ee mobile-ka beta ka hor — dhammaystir waxyaabaha adeegsadaha muhiimka u ah oo hadhay, isku-dubbarid, tijaabin dhammaan, hagaajin cilado dhab ah, UX polish, xaqiijin Android, diyaargarow beta. Audit hore → dabadeed dhis. Ma dib-u-dhisin waxa dhammaystiran, ma abuurin duplicate, ma been-abuurin functionality (gaar ahaan lacag-qaadasho/payout).

### Audit (STEP 1) — waxa la helay & la xalliyay
- ✅ **`AndroidManifest.xml` (release blocker):** `android.permission.INTERNET` waxaa kaliya ku jiray `src/debug` + `src/profile` → **release build wuu shabakad la'aan noqon lahaa**. Lagu daray `src/main`. `android:label` `"kaalmo_mobile"` → `"Kaalmo"`.
- ✅ **Dead routes/code:** `PlaceholderScreen` + `/donate` placeholder route + `placeholderComingSoon`/`donateComingSoonNote`/`campaignRaisedOfGoal` l10n keys — la tirtiray. `AppRoutes.donate` (dead const) la saaray.
- ✅ **`errorBuilder` maqan:** GoRouter uma lahayn fallback → hadda `NotFoundScreen` (localized, "Home" button).
- ⚠️ Backend gaps la xaqiijiyay: profile-edit **wuu jiraa** (`PATCH /users/me` → `fullName`/`language`/`pushEnabled`) → la dhisay. Password-change authenticated endpoint **ma jiro** → forgot-password flow (logout → `/forgot-password`). Delete-account endpoint **ma jiro** → "Close my account" → support ticket hore loo buuxiyay (documented gap, lama been-abuurin).

### Screens/routes cusub
- `/profile/settings` `SettingsScreen` — PREFERENCES (luqad SO/EN SegmentedButton → `localeController` + best-effort `PATCH language`; push notifications SwitchListTile → `PATCH pushEnabled`, revert+snackbar on error). ACCOUNT (Edit name → bottom sheet → `PATCH fullName`; Change password → confirm → logout → `/forgot-password`). APP (About; Help & Support; Close my account → prefilled support ticket). Logout (danger → confirm).
- `/profile/settings/about` `AboutScreen` — appName, tagline, body, legal rows (`SelectableText` URLs — url_launcher lama darin).
- `/support` `SupportScreen` — liiska tikidhada (`myTicketsProvider`). loading/error+retry/empty(scrollable, "New request")/data (`RefreshIndicator` + `ListView.separated` — subject, message 2-line, status chip, `formatRelative`, reply count). FAB "New request".
- `/support/new` `CreateTicketScreen` — subject (3–200) + message (5–2000), `maxLength` + errorText, `initialSubject` seed (close-account). Submit → `POST /support-tickets` → invalidate + snackbar → `pushReplacement` ticket detail.
- `/support/:id` `TicketDetailScreen` — thread (`_Bubble` mine/support, 82% width) + `_ReplyBar` (`POST .../replies`) marka aan la xirin, kelse "closed" note. Reply done → clear + invalidate.
- `/organizer/invites` `OrganizerInvitesScreen` — casumaadaha co-organizer (`campaignInvitesProvider` → `GET /campaign-invites/mine`). empty/data (`_InviteCard` — campaign title, inviter, "Accept invitation" → `POST /campaign-invites/:memberId/accept` → invalidate `campaignInvitesProvider`+`myCampaignsProvider` → snackbar → `/organizer/campaign/:id`). Tan ayaa dhammaystirtay role-ka **CO-ORGANIZER** (permission logic horeba way shaqaynaysay, aqbalaadda casumaadda kaliya ayaa maqnayd).
- `ProfileScreen`: lagu daray tiles Notifications / Campaign invitations / Settings.

### Backend
- **0 isbeddel `server/**` / `client/**`.** Dhammaan endpoints la isticmaalay horeba way jireen: `PATCH /users/me`, `/support-tickets` (`/mine`, `/mine/:id`, `/mine/:id/replies`), `/campaign-invites/mine` + `/:memberId/accept`.

### Notification navigation
- `resolveNotificationRoute`: lagu daray `/organizer/invites` → `AppRoutes.organizerInvites`, `/support` → `AppRoutes.support` (hore = `null`). `/organizer/withdrawals` + unknown weli `null` (withdrawal la dib-dhigay).

### Audit-yada kale (STEP 5–19)
- ✅ **Routes:** dhammaan back-nav / deep-link / login-redirect (`?from=` allowlist + `/support` lagu daray `returnable`) / logout / unauthorized / role-nav / deleted-resource (`errorBuilder`) la xaqiijiyay. Ma jiro duplicate route.
- ✅ **Roles:** DONOR/ORGANIZER/BENEFICIARY/CO-ORGANIZER — UI role-gating (`user.isOrganizer` iwm) waa cosmetic kaliya; backend authorization = xaqiiqada. **Admin mobile lama abuurin.**
- ✅ **Withdrawal:** DHAB LACAG-QAADASHO LAMA DHISIN. Payout readiness waa daacad ("Withdrawal is currently unavailable"). Ma jiro fake payout success / provider bypass / credential storage / hardcoded secret.
- ✅ **UX polish:** design system la ilaaliyay (ma jirin redesign) — spacing/typography/buttons/cards/chips/states isku dhigid.
- ✅ **Responsive:** tall-surface tests + `_Bubble` 82%-width + `maxLength` fields + scrollable empty states. Ma jiro overflow la og yahay.
- ✅ **Localization:** ~55 fure cusub halkiiba (SO + EN, parity buuxda — 0 `@`-key ka maqan). Ma jiro string adag oo aan la turjumin. ⚠️ Backend `title`/`body` + ticket replies = Ingiriisi (data, ma aha UI chrome).
- ✅ **Accessibility:** touch targets ≥ 44, `SwitchListTile`/`SegmentedButton` labeled, icon buttons `tooltip`/`Semantics`, form labels.
- ✅ **Network/errors:** dhammaan screen-yada cusub — loading/success/empty/error/retry. `presentError` + `AppException` (401/403/404/409/429/500/timeout/network/malformed). Ma jiro blank screen ama uncaught exception adeegsade u muuqda.
- ✅ **Security:** tokens `flutter_secure_storage` (keystore); ma jiro secret/API-key source-ka; ma jiro password/token log (`LogInterceptor` body/header off); logout → `clearSession()` (tokens + user wipe, locale kaliya hadhay); notification controller session-scoped (user cusub ma arko feed-ka hore).
- ✅ **Performance:** ma jiro duplicate request (single-flight controllers), ma jiro pagination been-abuur; images `CachedNetworkImage` horeba.
- ✅ **pubspec.yaml:** 0 dependency lagu daray, 0 la saaray (dhammaan la isticmaalaa).

### Android (STEP 21–22)
- ✅ `applicationId` = `namespace` = `com.kaalmo.kaalmo_mobile`, label "Kaalmo", `INTERNET` permission (main), `minSdk`/`targetSdk` = Flutter default, `flutter doctor` → Android SDK 36.0.0 + 3 device la heli karo.
- ✅ **Build fixes (within mobile project, `mobile/android/**` oo untracked):**
  1. `flutter_secure_storage` u baahan `compileSdk 37` (Flutter 3.47 default = 36) → `build.gradle.kts` `compileSdk = maxOf(flutter.compileSdkVersion, 37)`. SDK Platform 37 la rakibay.
  2. Kotlin incremental compiler wuu jabaa marka pub cache (`C:`) iyo mashruuca (`D:`) ay ku kala jiraan darawallo Windows kala duwan (`RelocatableFileToPathConverter: "different roots"`) → `gradle.properties` `kotlin.incremental=false`.
- ✅ **`flutter build apk --debug` → SUCCESS:** `√ Built build\app\outputs\flutter-apk\app-debug.apk` (163 MB debug APK). Release build lama isku dayin (signing config dhab ah lama diyaarin — operational).
- ⚠️ **Device/emulator manual run** — weli lama sameynin (local verification kaliya).
- Production secrets lama gelin. `apiBaseUrl` = `--dart-define` / `AppConfig` (dev `10.0.2.2:5000`).

### Tests (STEP 20)
- ✅ `flutter analyze` → **No issues found** (ran ~42s).
- ✅ `flutter test` → **+238 All tests passed** (baseline hore 214 → +24 cusub: `support_test.dart` ×14, `completion_screen_test.dart` ×~14, notification route/target updates).
- Cusub: SupportTicket/TicketStatusView parse, SupportRepository (myTickets/create body/401), NewTicket + TicketReply controllers, Settings (edit name PATCH / push toggle PATCH / change password → forgot / close account → prefilled ticket), Support widget flows (list/empty/error/create→detail/reply/guest→login), Co-organizer invites (empty/accept→manage/accept-failure), CampaignInvite.fromJson, NotFoundScreen route.

### Known limitations / Future work
- 🔒 **Withdrawal execution** — payout provider credentials lama hayo → la dib-dhigay (honest "unavailable").
- 🔒 **FCM push delivery** — backend + `DeviceToken` diyaar; mobile client wiring la dib-dhigay (beta ka dib).
- ⚠️ **Delete account** — backend endpoint ma jiro → support-ticket workaround.
- ⚠️ **Password change (authenticated)** — backend endpoint ma jiro → forgot-password flow.
- ⚠️ Notification `title`/`body` + support replies English-only (backend data).
- ⚠️ Beneficiary↔campaign linkage + payout-account linkage APIs weli ma jiraan (0p gaps).
- ⚠️ Android device/emulator manual smoke test weli waa la sameyn (build + analyze + automated tests dhammaan pass).

### Git safety
- ✅ Ma commit, ma push, ma PR, ma reset. `server/**` + `client/**` lama taaban (pre-existing changes sidoodii). `mobile/` untracked sidoodii.

## 0q. Mobile In-App Notifications (2026-08-30)

**Codsi:** In-app notification experience oo keliya (FCM/push maya, Withdrawal maya, Admin maya). Backend-ka jira kaliya la isticmaalo — 0 isbeddel.

- ✅ **Backend la baaray, 0 isbeddel (`server/**` / `client/**` lama taaban):** `GET /api/v1/notifications/mine` (`requireAuth` → `{items: Notification[], unreadCount}`, `.sort({createdAt:-1}).limit(50)` — **cap 50, no pagination**), `PATCH /api/v1/notifications/:id/read` (ownership la hubiyo → 404 haddii aan lahayn → notification cusboonaysiiyay), `PATCH /api/v1/notifications/read-all` (→ `{updated:true}`). `Notification` model: `{_id, type (free string), title, body?, targetUrl?, read, createdAt, updatedAt}`.
- ✅ **Type values dhabta ah (`notifyUser` calls):** `donation_confirmed`, `campaign_update`, `campaign_status_change`, `campaign_{approve|start_review|reject|publish|suspend|restore}`, `beneficiary_{verified|rejected}`, `withdrawal_{pending|under_review|approved|processing|completed|failed|frozen}`, `team_invite`, `support_reply`, `account_status`. `targetUrl` (web paths): `/campaigns/:id`, `/organizer`, `/verification`, `/organizer/invites`, `/organizer/withdrawals`, `/support`.
- ✅ **Screen/route:** `/notifications` `NotificationsScreen` (laga beddelay `PlaceholderScreen`, `parentNavigatorKey: _rootKey`). AppBar action "Calaamadee dhammaan la akhriyay" marka `unreadCount > 0`. States: loading (`LoadingView`) / ready (`ListView.separated` + `RefreshIndicator`) / empty ("Weli ogeysiis ma jiro" — scrollable si pull-to-refresh) / error (`ErrorView` + retry). `initState` post-frame `refresh()` si dib-u-imaadka loo cusboonaysiiyo.
- ✅ **`NotificationTile` (reusable):** icon-chip (kind-based), title (bold marka aan la akhrin), body (backend qoraal), waqti la is-daba-joogo (`formatRelative`), dot cas marka aan la akhrin + background brand-tinted khafiif ah, `chevron_right` marka target la heli karo. Midabbo yar (design system) — kaliya `campaign_reject/suspend` + `account_status` ayaa isticmaala tone kale.
- ✅ **`NotificationBell` (Home header):** `Icons.notifications_none` + badge cas oo tusaya **`unreadCount` backend-ka** (`select` — lagama xisaabiyo liis qayb ah). Tap → `/notifications`.
- ✅ **Read/unread:** `NotificationsController` (StateNotifier, session-scoped — bell + screen hal feed + hal fetch). `markRead(id)` = **optimistic** (item.read=true + count-1 → API → fashil → dib u celi + `mutationError` snackbar). `markAllRead()` = optimistic oo dhan → API → revert on failure. Weligeed read state been ah lagama reebo — backend = xaqiiqada.
- ✅ **Unread count:** kaliya `unreadCount` backend-ka (authoritative) — bell badge + "mark all" visibility.
- ✅ **Navigation mapping (`resolveNotificationRoute`):** `/campaigns/:id` → `/campaign/:id` (ama `/campaign/:id/updates` haddii `type == campaign_update`); `/organizer` → `/organizer`; `/verification` → `/beneficiary`; `/support` + `/organizer/invites` + `/organizer/withdrawals` + unknown → **`null` (nav la'aan, laakiin weli read la calaamadeeyo, ma burburo)**.
- ✅ **Auth:** `/notifications` = gal loo baahan yahay (router → guest → `/login`; `?from=` allowlist `/notifications` lagu daray). `_LoginGate` sidoo kale screen-ka gudihiisa (difaac). Bell kaliya Home (horeba auth-gated).
- ✅ **Localization:** ~18 fure cusub (Soomaali + Ingiriisi — 0 `@`-key ka maqan `app_so.arb`). Ma jiro string adag oo aan la turjumin. ⚠️ Backend `title`/`body` = Ingiriisi (data, ma aha UI chrome) — turjumaad u baahan template backend ah (documented gap, sida `PAYMENT_DECLINED` hore).
- ✅ **Error handling:** `presentError` + `AppException` (401/403/404/429/500/timeout/network/malformed row → `whereType<Map>` skip / unknown type → `system` fallback). Ma jiro blank screen.
- ✅ **Performance:** hal fetch session-ka (non-autoDispose controller), pull-to-refresh + post-frame refresh kaliya, ma jiro pagination la been-abuurin (backend cap 50 la documented-gareeyay).
- ✅ **Tests (dhammaan pass):** `notifications_test.dart` (unit — `AppNotification`/`NotificationFeed` parse + malformed skip, `NotificationKind.fromType` ×13 + fallback, `resolveNotificationRoute` ×7, `NotificationsController` load/error/empty + markRead optimistic+decrement+revert + already-read no-op + markAllRead + revert + unauth-no-load, EN + SO l10n strings). `notifications_screen_test.dart` (widget — loading, list unread/read render, empty, error+retry, mark-all-read, tap→markRead+navigate→CampaignDetails, no-target→markRead+no-crash, pull-to-refresh, Home bell badge + open, guest→login). `flutter analyze` → **No issues found**. `flutter test` → **dhammaan pass**.
- ⚠️ **Limitations:** no pagination (backend 50-cap); notification title/body English-only (backend data); no per-notification detail screen (tile navigates straight to the target); withdrawal/co-organizer-invite/support targets have no in-app destination yet (tile marks read but doesn't navigate).
- ➡️ **Xigta:** Withdrawal execution UI / FCM push wiring (foundation horeba way jirtaa).

## 0p. Mobile Organizer + Beneficiary (2026-08-30)

**Codsi:** Hal marxalad diiran: waaya-aragnimada Organizer (maamul ololayaal) + Beneficiary (xiriirka ka-faa'iidaystaha + xaqiijin + diyaarinta lacag-qaadashada — DHAB LACAG-QAADASHO MAYA). Backend-ka jira kaliya. Ma la dhisin Admin/FCM/Analytics/Withdrawal-execution/Payment-changes.

### Backend la baaray, 0 isbeddel `server/**` / `client/**`
- **Organizer:** `GET /campaigns/mine` (`requireAuth` — owned + accepted co-organized, mid kasta `access:'owner'|'co-organizer'`, newest-first, **no pagination**, **no aggregate totals**), `PATCH /campaigns/:id` (`updateCampaignSchema` = `createCampaignSchema.partial()` → `title{so≥5,en?}`, `story{so≥20,en?}`, `category`(enum 14), `goalAmount>0`, `region?`, `endDate?`, `coverImageUrl?` — **NO `mediaUrls`, NO `beneficiaryId`**; `canEditCampaign` gate; statuses `submitted..withdrawal` → editing dib ugu celisa `under_review`; `NOT_EDITABLE` = suspended/frozen/cancelled/expired/completed), `POST /campaigns/:id/submit` (owner, `draft → submitted` kaliya), `POST /campaigns/:id/cancel` (owner, `draft|submitted → cancelled`), `DELETE /campaigns/:id` (owner, draft kaliya), `POST /campaigns/:id/updates` (`createUpdateSchema {text≥10, imageUrl? url}`, contributor), `GET /campaigns/:id/members` (owner-only, raw `CampaignMember` — email + status kaliya, ma populate-gareeyo magac).
- **Beneficiary:** `GET /beneficiaries/me` (`requireAuth` — **404 marka aan la gudbin** → repo → `null`), `POST /beneficiaries/me` (`{fullName 2–100, idDocumentUrl? url}` → diiwaan `pending`), `GET /payout-accounts/mine`, `POST /payout-accounts` (`{type: mobile_money|bank, accountNumber 4–30, providerName 2–60}` → masked-only `***1234`). Verification flags: `/users/me` → `emailVerified/phoneVerified/identityVerified`; beneficiary → `verificationStatus: pending|verified|rejected`.
- ⚠️ **Backend gaps (la sheegay, lama beddelin, workaround lama abuurin):** (1) **Ma jirto API lagu xiro ka-faa'iidayste olole** — `Campaign.beneficiaryId` waxaa dhigta `seed.js` + admin kaliya → beneficiary-gu ma arki karo "ololayaashayda", organizer-ku ma dooran karo ka-faa'iidayste. (2) **Ma jirto nidaam casumaad/aqbalaad ka-faa'iidayste** — casumaadaha kaliya waa co-organizer (`CampaignMember`, `/campaign-invites/*`). PART B "Invitation → Accept" lama dhisi karo. (3) **Ma jirto habka la siiyo `beneficiary` role** (`seed` kaliya; laakiin `POST /beneficiaries/me` waa `requireAuth` oo qof kasta u furan). (4) **Ma jirto API lagu xiro `Beneficiary.payoutAccountId`** (admin/seed kaliya) → `payoutReady` = `verified && payoutAccountId!=null` lagama gaari karo si is-adeeg ah. (5) **`rejected` campaign dib looma gudbin karo** (`TRANSITIONS` `rejected` key ma laha). (6) **`updateCampaignSchema` `mediaUrls`/`beneficiaryId` ma laha** → sawir/ka-faa'iidayste lagama beddeli karo edit-ka. (7) Media upload (`POST /uploads/image` multipart) → u baahan `image_picker` package + wiring → **la dib-dhigay** (updates = qoraal kaliya, edit = sawir la'aan).

### Organizer screens/routes
- `/organizer` `OrganizerDashboardScreen` — role-gated (`user.isOrganizer`; kelse "Weli abaabule ma tihid"). Stats oo DHAMMAAN **la xisaabiyay client-side liiska dhabta ah** (`OrganizerStats.from`): total/live/in-review/drafts/completed/rejected + total raised (sum `raisedAmount`). Recent 3 + "View all". Pull-to-refresh.
- `/organizer/campaigns` `MyCampaignsScreen` — dhammaan (`OrganizerCampaignTile`: sawir, cinwaan, qayb, `CampaignStatusPill`, progress, "Co-organizer" chip). States: loading/success/empty/error+retry/pull-to-refresh.
- `/organizer/campaign/:id` `CampaignManageScreen` — header (sawir/cinwaan/status pill/progress), `CampaignActionSet.forCampaign(c, isOwner:)` (**mirror backend `campaignService.js`**: `_notEditable`, `_editReturnsToReview`, `_public`, draft-only submit/delete, draft|submitted cancel) → button kaliya la tuso marka backend-ku ogol yahay. Actions: Edit, Post update, View public page, Submit for review (confirm→`submit()`→refresh+snackbar), Cancel (confirm, destructive), Delete draft (confirm→pop). Warnings: `rejected` note, "editing returns to review" note. Beneficiary info (chip: linked/none — resolve lama karo). Team section (owner-only, `campaignMembersProvider` — email + accepted/pending).
- `/organizer/campaign/:id/edit` `CampaignEditScreen` — form: titleSo(5–150)/titleEn/category(dropdown)/region(dropdown, ikhtiyaari)/goal(>0)/storySo(≥20)/storyEn. Client validation = mirror backend. Save → partial body → `PATCH` → guul → invalidate + pop + snackbar. Note: "cover/gallery lagama beddeli karo app-ka".
- `/organizer/campaign/:id/update` `PostUpdateScreen` — qoraal (`text ≥10`), publish → `POST /updates` → guul → invalidate `campaignUpdatesProvider` + pop + snackbar. Media = deferred.
- Controllers: `CampaignEditorController` (hydrate-once + validation + partial save), `CampaignManageController` (submit/cancel/deleteDraft — single-flight, `error` state, guul kaliya ayaa wax bedesha — status client-side lama been-abuurin), `PostUpdateController` (min-10 guard + submit). `OrganizerApi`/`OrganizerRepository` (repo labaad lama abuurin — `Campaign` model la ballaariyay `access`/`beneficiaryId`).

### Beneficiary screens/routes
- `/beneficiary` `BeneficiaryDashboardScreen` — qof kasta oo la galay (backend = `requireAuth`, ma aha role). `beneficiaryProfileProvider` (`null` = weli lama bilaabin). Muujiya: **VerificationChecklist** (Email/Phone/Identity verified ka `/users/me` + Beneficiary verified ka profile — states dhabta ah kaliya), Identity card (magac + status pill + note pending/rejected + "Start verification"/"Update details" button), **Payout section** (`payoutAccountsProvider` — masked `***1234` + verified/awaiting + "Add payout account"), **Payout readiness banner** (`profile.payoutReady` → "Ready for withdrawal" [note: withdrawal = sii-deyn dambe] / "verify first" / "admin still needs to link" — mid kasta xaalad dhab ah). Linkage-note oo sharaxaya gap-ka. Pull-to-refresh.
- Forms (bottom sheets): `showBeneficiaryIdentitySheet` (`BeneficiaryIdentityController`, name 2–100 → `POST /beneficiaries/me` → invalidate + snackbar), `showPayoutAccountSheet` (`PayoutAccountFormController`, type segmented + provider 2–60 + account 4–30 → `POST /payout-accounts` → invalidate + snackbar).
- `BeneficiaryApi`/`BeneficiaryRepository` (404→`null`), models `BeneficiaryProfile` (+`BeneficiaryStatusView` none/pending/verified/rejected, `payoutReady`) + `PayoutAccount` (masked-only).

### Roles / authorization
- Backend = xaqiiqada haya (dhammaan gates: `canEditCampaign`, `isCampaignContributor`, owner checks, `requireRole` withdrawal). Client-side role check = tusin kaliya: Profile-ku wuxuu tusaa "Organizer" tile marka `user.isOrganizer`, "Beneficiary" tile had iyo jeer (backend qof kasta u ogol). Organizer dashboard = self-gate difaac ah. Router: `/organizer*` + `/beneficiary*` = gal loo baahan yahay (guest → `/login`); `?from=` allowlist la ballaariyay.
- Ma jiro `becomeOrganizer` onboarding (OTP flow) — halkan lama dhisin (unrelated feature).
- Weligeed lama log-gareeyo token/password/OTP/account number (masked-only backend-ka).

### Localization
- ~120 fure cusub (Soomaali + Ingiriisi — 0 `@`-key ka maqan `app_so.arb`) + 4 status cusub (`statusDraft/Submitted/UnderReview/Approved`). Ma jiro string adag.

### Error / loading / empty states
- Meel kasta: `LoadingView`/`EmptyView`/`ErrorView`+retry/pull-to-refresh. `presentError` + `AppException` hierarchy hore (unauthorized/forbidden/network/timeout/server-validation → fariin nabdoon). Invalid campaign action → button lama tuso; backend haddii uu diido (`INVALID_TRANSITION` iwm) → snackbar fariinta backend-ka. Missing campaign → `ErrorView`. Malformed optional fields → dulqaad (`whereType<Map>` skip).

### Tests (dhammaan pass)
- `organizer_test.dart` (unit — `OrganizerStats.from` tally+sum, `CampaignActionSet` per status ×5 [draft/submitted/active/completed+suspended/co-organizer], `CampaignEditorController` hydrate+validation+save success/failure, `CampaignManageController` submit/cancel/delete success + failure + single-flight, `PostUpdateController` min-10 reject + success + failure). `beneficiary_test.dart` (unit — `BeneficiaryProfile.fromJson`+statusView+`payoutReady`, `BeneficiaryRepository` 404→null + parse + 500-rethrow + malformed-skip, `BeneficiaryIdentityController` validation+success+failure, `PayoutAccountFormController` validation+success). `organizer_screen_test.dart` (widget — Profile→Organizer, dashboard stats+tiles, donor role → not-available, my campaigns empty/error+retry, manage draft actions + →edit, active campaign hides submit/delete, submit confirm→success, submit failure message, edit validation+save, post update validation+success). `beneficiary_screen_test.dart` (widget — Profile→Beneficiary, no-profile→start CTA, verified+linked→payout ready, verified+no-account→linkage message, error+retry, submit identity flow, add payout flow, guest→login).
- `flutter analyze` → **No issues found**. `flutter test` → **dhammaan pass**.

### Limitations (report)
- Beneficiary↔campaign linkage API, beneficiary invitation/acceptance API, `beneficiary` role assignment, `Beneficiary.payoutAccountId` self-service link, `rejected`-campaign resubmit, campaign media/`beneficiaryId` edit, `/campaigns/mine` pagination + aggregate totals — **dhammaan ma jiraan backend-ka**; workaround lama abuurin; kor eeg minimal backend change.
- ➡️ **Xigta:** Withdrawal execution UI / Notifications (FCM) UI.

## 0o. Mobile My Donations (2026-08-30)

**Codsi:** Donation + Payment kadib — la dhiso waaya-aragnimada "Deeqahayga" oo keliya: Profile → My Donations → taariikhda → fur deeq → rasiid → fur ololaha. `GET /api/v1/donations/mine` la isticmaalo (jira). Ma la dhisin Organizer/Beneficiary/Withdrawal/Notifications/Admin/Analytics.

- ✅ **Backend la baaray, 0 isbeddel:** `GET /api/v1/donations/mine` (`requireAuth`) → `Donation.find({donorId}).sort({createdAt:-1}).populate('campaignId','title coverImageUrl category')` → **array toos ah** (ma jiro wrapper, ma jiro pagination). Rukun kasta: `{_id, campaignId:{_id,title:{so,en},coverImageUrl,category}|null (haddii la tirtiray), donorId, amount, currency, isAnonymous, message?, paymentId (ObjectId, lama populate-gareeyo), paymentTransactionId, status:'pending'|'confirmed'|'failed'|'refunded', createdAt, updatedAt}`.
- ⚠️ **Xaddidaadaha backend (la sheegay, lama beddelin):** (1) **Ma jirto pagination** endpoint-kan — dhammaan deeqaha hal jeer ayaa la soo qaataa (newest-first server-side). Pagination param lama been-abuurin. (2) **Hab lacag-bixin (payment method) ma soo celiyo** endpoint-kan — wuxuu ku jiraa `Payment.provider` oo aan la populate-gareyn → My Donations tile/receipt-ku ma tuso habka lacag-bixinta (post-donation success-ka kaliya ayaa yaqaan sababtoo ah isticmaaluhu ayaa dooray). (3) **Ma jirto `GET /donations/:id`** → detail screen-ku wuxuu ka akhriyaa liiska horeba la soo dejiyay (`myDonationByIdProvider`); haddii aan la helin → "Deeqda lama helin" state nabdoon. (4) Reference-ka rasiidku = `donation._id`.
- ✅ **Screens/routes:** `ProfileScreen` (`/profile` — laga beddelay `PlaceholderScreen`; header aqoonsi + "Deeqahayga" tile + `LogoutAction`). `MyDonationsScreen` (`/profile/donations`, nested `parentNavigatorKey:_rootKey`). `DonationDetailScreen` (`/profile/donations/:id`, nested). Router redirect `from`-allowlist la ballaariyay `/profile/` → guul kadib dib ayaa loo celiyaa My Donations.
- ✅ **My Donations list:** `MyDonationTile` (sawir campaign / placeholder, magaca ololaha ama "Olole lama helayo", qadar, calaamad anonymous, waqti la is-daba-joogo, `DonationStatusChip`). States: **Loading** (`LoadingView`), **Success** (`ListView.separated` + `RefreshIndicator`), **Empty** ("Weli deeq ma jirto" + "Baadh ololayaasha" → `/explore`, scrollable si pull-to-refresh u shaqeeyo), **Error** (`ErrorView` + retry → `ref.invalidate`).
- ✅ **Receipt (dib loo isticmaalay):** `DonationReceiptCard` waa la dib-qaabeeyay si uu u qaato fields tooska ah (amount/currency/isAnonymous/date/statusLabel?/methodLabel?/reference?/message?) halkii uu qaadan lahaa `DonationResult` — hadda **labada** `_SuccessView` (post-donation) iyo `DonationDetailScreen` (My Donations) hal card ayay wadaagaan. Ma jirto UI rasiid oo la soo celiyay. Detail-ku wuxuu tusaa status (midab leh) + reference; method maya (backend ma bixiyo).
- ✅ **Navigation ololaha:** deeq leh campaign id → "Eeg ololaha" button → `/campaign/:id` (`CampaignDetailsScreen` hore la isticmaalay). Campaign la tirtiray → note nabdoon "Ololahani mar dambe lama heli karo" halkii button.
- ✅ **Status:** `DonationStatusView` enum (`pending`/`confirmed`/`failed`/`refunded` + `unknown` fallback — status cusub lama abuurin). Label localized, midab + icon design-system.
- ✅ **Data/providers:** `MyDonation` + `MyDonationCampaign` models (dulqaad leh — campaign null marka la tirtiray, media URL resolver). `DonationRepository.getMyDonations()` lagu daray (repo labaad lama abuurin; `AppConfig` lagu daray constructor-ka media resolution). `myDonationsProvider` (`FutureProvider.autoDispose`), `myDonationByIdProvider` (`.family` — liiska ka akhri). Ma jiro API call widget gudihiis.
- ✅ **Auth:** My Donations = gal loo baahan yahay. Router-ku horeba wuu ilaaliyaa `/profile*` (guest → `/login` → `?from=` → dib u noqo). `_LoginGate` sidoo kale screen-ka gudihiis (difaac).
- ✅ **Localization:** ~25 fure cusub (Soomaali + Ingiriisi — 0 `@`-key ka maqan `app_so.arb`). Ma jiro string adag.
- ✅ **Error handling:** `presentError` + `AppException` hierarchy hore; unauthorized/network/timeout/server-error/empty/malformed-optional-fields la maareeyo (rukun qaldan → la boodo, ma throw-gareeyo). Ma jiro blank screen.
- ✅ **Tests (dhammaan pass):** `my_donations_test.dart` (unit — `MyDonation.fromJson` full/anonymous/deleted-campaign/missing-fields/media-resolve, `DonationStatusView.from` + fallback, `DonationRepository.getMyDonations` success + newest-first + media host + malformed-entry-skip + `ApiException` (500) + `NetworkException` (connectivity)) + `my_donations_screen_test.dart` (widget — loading→list, status render, anonymous, empty state, error+retry refetch, pull-to-refresh refetch, tap → receipt + reference, "Eeg ololaha" → `CampaignDetailsScreen`, deleted-campaign safe state, guest → `LoginScreen`). `flutter analyze` → **No issues found**. `flutter test` → **dhammaan pass**.
- ⚠️ **Limitations:** no pagination (full list load — OK inta tirada deeqaha hal user uu yar yahay); payment method aan la tusi karin history-ga; no per-donation endpoint (detail = list-derived); PAYMENT status text localized laakiin ma jiro webhook/async update.
- ➡️ **Xigta:** Organizer / Beneficiary / Withdrawal / Notifications (FCM) UI — mid.

## 0n. Mobile Donation + Payment (2026-08-30)

**Codsi:** Campaign Experience kadib — la dhiso waaya-aragnimada deeq-bixinta oo keliya: qadar → fariin → qarsoodi → dib-u-eegis → hab lacag-bixin → habaynta → success/pending/failed → rasiid. Backend-ka jira kaliya (0 isbeddel `server/**` / `client/**`). Ma la dhisin Organizer/Beneficiary/Withdrawal/Notifications/Admin.

- ✅ **Backend la baaray, 0 isbeddel:** `GET /api/v1/payments/config` (public → `{providers:['manual'](+‘evc_plus’ haddii WaafiPay configured), currency:'USD', minAmount:1}`), `POST /api/v1/campaigns/:id/donate` (`optionalAuth`, `donationRateLimiter` 30/5daq, `validate(createDonationSchema)` → `{amount:number>0 max 1_000_000, provider?:'manual'|'evc_plus', phone?:7–20, message?:≤500, isAnonymous?:bool}`, header `Idempotency-Key` → 201 `{donation, payment:{paymentId,status}, raisedAmount, note}`; `evc_plus` la'aan phone → `400 VALIDATION_ERROR`; campaign aan `PUBLIC_STATUSES` ku jirin → `400 CAMPAIGN_NOT_OPEN`; EVC decline → `402 PAYMENT_DECLINED` + fariin nadiif ah), `GET /api/v1/donations/mine` (`requireAuth`).
- ⚠️ **Xaddidaadaha backend (la sheegay, lama beddelin):** (1) Labada provider ee jira (`manual`, `evc_plus`) **synchronous** ayay yihiin — `manual` isla markiiba wuu is-xaqiijiyaa (offline/hawala style), `evc_plus` USSD-push synchronous. **Ma jirto `pending` dhab ah** hadda; screen-ku `pending` wuu maamulaa haddii provider mustaqbal ah uu soo celiyo `payment.status:'pending'`, laakiin ma jirto `GET /payments/:id` status-check endpoint. (2) **Fee calculation ma jirto backend-ka** → review-gu wuxuu tusaa "Khidmad: Ma jirto", Wadarta = qadarka. (3) **`evc_plus` dev-ka lagama heli karo** ilaa `WAAFIPAY_*` env la dejiyo → `manual` waa habka la tijaabin karo (donation dhab ah oo la diiwaan geliyo, lama been-abuurin). (4) Donate response-ku transaction reference gaar ah ma bixiyo → rasiidku wuxuu isticmaalaa `donation._id`. (5) `POST /donate` waa `optionalAuth` backend-ka, laakiin mobile-ku wuxuu u baahan yahay gal (rasiid + `donations/mine` + ogeysiis) — sidaas darteed flow-gu wuxuu leeyahay `_LoginGate` + `?from=` return.
- ✅ **Route cusub:** `/campaign/:id/donate` (`DonateFlowScreen`, nested `parentNavigatorKey: _rootKey`). Hal screen oo leh internal step-machine (`DonatePhase`: editing → review → processing → success/pending/failed) si xaaladdu u sii jirto marka "back / edit" la taabo — router-ka wax lagama gudbiyo. `PopScope` back: review/failed/pending → dib u eeg qadarka; success → ka bax; processing → xiran.
- ✅ **Screens/steps:** (1) **Amount** — `DonateCampaignHeader` (sawir + progress bar nool), preset chips [5/10/25/50/100], custom amount field (`DecimalAmountFormatter` — keystroke kasta la hubiyo, ≤2 decimal), fariin (`maxLength 500`), anonymous switch. (2) **Review** — qadar, fariin, muuqaal, `PaymentMethodSelector` (radio card list oo backend providers), phone field (kaliya `evc_plus`), "Khidmad: Ma jirto", Wadar, security note, "Deeq bixi {qadar}" / "Wax ka beddel". (3) **Processing** — spinner. (4) **Pending** — "Lacag-bixintaada waa la hawlgelinayaa" + "uma baahnid inaad mar labaad bixiso". (5) **Success** — `DonationReceiptCard` (olole/qadar/taariikh/hab/muuqaal/tixraac/fariin — xog backend kaliya, ma jiro macluumaad lacag-bixin gaar ah). (6) **Failed** — fariin cad + Isku day / Wax ka beddel / Ku noqo.
- ✅ **Data/domain:** `PaymentConfig`, `DonationResult` (+`DonationPaymentStatus` — `isConfirmed` = `payment.status=='confirmed' && donation.status=='confirmed'`; guul weligeed backend ayaa go'aamiya, ma aha in codsiga la aqbalay), `PaymentMethod` (provider-agnostic — id aan la aqoon weli wuu muuqdaa). `DonationApi` + `DonationRepository`. Providers: `donationApiProvider`, `donationRepositoryProvider`, `paymentConfigProvider` (FutureProvider cached), `donateControllerProvider` (`autoDispose.family`, auth-aware).
- ✅ **Idempotency:** `newIdempotencyKey()` (`Random.secure()` + microsecond ts — package cusub lama darin) → hal fure **isku-day kasta**. `Idempotency-Key` header la diro. Fure isku mid ah ayaa dib loo isticmaalaa retry kasta (double-tap / network retry / timeout / "Isku day mar kale") si aan lacag mar labaad loo qaadin; fure cusub kaliya marka isticmaaluhu "Wax ka beddel deeqda" doorto (isku-day cusub). Submit-ku waa single-flight (wicitaan labaad inta `processing` la joogo waa la iska indhatiraa); button la damiyo inta la hawlgelinayo.
- ✅ **Payment states:** INITIAL/editing → PROCESSING → PENDING | SUCCESS | FAILED. Maaraynta: user cancel (PopScope), timeout/network/provider error (`presentError` + `AppException`), duplicate submit (single-flight), pending, declined (`402` friendly message). **Weligeed SUCCESS llooma tuso ilaa backend uu xaqiijiyo.**
- ✅ **Campaign update:** deeq la xaqiijiyay kadib → `campaignDetailControllerProvider.refresh()` + `campaignSupportersProvider` invalidate (backend-ka laga soo qaato raised/progress/supporter count — client-side lama been-abuurin). Donate CTA (`CampaignActionBar`) hadda waa firfircoon marka `status.isOpenForDonations`, kelse "Deeqaha waa xiran yihiin" (disabled).
- ✅ **Auth:** view = public. Donate → `_LoginGate` (haddii aan la gelin) → `showLoginRequiredSheet` → `/login?from=/campaign/:id/donate` → guul kadib dib ayaa loo celiyaa flow-ga deeqda. Nidaam auth cusub lama abuurin.
- ✅ **Localization:** ~65 fure cusub (Soomaali + Ingiriisi labada — 0 `@`-key ka maqan `app_so.arb`). Ma jiro string adag. `errorCampaignNotOpen` lagu daray `presentError`.
- ✅ **Security:** phone/token/PIN/provider-response weligood lama log-gareeyo; `DonationReceiptCard` ma tuso xog lacag-bixin gaar ah (phone maya); amount/fees/status/balance = backend source of truth (client-side lama xisaabin); amount tampering — backend ayaa go'aamiya; `optionalAuth` donate + campaign-status guard backend-ka; Idempotency-Key replay guard.
- ✅ **Tests (dhammaan pass):** `donation_test.dart` (unit — parseAmount/formatAmount/`DecimalAmountFormatter`/idempotency-key uniqueness, `PaymentConfig`/`DonationResult` parse, amount validation ×4, preset, custom decimal, anonymous, message-too-long, config load + default provider, config failure non-fatal, goToReview guard, submit success/pending/failed/network, single-flight double-submit, idempotency-key stability across retry + regen on edit, unauth cannot submit) + `donation_flow_screen_test.dart` (widget — presets + Continue-enable, custom amount → review + payment methods, anonymous carried to review, confirmed → receipt + campaign refresh, declined → failure + retry, unauth → login gate). `flutter analyze` → **No issues found**. `flutter test` → **dhammaan pass**.
- ⚠️ **Limitations:** EVC Plus live charge = `WAAFIPAY_*` credentials loo baahan yahay (dev = `manual` provider, taas oo donation dhab ah diiwaan geliza oo is-xaqiijiza — lama been-abuurin); no true async/webhook pending path in current providers; no `GET /payments/:id` status-check endpoint; no server-side fee model; PAYMENT_DECLINED message = backend English text (Somali-ma-turjumaan — provider-specific).
- ➡️ **Xigta:** Organizer / Beneficiary / Withdrawal / Notifications (FCM) UI — mid.

## 0m. Mobile Campaign Experience (2026-08-30)

**Codsi:** Home + Explore kadib — la dhiso dhammaan waaya-aragnimada USER-ku campaign-ka ku daawado/kula falgalo hal marxalad: Details, Updates, Comments, Supporters/Donors, Share, Save, Follow/Unfollow, Report, navigation Home/Explore → Details. Backend-ka jira kaliya (0 isbeddel). Donation/Payment weli maya — Donate slot waa la reserve-gareeyay oo disabled.

- ✅ **Backend APIs la isticmaalay (0 isbeddel `client/**` ama `server/**`):** `GET /campaigns/:id` (optionalAuth, full doc, 404 haddii aan jirin/non-public), `GET /campaigns/:id/updates` (newest-first, no pagination), `GET /campaigns/:id/comments` (newest-first, no pagination), `POST /campaigns/:id/comments` (`requireAuth`, `{text}` 1–1000), `GET /campaigns/:id/donations?limit=` (`{items:[{amount,currency,message,createdAt,donorName|null}], supporterCount}` — confirmed kaliya, anonymous → `donorName:null`), `GET /campaigns/:id/interactions` (`requireAuth` → `{following,saved}`), `POST/DELETE /campaigns/:id/follow` + `/save`, `POST /reports` (`requireAuth`, `{targetType:'campaign', targetId, reason(5–500 free text)}`).
- ⚠️ **Backend gaps (la sheegay, lama beddelin, lama been-abuurin):** (1) Updates-ku **title ma laha** — `text` kaliya (min 10); tile-ku wuxuu tusaa taariikh + qoraal. (2) Updates/comments **author name ma populate-gareeyaan** → comment-ku "You" (userId==me) ama "Supporter" ayuu tusaa, ma tuso magac. (3) Updates/comments/donations **pagination ma laha** → hal jeer la soo dejiyo; comment cusub `prepend`. (4) `POST /reports` **reason enum ma laha** → client-ku wuxuu bixiyaa 6 category (`ReportReason` enum, `backendPhrase` ≥5 char) + faahfaahin ikhtiyaari ah, isku dar → hal `reason` string ≤500. (5) `organizerId` ma populate-gareeyo → organizer/beneficiary card lama tuso (N+1 request lama sameeyo). (6) Donor count-ku wuxuu ka yimaadaa `/donations.supporterCount` (list la heli waayo → count kaliya la tusaa).
- ✅ **Screens (4 route):** `/campaign/:id` `CampaignDetailsScreen` (SliverAppBar: back/share/`⋮`→Report · hero cover + media gallery counter · summary: title/category·subcategory·region/raised·goal/progress/supporter line/end date · status banner completed/suspended/frozen/cancelled/expired · trust badges · story expand/collapse · Updates preview [2 + "See all N"] · Supporters preview [3 + "See all N"] · Comments nav row · sticky `CampaignActionBar`: Save/Share/Follow + **disabled Donate slot** "Donate"/"Donations closed"). `/campaign/:id/updates` `CampaignUpdatesScreen`. `/campaign/:id/comments` `CampaignCommentsScreen` (list + `CommentComposer` haddii la galay, kelse "sign in to comment"). `/campaign/:id/supporters` `CampaignSupportersScreen` (count headline + "recent only" note + tiles). Dhammaan sub-routes `parentNavigatorKey: _rootKey` (full-screen, bottom nav la'aan). Back navigation → `context.pop()` ama `/home`.
- ✅ **Models:** `CampaignUpdate` (`{id,text,imageUrl?,createdAt?}`), `CampaignComment` (`{id,userId,text,createdAt?}` + `isMine`), `Supporter` (`{id,amount,currency,donorName?,message?,createdAt?}` + `isAnonymous`) & `SupporterList` (`{items,supporterCount}`), `CampaignInteractions` (`{following,saved}`). Dhammaan `fromJson` waa dulqaad leh (media URL resolver la wadaago).
- ✅ **Domain:** `CampaignBadge` enum (identity/beneficiary/organization/payment verified — icon + localized label, `parseBadges` unknown iska tuura), `CampaignStatusView` enum (`isOpenForDonations`, `needsBanner`, `isNegative`, localized `label`/`bannerMessage`), `ReportReason` enum (6 category → `backendPhrase` + `compose(explanation)` cap 500).
- ✅ **Data layer:** `CampaignApi` + `CampaignRepository` la ballaariyay (`getCampaign/getUpdates/getComments/postComment/getSupporters/getInteractions/setFollowing/setSaved/reportCampaign`). Ma jiro API call widget gudihiis; ma jiro N+1.
- ✅ **State (Riverpod):** `campaignDetailControllerProvider` (`.autoDispose.family` — campaign + interactions [haddii la galay, non-fatal], **follow/save NON-optimistic**: button spinner → await → isbeddel guul kaliya; fashil → `mutationError` snackbar, xaaladdii hore lama lumin), `campaignUpdatesProvider`/`campaignSupportersProvider` (`FutureProvider.autoDispose.family`), `campaignCommentsControllerProvider` (load + `submit` — empty/over-1000/double-submit hor-istaag, guul → prepend), `shareServiceProvider`.
- ✅ **Share:** `ShareService` abstraction (`SharePlusService` → `share_plus` 13.3.0 — **hal package cusub oo la daray**), content = title + excerpt(160) + `${webBaseUrl}/campaigns/:id` (`AppConfig.webBaseUrl` cusub, `--dart-define=WEB_BASE_URL`).
- ✅ **Auth behavior:** view = public (auth la'aan). Follow/Save/Comment/Report = `_guarded()` → `showLoginRequiredSheet` → `/login?from=/campaign/:id` → guul kadib dib ayaa loo celiyaa campaign-ka (router redirect `from` param). Ma jiro crash marka aan la gelin.
- ✅ **Localization:** ~95 fure cusub (Soomaali + Ingiriisi labada — 0 `@`-key ka maqan `app_so.arb`). Ma jiro string adag. Fure kaliya marxaladdan loo baahday ayaa la daray.
- ✅ **Error/empty states:** meel kasta — `LoadingView`/`EmptyView`/`ErrorView`+retry, `presentError` + `AppException` hierarchy ee hore. Ma jiro blank screen. Details-ku wuxuu leeyahay `_Chrome` (back bar) loading/error labadaba.
- ✅ **Tests (dhammaan pass):** `campaign_detail_test.dart` (unit — model parsing ×5, badges, status, report reason compose/cap, `CampaignDetailController` load success/error + follow/save toggle + failure-keeps-state + unauth-blocked, `CampaignCommentsController` load/error/empty-reject/over-long-reject/prepend/error-return) + `campaign_detail_screen_test.dart` (widget — renders+action bar, error+retry, verification badges, completed banner + "Donations closed", missing cover placeholder, long story expand, anonymous supporter, follow requires auth [login sheet], authed follow, share URL, report flow menu→reason→submit→"Report received", navigate → updates sub-screen, Home card → details → back → Home) + `home_explore_screen_test.dart` navigation (Home/Explore card → `CampaignDetailsScreen`). `flutter analyze` → **No issues found**. `flutter test` → **dhammaan pass**.
- ⚠️ **Limitations:** update title / author names / pagination / report-reason enum ma jiraan backend-ka (kor eeg); organizer & beneficiary info lama tuso (`organizerId` un-populated, N+1 lama sameeyo); Donate = disabled placeholder (marxaladda xigta); media gallery = cover + `mediaUrls` (list endpoint dheeraad ma jiro).
- ➡️ **Xigta:** DONATION + PAYMENT.

## 0l. Mobile Home + Explore (2026-08-30)

**Codsi:** Auth kadib — la dhiso Home & Explore dhab ah oo campaign discovery ah. Backend-ka jira kaliya, wax lama beddelin. Campaign Details, Donate, Organizer, Beneficiary weli maya.

- ✅ **Backend APIs la isticmaalay (0 isbeddel):** `GET /api/v1/campaigns` (`?category&region&q&page&limit` → `{items,total,page,limit}`, weligeed public statuses, newest-first) + `GET /api/v1/campaigns/stats` (`{totalRaised,campaignCount,donorCount}`).
- ⚠️ **APIs aan jirin (la sheegay, lama been-abuurin):** (1) featured/trending endpoint ma jiro — "Featured" = campaign la xaqiijiyay marka hore, "Recent" = liiska newest-first. (2) `sort` param ma jiro. (3) Categories endpoint ma jiro — `kCampaignCategories` (14, isku mid enum-ka backend); regions constant (`Mogadishu/Hargeisa/Puntland/Nairobi`, sida web-ka). (4) `?status=` / `?verified=` list-ka laguma taageero → status/verified filter lama sameyn (client-side filter khaldan noqon lahaa dataset weyn). (5) List-ku organizer/donor-count ma populate-gareeyo → card-ku ma tuso organizer name / donor count.
- ✅ **Screens:** `HomeScreen` (brand + greeting + search entry + stats strip + Featured carousel + Categories + Recent + View all) · `ExploreScreen` (search + category chips + region dropdown + paginated list + infinite scroll + pull-to-refresh + loading/empty/error). `MainShell` bottom nav (Home/Explore/Profile).
- ✅ **Widgets:** `CampaignCard` (real, maps `Campaign` → `CampaignCardShell`), `CampaignCardShell` (cusboonaysiiyay: `NetworkImageBox` + status pill + location), `NetworkImageBox` (loading placeholder + broken fallback + `cacheWidth`), `CategoryChips`, `SearchField` (reusable, clear button), `HomeSearchBar`, `SectionHeader`, `StatsStrip`, `AppProgressBar` (overflow-safe: `Expanded` + ellipsis).
- ✅ **Models:** `Campaign` (tolerant `fromJson`, `progress` calc oo nabdoon — zero-goal→0, over-goal→clamp 1, no NaN/Infinity), `CampaignPage` (`hasMore`), `PlatformStats`.
- ✅ **Data layer:** `CampaignApi` → `CampaignRepository` (maps JSON, `resolveMediaUrl` — `localhost`/`127.0.0.1`/`10.0.2.2` upload URLs → API host si sawirradu ugu shaqeeyaan device-ka). Ma jiro API-call widget gudihiis.
- ✅ **State:** Riverpod. `homeFeedProvider` (FutureProvider — page 1 + stats, stats-failure non-fatal). `ExploreController` (`StateNotifier<ExploreState>`): search **debounce 400ms** + stale-request guard (monotonic token) + `CancelToken` cancellation, category/region filters (reload page 1), `loadMore` pagination (page size 20), `refresh` (pull-to-refresh).
- ✅ **Localization:** ~40 fure cusub (Home/Explore/categories/regions/stats) — Soomaali + Ingiriisi. Ma jiro string adag.
- ✅ **Error handling:** `presentError` / `AppException` ee hore la isticmaalay — ma jiro nidaam labaad.
- ✅ **Performance:** pagination, lazy `ListView`/slivers, debounce, `Image` in-memory cache + `cacheWidth`, stale-search cancellation. Package weyn lama darin (disk image cache = mustaqbal).
- ✅ **Tests (59/59 pass):** `campaign_test` (model parsing/edge, progress calc, repository success/error via stub Dio adapter, resolveMediaUrl), `explore_controller_test` (init, debounce, category filter, pull-to-refresh, pagination/loadMore, error state), `home_explore_screen_test` (Home loading/success/empty/error+retry, Explore via bottom nav, card missing-image, card progress calc, zero-goal, navigation → `/campaign/:id`). `flutter analyze` → **No issues found**.
- ⚠️ **Limitations:** organizer identity & per-campaign donor count aan la tusi karin (list endpoint ma populate-gareeyo); no server sort/trending; status/verified filters aan la taageerin; `/campaign/:id` weli placeholder; disk image cache lama darin.

## 0k. Mobile Authentication (2026-08-30)

**Codsi:** Aasaaska Flutter kadib — la dhiso auth-ka dhabta ah. Isticmaal backend-ka jira, wax backend ah lama beddelin. Scope: authentication oo keliya (Home/Donate/Organizer weli maya).

- ✅ **Backend contract la xaqiijiyay — 0 isbeddel backend ah loo baahday.** `POST /auth/{login,register,refresh,verify-email-otp,resend-verification-email,forgot-password,reset-password}` + `GET /users/me`. `POST /auth/logout` MA JIRO → local-only cleanup (raac backend limitation).
- ✅ **Screens (6):** `SplashScreen` (session resolution — bootstrap + router redirect), `LoginScreen`, `RegisterScreen` (fullName/email/phone/password/confirm + terms checkbox), `VerifyEmailScreen` (OTP + resend + 60s cooldown), `ForgotPasswordScreen` (email → neutral confirmation), `ResetPasswordScreen` (email+code+newpass → success → login). Placeholder screens-ka `/home` iyo `/profile` waxay hadda leeyihiin `LogoutAction`.
- ✅ **Reusable auth components:** `AuthScaffold` + `AuthSwitchPrompt`, `AuthErrorBanner` (error/info/success tones), `OtpInput` (6-god, auto-submit on complete), `LogoutAction` (confirm dialog), `Validators` (email/password/confirm/name/phone/code6), `presentError()` (AppException → hal localized message; backend codes → Somali/English, kuwa kale → backend message).
- ✅ **AuthController la ballaariyay:** login/register/verifyEmailOtp/resendVerificationEmail/forgotPassword/resetPassword/logout/markSessionExpired/acknowledgeSessionExpired. `AuthState`: unknown → authenticated/unauthenticated (+ `sessionExpired` flag).
- ✅ **Routing:** `/verify-email` route cusub. Redirect guard: authenticated + `!emailVerified` → `/verify-email` (qasab, sida web-ka). authenticated + verified + guest-route → `/home`. unauthenticated + protected → `/login`.
- ✅ **Token refresh (dhab ah la test-gareeyay):** 401 → single-flight refresh (`TokenRefresher` + bare Dio) → retry hal mar → guul → sii wad. Refresh fashilma → `AuthEvents.notifySessionExpired` → `AuthController` → session la nadiifiyay → `/login` + banner "Fadhigaagu wuu dhammaaday". Retry hal mar oo keliya (ma jiro loop).
- ✅ **Security:** tokens secure storage kaliya (`FlutterSecureStorage`); token/password/OTP weligood laguma log-gareeyo; forgot-password weligeed ma sheegto in email jiro (backend + UI); duplicate-submit la hor-istaagay (`_submitting` guard); session dhicay si nabdoon loo maareeyo.
- ✅ **Localization:** ~55 fure cusub oo auth ah — Soomaali + Ingiriisi labadaba. Ma jiro string adag oo widget ku dhex qoran. Arabic/RTL wali diyaar.
- ✅ **Tests (31/31 pass):** `auth_flow_test.dart` (17 — routing×3, login×4, register×3, forgot/reset×3, verify×2, logout×1), `token_refresh_test.dart` (5 — 401→refresh→retry, retry-once, refresh-fail→session-expired, single-flight, no-token/reject), `widget_test.dart` (4), `api_exception_mapper_test.dart` (5). `test/support/` fakes + stub Dio adapter. `flutter analyze` → **No issues found**.
- ⚠️ **Limitations:** (1) `POST /auth/logout` ma jiro backend-ka → local cleanup kaliya (refresh token wuu dhici doonaa 30d gudahood; access token 15min). (2) Phone verification backend-ku `501` ayuu yahay → screen lama dhisin. (3) Unverified user waa in uu iimayl xaqiijiyo si uu ugu gudbo (isla web-ka); "Mar dambe" = logout — marka Home la dhiso waxaa laga yaabaa in loo beddelo banner.

## 0j. Flutter Mobile Foundation (2026-08-30)

**Codsi:** Backend preparation waa dhammaatay. Hadda la bilaabo Flutter app-ka. TALAABADA KOWAAD OO KELIYA: la sameeyo oo la habeeyo aasaaska app-ka mobile-ka. Ma la dhisin Home/Donate/Organizer/Beneficiary screens.

- ✅ **Mashruuc cusub `mobile/`** — `flutter create` (Flutter 3.47.2 / Dart 3.13.2), package `kaalmo_mobile`, org `com.kaalmo`, platforms `android,ios`.
- ✅ **Packages (5, sabab cad):** `dio` (HTTP), `flutter_secure_storage` (tokens — ma aha SharedPreferences), `go_router` (routing + auth guard), `flutter_riverpod` (session/locale state + DI), `intl`/`flutter_localizations` (ARB). **Firebase weli lama darin** — architecture-ka kaliya (abstract `PushService` + `DeviceApi`); `firebase_messaging` waxaa la dari doonaa marxaladda notification-ka.
- ✅ **Qaab-dhismeed:** `lib/core/{config,constants,errors,network,storage,theme,localization,router,push,di}` + `lib/features/{auth,notifications,...}` (`data/application/presentation` layers) + `lib/shared/{buttons,inputs,cards,widgets,states}` + `main.dart` + `app.dart`.
- ✅ **API client (Dio):** base URL config, JSON, 15s/20s timeouts, `AuthInterceptor` (Bearer inject → 401 → single-flight refresh via bare-Dio `TokenRefresher` → retry hal mar → haddii fashilo `AuthEvents` session-expired), `ApiExceptionMapper` → `{error:{code,message,fields}}` → hal `AppException` hierarchy (Api/Network/Timeout/Unexpected). Cycle-ka provider-ka waxaa lagu jebiyay `AuthEvents` event bus + `TokenRefresher`.
- ✅ **Secure storage:** `SecureTokenStore` (access/refresh/user-json/locale) — keystore/keychain kaliya.
- ✅ **Auth foundation (screens LA'AAN):** `AuthUser`/`AuthSession`/`TokenPair` models (toPublicUser shape), `AuthApi` (login/register/refresh/forgot/reset/verify-email/resend/verify-phone/me), `AuthRepository`, `AuthController` (Riverpod `Notifier<AuthState>`: unknown/authenticated/unauthenticated + sessionExpired).
- ✅ **Theme:** Material 3 light+dark `ColorScheme` (`ColorScheme.fromSeed` + palette copyWith), `AppColors` tokens (dhammaan 12-ka midab ee la bixiyay), Inter + system fallback (font binary lama bundle-gareyn).
- ✅ **Localization:** `l10n.yaml` + `app_en.arb` + `app_so.arb` (~35 fure aasaasi ah), `AppL10n` generated (`lib/core/localization/generated/`), `LocaleController` (persist secure storage). Arabic/RTL diyaar — `app_ar.arb` kaliya loo baahan yahay.
- ✅ **Routing (GoRouter):** `/splash /login /register /forgot-password /reset-password /home /explore /campaign/:id /donate /organizer /beneficiary /notifications /profile` — `SplashScreen` dhab ah, inteeda kale `PlaceholderScreen` la wadaago; redirect guard oo ku xiran `AuthController` (`refreshListenable`).
- ✅ **Env config:** `AppConfig` + `AppEnvironment{development,staging,production}` `--dart-define=ENV/API_BASE_URL`. Base URL-yadu waa constants aan qarsoodi ahayn; API keys/secrets/Firebase creds weligood code-ka kuma jiraan. `.gitignore` waxaa lagu daray `google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`.
- ✅ **Push foundation:** `PushService` (abstract) + `NoopPushService`, `DeviceApi` (`POST/DELETE/GET /api/v1/devices`), `DeviceRegistrar` (syncOnLogin/unregisterOnLogout/token-rotation). Firebase package LA'AAN.
- ✅ **Shared widgets:** PrimaryButton, SecondaryButton, AppTextButton, AppTextField, PasswordField, CampaignCardShell, VerificationBadge, AppProgressBar, LoadingView, EmptyView, ErrorView, SuccessView.
- ✅ **Tests:** `widget_test.dart` (app boots → splash → routes to /login, theme primary = #0B7189, AuthController unknown, GoRouter constructable) + `api_exception_mapper_test.dart` (5 error-mapping cases). **`flutter analyze` → No issues found. `flutter test` → 9/9 passed.**
- ⚠️ **Lama taaban:** web frontend (`client/`), backend (`server/`), withdrawal, admin. Ma jiro backend audit cusub.
- ➡️ **Xigta:** AUTHENTICATION — LOGIN + REGISTER.

## 0i. Payment hardening + FCM push notification backend (2026-08-30)

**Codsi:** Ka hor Flutter, laba awood oo backend ah oo kaliya: (1) payment provider integration la xaqiijiyo/la adkeeyo, (2) push notifications (FCM). Kadib backend feature development waa la joojiyaa.

### Payment (isticmaal abstraction-ka jira — lama dib u dhisin)
- ✅ **Idempotency** — `POST /campaigns/:id/donate` hadda waxay aqbashaa `Idempotency-Key` header. Codsi la celiyay oo isku fure ah → natiijadii hore ayaa la soo celiyaa, lacag mar labaad lama qaado. `Payment.idempotencyKey` (sparse) cusub.
- ✅ **Donation body validation dhab ah** — `donationValidators.js` cusub (`createDonationSchema`); route-ka wuxuu hadda leeyahay `validate(...)`. Currency weligeed llooma aqbalo client — waxaa laga qaataa campaign-ka.
- ✅ **Audit actorType saxan** — donation-ka donor-ku sameeyo hadda `actorType: 'user'` (ama `'system'` guest), ma aha default-kii `'admin'`.
- ✅ **`GET /api/v1/payments/config`** (public) → `{ providers, currency, minAmount }` — si mobile-ku uusan u hard-code garayn provider (sida web `Donate.jsx` u sameeyo).
- ✅ **`waafiPayClient.js` cusub** — HTTP transport-ka WaafiPay laga soocay adapter-ka si loo test-gareeyo states-ka (approved/declined/timeout/malformed/501) — dhaqan isbeddel ma jiro.
- ✅ **`.env.example`** — `WAAFIPAY_*` names lagu daray (comment: la'aan → 'evc_plus' 501, 'manual' wali shaqeeya).
- ⚠️ **Ma la dhisin webhook infrastructure** — labada provider ee jira (`manual`, `evc_plus`) waa synchronous, webhook uma baahna. `PaymentService.handleWebhook` wuxuu sii yahay seam mustaqbal.
- ⚠️ **Live EVC Plus charge lama tijaabin** — u baahan taleefan dhab ah + PIN + lacag dhab ah. Credentials-ka `.env` gudahood way jiraan (magac kaliya la xaqiijiyay); dhammaan code paths-ka HTTP-ga la mock-gareeyay ayaa la test-gareeyay.

### Push notifications (FCM) — Constitution §62/§87 waxay dhihi jireen "no FCM for MVP"; user-ku si cad ayuu u codsaday marxaladda mobile
- ✅ **`DeviceToken` model cusub** — `{ userId, token(unique), platform, lastSeenAt }`. Qof kasta wuxuu yeelan karaa device badan; token la re-register gareeyo → user hadda leh ayaa la siiyaa.
- ✅ **`fcmService.js` cusub** — `firebase-admin` lazy init env-ka kaliya; `sendToUser(userId,{title,body,data})`; multicast; **invalid token cleanup** (FCM `registration-token-not-registered` → `DeviceToken.deleteMany`); la'aan configured → no-op; credentials weligood laguma log-gareeyo.
- ✅ **`notificationService.notifyUser` la kordhiyay** — Notification (in-app) wuu keydiyaa sida hore, kadibna push (fire-and-forget) wuu diraa. Dhacdo cusub oo la xiro looma baahna — 10-ka goobood ee `notifyUser` ka wacaan (donation, campaign approve/reject/suspend, goal reached, update, withdrawal, beneficiary, account status, team invite, support) si toos ah ayay push u helaan.
- ✅ **`deviceTokenController.js` + `deviceRoutes.js` cusub** — `POST/DELETE/GET /api/v1/devices` (`requireAuth`, caller-scoped). `deviceValidators.js` cusub.
- ✅ **`User.pushEnabled`** (default `true`) — master switch, `PATCH /users/me` ku maareyn karo; `toPublicUser` wuu soo celiyaa.
- ✅ **`firebase-admin`** package (kaliya mid — FCM waxay u baahan tahay SDK-gan ama OAuth2 gacanta lagu qoray).
- ✅ **`.env.example`** — `FIREBASE_PROJECT_ID/CLIENT_EMAIL/PRIVATE_KEY` names lagu daray.
- ⚠️ **Real device delivery lama tijaabin** — u baahan Firebase project dhab ah + token dhab ah. Dhammaan wiring-ka (register/remove/multi-device/cleanup/dispatch/no-leak) firebase-admin la mock-gareeyay ayaa la test-gareeyay.

### Test setup la cusboonaysiiyay
- `test/globalSetup.js` cusub — hal `MongoMemoryServer` oo dhammaan faylalka la wadaago (ka hor kasta oo fayl mongod-kiisa bilaabo → gaabis + flaky).
- Faylal cusub: `test/payment.test.js` (28 test), `test/pushNotifications.test.js` (18 test).
- **Wadar: 65 test, dhammaan waa pass** (auth.passwordReset 19 + payment 28 + push 18).

### Xaddidaadaha hadhay (mobile blocker ma aha)
- EVC Plus live charge + FCM live delivery: manual QA / production credentials ayaa loo baahan yahay.
- Webhook + reconciliation job: looma baahna providers-ka hadda; mustaqbalka provider async haddii la daro.

---

## 0h. Password reset / forgot-password — backend (2026-08-30)

**Codsi:** Mobile-ka (Flutter) ka hor, backend-ka la diyaariyo. Tallaabada koowaad: `forgot-password` / `reset-password` oo aan hore u jirin. Isticmaal API isku mid ah web + mobile — ma jiro endpoint gaar ah oo mobile.

- ✅ **`POST /api/v1/auth/forgot-password`** `{ email }` → had iyo jeer `200 { sent: true }` (weligeed ma sheegto in email-ku diiwaan gashan yahay iyo in kale — user enumeration lama oggola). Haddii akoonku jiro oo `active` yahay, lambar 6-god ah ayaa la emailiyaa (15 daqiiqo).
- ✅ **`POST /api/v1/auth/reset-password`** `{ email, code, password }` → `200 { reset: true }`. Furaha cusub `bcrypt` (cost 12, sida `register`). `emailVerified = true` (lambarka la helay wuxuu caddeeyaa gacan-ku-haynta email-ka). **Ma soo celiyo token** — user-ku waa inuu dib u galo.
- ✅ **Verification model dib loo isticmaalay** — `type: 'password_reset'` cusub; `attempts` field cusub. Lambarka waxaa loo keydiyaa **bcrypt hash oo keliya** (plaintext-ka weligeed lama keydiyo, lamana log-gareeyo). Codsi cusub → lambarkii hore ee `pending` waa la buriyaa (`rejected`).
- ✅ **Rate limiting** — `passwordResetRateLimiter` cusub: **5 codsi / 60 daqiiqo / IP** (labada route). Dheeraad: **3 codsi / 15 daqiiqo per-account** oo `authService` gudihiisa lagu xaqiijiyo.
- ✅ **Attempt limit** — ugu badnaan **5 isku-day khaldan** per lambar; kadib lambarku waa la gubaa (`rejected`). Mid-mar-la-isticmaalo (single-use): guusha kadib `status: 'approved'`.
- ✅ **Session invalidation** — `User.passwordChangedAt` cusub; `authService.refresh()` wuxuu diidaa refresh token kasta oo la sameeyay ka hor dib-u-dejinta (Constitution Sec. 24/25). Access token-ka (15 daqiiqo) si dabiici ah ayuu u dhacaa.
- ✅ **Audit logging** — `auth.password_reset_requested` + `auth.password_reset_completed` (`actorType: 'user'` cusub `AuditLog` enum-ka). Lambarka/furaha weligood laguma qoro logs/metadata.
- ✅ **Error format** — dhammaan `ApiError` → qaabka `{ error: { code, message, fields } }`. Dhammaan sababaha guul-darrada `reset-password` (email aan jirin, lambar khaldan, dhacay, isku-day badan) waxay soo celiyaan `400 INVALID_CODE` isku mid ah; fure daciif ah → `400 VALIDATION_ERROR`.
- ✅ **Test setup dhab ah la daray** — `vitest` + `supertest` + `mongodb-memory-server`, `npm test` script, `server/test/auth.passwordReset.test.js` (19 test): request, unknown email, suspended user, per-account throttle, guul, old-password rejected, code reuse, wrong-code attempt limit, expired code, weak password, unknown email @ reset, refresh-token invalidation, IP rate limit, audit-log-without-secrets, iyo **regression**: register/login/refresh + email OTP + organizer OTP + resend-verification.
- ⚠️ Existing email-verification iyo organizer OTP flows **lama taaban** — weli plaintext-code ayay keydiyaan (regression test ayaa xaqiijiya).
- ⚠️ Frontend lama taaban — web-ku weli ma laha "Forgot password?" link (mobile + web UI tallaabo kale).

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
