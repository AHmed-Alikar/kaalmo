import 'dart:async';

/// A tiny event bus that breaks the dependency cycle between the network layer
/// (which detects a dead session) and the auth controller (which reacts to
/// it). The interceptor only knows how to *emit*; `AuthController` subscribes.
class AuthEvents {
  final _sessionExpired = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _sessionExpired.stream;

  void notifySessionExpired() {
    if (!_sessionExpired.isClosed) _sessionExpired.add(null);
  }

  void dispose() => _sessionExpired.close();
}
