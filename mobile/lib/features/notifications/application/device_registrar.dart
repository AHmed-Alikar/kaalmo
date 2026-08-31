import 'dart:async';

import '../../../core/push/push_service.dart';
import '../data/device_api.dart';

/// Keeps the backend's copy of this device's push token in sync.
///
/// Call [syncOnLogin] after authentication and [unregisterOnLogout] before
/// clearing the session. Token rotations are handled automatically once
/// [start] has been called. Every backend call is best-effort — a failure
/// here must never block auth.
class DeviceRegistrar {
  DeviceRegistrar(this._push, this._api);

  final PushService _push;
  final DeviceApi _api;

  StreamSubscription<String>? _refreshSub;
  String? _lastRegistered;

  void start() {
    _refreshSub ??= _push.onTokenRefresh.listen(_registerQuietly);
  }

  Future<void> syncOnLogin() async {
    final token = await _push.getToken();
    if (token != null) await _registerQuietly(token);
  }

  Future<void> unregisterOnLogout() async {
    final token = _lastRegistered ?? await _push.getToken();
    if (token != null) {
      try {
        await _api.remove(token);
      } catch (_) {/* best effort */}
    }
    _lastRegistered = null;
  }

  Future<void> _registerQuietly(String token) async {
    if (token == _lastRegistered) return;
    try {
      await _api.register(token: token, platform: currentPushPlatform());
      _lastRegistered = token;
    } catch (_) {/* best effort — retried on next login / rotation */}
  }

  void dispose() {
    _refreshSub?.cancel();
    _refreshSub = null;
  }
}
