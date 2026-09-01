import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_message.dart';
import 'push_service.dart';

/// Background / terminated-state message handler. Must be a top-level function
/// annotated `@pragma('vm:entry-point')` — it runs in a separate isolate.
///
/// Android already shows the tray notification for messages that carry a
/// `notification` block, so there is nothing to display here. We only need this
/// registered so the plugin sets up the background channel; the tap is handled
/// later via `getInitialMessage()` / `onMessageOpenedApp`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Runs in its own isolate. Ensure Firebase is available in this context —
  // the plugin usually does this, but calling it guarded is safe and avoids a
  // silently-thrown "no Firebase app" if that ever changes.
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  } catch (_) {/* already initialised / not configured */}

  // Nothing to display here: messages carry a `notification` block, so Android
  // shows the system-tray notification itself. The tap is handled on next
  // launch via getInitialMessage() / onMessageOpenedApp.
  if (kDebugMode) {
    debugPrint('[FCM bg] message ${message.messageId} '
        'hasNotification=${message.notification != null} dataKeys=${message.data.keys.toList()}');
  }
}

/// Firebase Cloud Messaging implementation of [PushService].
///
/// Assumes `Firebase.initializeApp()` already ran in `main()` (guarded). If it
/// did not — no `google-services.json` on the device — every method is a safe
/// no-op and the app falls back to in-app notifications only.
class FcmPushService implements PushService {
  FcmPushService();

  final _foreground = StreamController<PushMessage>.broadcast();
  final _opened = StreamController<PushMessage>.broadcast();
  bool _wired = false;

  bool get _available => Firebase.apps.isNotEmpty;

  FirebaseMessaging get _fm => FirebaseMessaging.instance;

  @override
  Future<void> init() async {
    if (!_available || _wired) return;
    _wired = true;
    try {
      // Background handler is registered in main() (before runApp).
      await _fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen((m) => _emit(_foreground, m));
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _emit(_opened, m));
    } catch (e) {
      if (kDebugMode) debugPrint('[FcmPushService] init failed: $e');
    }
  }

  void _emit(StreamController<PushMessage> c, RemoteMessage m) {
    if (c.isClosed) return;
    c.add(PushMessage.fromData(
      m.data,
      title: m.notification?.title,
      body: m.notification?.body,
    ));
  }

  @override
  Future<PushPermission> requestPermission() async {
    if (!_available) return PushPermission.notDetermined;
    try {
      final settings = await _fm.requestPermission();
      return _map(settings.authorizationStatus);
    } catch (_) {
      return PushPermission.notDetermined;
    }
  }

  @override
  Future<PushPermission> permissionStatus() async {
    if (!_available) return PushPermission.notDetermined;
    try {
      final settings = await _fm.getNotificationSettings();
      return _map(settings.authorizationStatus);
    } catch (_) {
      return PushPermission.notDetermined;
    }
  }

  PushPermission _map(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized => PushPermission.granted,
        AuthorizationStatus.provisional => PushPermission.granted,
        AuthorizationStatus.denied => PushPermission.denied,
        AuthorizationStatus.notDetermined => PushPermission.notDetermined,
      };

  @override
  Future<String?> getToken() async {
    if (!_available) return null;
    try {
      return await _fm.getToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<String> get onTokenRefresh =>
      _available ? _fm.onTokenRefresh : const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpened => _opened.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => _foreground.stream;

  @override
  Future<PushMessage?> initialMessage() async {
    if (!_available) return null;
    try {
      final m = await _fm.getInitialMessage();
      if (m == null) return null;
      return PushMessage.fromData(m.data,
          title: m.notification?.title, body: m.notification?.body);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    if (!_available) return;
    try {
      await _fm.deleteToken();
    } catch (_) {/* best effort */}
  }
}
