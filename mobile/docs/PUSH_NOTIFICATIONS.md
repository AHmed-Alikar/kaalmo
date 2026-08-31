# Push notifications (FCM) — setup & test

The Flutter client is fully wired. Two things must be supplied out-of-band before
real push notifications are delivered — neither is in source control.

## 1. Android app configuration

1. In the [Firebase console](https://console.firebase.google.com/), create (or open)
   the Kaalmo project and add an **Android app** with package name
   `com.kaalmo.kaalmo_mobile`.
2. Download `google-services.json` and drop it at:

   ```
   mobile/android/app/google-services.json
   ```

   It is git-ignored. Its presence auto-enables the Google Services Gradle plugin
   (`android/app/build.gradle.kts`), so nothing else changes.
3. Rebuild: `flutter build apk --debug`.

Without this file the app still builds and runs — `Firebase.initializeApp()` fails
quietly and the app uses in-app notifications only.

> iOS is not wired in this phase (no `GoogleService-Info.plist`, no APNs key).

## 2. Backend service account

The backend sends pushes via `firebase-admin`. Set these in the server
environment (from the Firebase service-account JSON key — see
`server/.env.example`):

```
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
```

Without them `fcmService` is a silent no-op; in-app notifications still work.

## 3. Real-device verification plan

Automated tests cover the wiring with fakes; they cannot prove FCM delivery.
On a real Android device with `google-services.json` in place and the backend
configured:

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| A | App open (foreground) | Trigger a backend `notifyUser` (e.g. confirm a donation) | In-app feed refreshes, bell badge increments, a SnackBar with an **Open** action appears |
| B | App backgrounded | Home button, then trigger the event | Notification appears in the Android tray on the "General" channel with the Kaalmo icon |
| C | App terminated | Swipe the app away, then trigger the event | Notification appears in the tray |
| D | Tap → route | Tap a donation notification | App opens on the campaign; a campaign-update notification opens Updates; an organizer notification opens the organizer area |
| E | Tap while logged out | Log out, trigger + tap a notification whose target needs auth | Lands on Login; after logging in, the original destination opens |
| F | Logout hygiene | Log out on the device | `DELETE /devices` is called; the previous user stops receiving pushes on this device |
| G | Login as another user | Sign in with a different account | `POST /devices` re-registers the token under the new user |
| H | Permission denied | Deny the OS notification prompt | App keeps working; in-app notifications unaffected; no repeat prompt |

Sending a test message directly: Firebase console → Cloud Messaging → "Send test
message", paste the device's FCM token (log it only in a debug build).
