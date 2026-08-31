import 'dart:io' show Platform;

import 'push_message.dart';

/// Whether the OS will actually deliver push notifications to the user.
enum PushPermission { granted, denied, notDetermined }

/// Abstraction over the push-notification provider.
///
/// [FcmPushService] is the real Firebase Cloud Messaging implementation;
/// [NoopPushService] is used in tests and whenever Firebase is not configured
/// on the device (no `google-services.json`) so the rest of the app — including
/// in-app notifications — keeps working unchanged.
abstract interface class PushService {
  /// Initialise the SDK and wire the message listeners. Safe to call once.
  /// Must never throw — a missing/broken Firebase config degrades to a no-op.
  Future<void> init();

  /// Ask the OS for notification permission (Android 13+ / iOS). Returns the
  /// resulting status. Calling again when already decided is cheap and does not
  /// re-prompt.
  Future<PushPermission> requestPermission();

  /// Current permission status without prompting.
  Future<PushPermission> permissionStatus();

  /// The current device token, or null when unavailable / permission not
  /// granted / Firebase not configured. Never logged.
  Future<String?> getToken();

  /// Emits a new token whenever the provider rotates it.
  Stream<String> get onTokenRefresh;

  /// Emitted when the user taps a notification and the app was already running
  /// (foreground or background). Cold-start taps come through [initialMessage].
  Stream<PushMessage> get onMessageOpened;

  /// Emitted for messages received while the app is in the foreground.
  Stream<PushMessage> get onForegroundMessage;

  /// The notification tapped to launch the app from a terminated state, if any.
  /// Consumed once.
  Future<PushMessage?> initialMessage();

  /// Best-effort local teardown on logout (does not call the backend).
  Future<void> deleteToken();
}

/// Platform tag sent to `POST /api/v1/devices`.
String currentPushPlatform() {
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'web';
}

/// Default implementation — used in tests and when Firebase is not configured.
class NoopPushService implements PushService {
  const NoopPushService();

  @override
  Future<void> init() async {}

  @override
  Future<PushPermission> requestPermission() async => PushPermission.notDetermined;

  @override
  Future<PushPermission> permissionStatus() async => PushPermission.notDetermined;

  @override
  Future<String?> getToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();

  @override
  Stream<PushMessage> get onMessageOpened => const Stream.empty();

  @override
  Stream<PushMessage> get onForegroundMessage => const Stream.empty();

  @override
  Future<PushMessage?> initialMessage() async => null;

  @override
  Future<void> deleteToken() async {}
}
