import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_state.dart';
import '../../features/notifications/application/device_registrar.dart';
import '../di/providers.dart';
import '../localization/generated/app_localizations.dart';
import '../localization/l10n.dart';
import '../router/app_router.dart';
import '../router/app_routes.dart';
import 'push_message.dart';
import 'push_service.dart';

/// Global messenger so a foreground push can show an in-app banner without a
/// `BuildContext`.
final pushMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// One place that owns the push lifecycle:
///  - initialises the SDK and wires the message listeners once,
///  - registers / unregisters this device's token as the session changes,
///  - requests notification permission at a sensible moment (just after login),
///  - routes notification taps to the right screen, deferring to after login
///    when the destination needs authentication.
///
/// The existing in-app notification system stays the source of truth for
/// history; push is purely an extra delivery + navigation channel.
class PushNotificationService {
  PushNotificationService(this._ref, {void Function(String route)? navigate})
      : _navigateOverride = navigate;

  final Ref _ref;
  final void Function(String route)? _navigateOverride;

  /// The route held back because its destination needs a signed-in user.
  @visibleForTesting
  String? get pendingRoute => _pendingRoute;

  PushService get _push => _ref.read(pushServiceProvider);
  DeviceRegistrar get _registrar => _ref.read(deviceRegistrarProvider);

  final _subs = <StreamSubscription<dynamic>>[];
  bool _started = false;
  bool _permissionAsked = false;
  bool _wasAuthenticated = false;

  /// A tap whose destination needs a signed-in user, held until login completes.
  String? _pendingRoute;

  /// Called once from `KaalmoApp` after the first frame.
  Future<void> bootstrap() async {
    if (_started) return;
    _started = true;

    await _push.init();
    _registrar.start();

    _subs.add(_push.onMessageOpened.listen(_handleOpened));
    _subs.add(_push.onForegroundMessage.listen(_handleForeground));

    // React to session changes for token registration + pending navigation.
    _ref.listen<AuthState>(authControllerProvider, (prev, next) {
      final was = prev?.isAuthenticated ?? _wasAuthenticated;
      if (next.isAuthenticated && !was) {
        _onAuthenticated();
      } else if (!next.isAuthenticated && was) {
        _onLoggedOut();
      }
      _wasAuthenticated = next.isAuthenticated;
    }, fireImmediately: true);

    // Cold start: the notification that launched the app.
    final initial = await _push.initialMessage();
    if (initial != null) _routeFor(initial, fromColdStart: true);
  }

  Future<void> _onAuthenticated() async {
    // Ask for permission the first time the user is signed in — notifications
    // about their donations/campaigns are the point of an account here.
    if (!_permissionAsked) {
      _permissionAsked = true;
      try {
        await _push.requestPermission();
      } catch (_) {/* denied is fine — app and in-app notifications continue */}
    }
    await _registrar.syncOnLogin();
    _consumePending();
  }

  Future<void> _onLoggedOut() async {
    await _registrar.unregisterOnLogout();
    // Drop the local token so the next user on this device can't inherit the
    // previous user's notifications (the backend also reassigns on re-register).
    await _push.deleteToken();
    _pendingRoute = null;
  }

  void _handleForeground(PushMessage m) {
    // Android shows nothing itself while the app is foregrounded. Refresh the
    // in-app feed (updates the bell badge + list) and show a light banner.
    if (_ref.read(authControllerProvider).isAuthenticated) {
      _ref.read(notificationsControllerProvider.notifier).refresh();
    }
    // No mark-read here — the user hasn't engaged with it yet.
    final text = m.body ?? m.title;
    final route = m.route;
    if (text == null || text.isEmpty) return;
    final messenger = pushMessengerKey.currentState;
    final l10n = lookupAppL10n(_ref.read(localeControllerProvider) ?? fallbackLocale);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
        action: route == null
            ? null
            : SnackBarAction(
                label: l10n.pushOpenAction,
                onPressed: () => _routeFor(m),
              ),
      ),
    );
  }

  void _handleOpened(PushMessage m) {
    final id = m.notificationId;
    if (_ref.read(authControllerProvider).isAuthenticated) {
      final ctrl = _ref.read(notificationsControllerProvider.notifier);
      if (id != null) {
        ctrl.refreshThenMarkRead(id);
      } else {
        ctrl.refresh();
      }
    }
    _routeFor(m);
  }

  /// Navigate for a tapped notification. Public destinations go straight there;
  /// destinations that need a session are stashed until the user logs in.
  void _routeFor(PushMessage m, {bool fromColdStart = false}) {
    final route = m.route ?? AppRoutes.notifications;
    final isPublic = route.startsWith('/campaign/');
    final authed = _ref.read(authControllerProvider).isAuthenticated;

    if (!authed && !isPublic) {
      _pendingRoute = route;
      if (!fromColdStart) _go(AppRoutes.login);
      return;
    }
    _go(route);
  }

  void _consumePending() {
    final route = _pendingRoute;
    if (route == null) return;
    _pendingRoute = null;
    _go(route);
  }

  void _go(String route) {
    if (_navigateOverride != null) {
      _navigateOverride(route);
      return;
    }
    // Defer a frame so the router is past /splash on cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _ref.read(goRouterProvider).push(route);
      } catch (_) {/* router not ready / invalid route — ignore */}
    });
  }

  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}
