import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/push/push_message.dart';
import 'package:kaalmo_mobile/core/push/push_notification_service.dart';
import 'package:kaalmo_mobile/core/push/push_service.dart';
import 'package:kaalmo_mobile/features/notifications/data/models/app_notification.dart';
import 'package:kaalmo_mobile/features/notifications/domain/notification_target.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

/// Builds a container with a fake push service + device api + auth + notif repo,
/// and a [PushNotificationService] whose navigation is recorded into [routes].
({
  ProviderContainer container,
  FakePushService push,
  FakeDeviceApi devices,
  FakeNotificationRepository notifs,
  List<String> routes,
}) _harness({bool authed = false}) {
  final push = FakePushService();
  final devices = FakeDeviceApi();
  final notifs = FakeNotificationRepository()
    ..feed = NotificationFeed(items: [fakeNotification(id: 'n1', read: false)], unreadCount: 1);
  final routes = <String>[];

  final container = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(
      authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
    ),
    pushServiceProvider.overrideWithValue(push),
    deviceApiProvider.overrideWithValue(devices),
    notificationRepositoryProvider.overrideWithValue(notifs),
    pushNotificationServiceProvider.overrideWith(
      (ref) => PushNotificationService(ref, navigate: routes.add),
    ),
  ]);
  addTearDown(container.dispose);
  addTearDown(push.dispose);
  return (container: container, push: push, devices: devices, notifs: notifs, routes: routes);
}

void main() {
  // The foreground handler touches a GlobalKey (ScaffoldMessenger), which needs
  // a binding even in non-widget tests.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('PushMessage', () {
    test('coerces the data map and exposes structured fields', () {
      final m = PushMessage.fromData(
        {'type': 'donation_confirmed', 'targetUrl': '/campaigns/c1', 'notificationId': 'n9', 'n': 3},
        title: 'Donation confirmed',
        body: 'Thank you',
      );
      expect(m.type, 'donation_confirmed');
      expect(m.targetUrl, '/campaigns/c1');
      expect(m.notificationId, 'n9');
      expect(m.data['n'], '3');
      expect(m.route, '/campaign/c1');
    });

    test('empty / missing fields are null, route falls through', () {
      final m = PushMessage.fromData(const {'type': ''}, title: 'x');
      expect(m.type, isNull);
      expect(m.targetUrl, isNull);
      expect(m.notificationId, isNull);
      expect(m.route, isNull);
    });
  });

  group('resolveNotificationRouteFrom (shared with in-app rows)', () {
    test('campaign, updates and comments', () {
      expect(resolveNotificationRouteFrom(type: 'donation_confirmed', targetUrl: '/campaigns/c1'),
          '/campaign/c1');
      expect(resolveNotificationRouteFrom(type: 'campaign_update', targetUrl: '/campaigns/c1'),
          '/campaign/c1/updates');
      expect(resolveNotificationRouteFrom(type: 'campaign_comment', targetUrl: '/campaigns/c1'),
          '/campaign/c1/comments');
    });

    test('organizer / invites / verification / support', () {
      expect(resolveNotificationRouteFrom(targetUrl: '/organizer'), '/organizer');
      expect(resolveNotificationRouteFrom(targetUrl: '/organizer/invites'), '/organizer/invites');
      expect(resolveNotificationRouteFrom(targetUrl: '/verification'), '/beneficiary');
      expect(resolveNotificationRouteFrom(targetUrl: '/support'), '/support');
    });

    test('unknown / withdrawal / missing → null (caller falls back to the list)', () {
      expect(resolveNotificationRouteFrom(targetUrl: '/organizer/withdrawals'), isNull);
      expect(resolveNotificationRouteFrom(targetUrl: '/something-new'), isNull);
      expect(resolveNotificationRouteFrom(targetUrl: null), isNull);
    });
  });

  group('token lifecycle', () {
    test('login → asks permission once, registers the device token', () async {
      final h = _harness();
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();

      await h.container.read(authControllerProvider.notifier).login(email: 'a@b.com', password: 'x');
      await pumpEventQueue();

      expect(h.push.calls, contains('requestPermission'));
      expect(h.devices.calls.any((c) => c.startsWith('register:fcm-fake-token-123')), isTrue);
    });

    test('token refresh re-registers with the backend', () async {
      final h = _harness(authed: true);
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();
      h.devices.calls.clear();

      h.push.refreshController.add('fcm-rotated-token-456');
      await pumpEventQueue();

      expect(h.devices.calls.any((c) => c.startsWith('register:fcm-rotated-token-456')), isTrue);
    });

    test('logout → removes the token from the backend and deletes it locally', () async {
      final h = _harness(authed: true);
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();

      await h.container.read(authControllerProvider.notifier).logout();
      await pumpEventQueue();

      expect(h.devices.calls.any((c) => c.startsWith('remove:')), isTrue);
      expect(h.push.calls, contains('deleteToken'));
    });

    test('permission denied does not throw and the token still registers', () async {
      final h = _harness();
      h.push.permission = PushPermission.denied;
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();

      await h.container.read(authControllerProvider.notifier).login(email: 'a@b.com', password: 'x');
      await pumpEventQueue();

      expect(h.devices.calls.any((c) => c.startsWith('register:')), isTrue);
    });

    test('a backend registration failure is swallowed', () async {
      final h = _harness(authed: true);
      h.devices.registerError = const NetworkException('offline');
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();
      // No throw = pass.
    });
  });

  group('notification tap routing', () {
    test('opened message → navigates and marks the notification read', () async {
      final h = _harness(authed: true);
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();

      h.push.openedController.add(PushMessage.fromData(
        {'type': 'donation_confirmed', 'targetUrl': '/campaigns/c1', 'notificationId': 'n1'},
      ));
      await pumpEventQueue();

      expect(h.routes, contains('/campaign/c1'));
      expect(h.notifs.calls, contains('markRead:n1'));
    });

    test('unknown target falls back to the notifications list', () async {
      final h = _harness(authed: true);
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();

      h.push.openedController.add(PushMessage.fromData({'type': 'mystery', 'targetUrl': '/nope'}));
      await pumpEventQueue();

      expect(h.routes, contains('/notifications'));
    });

    test('auth-required target while logged out is held, then opened after login', () async {
      final h = _harness();
      final svc = h.container.read(pushNotificationServiceProvider);
      await svc.bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();

      h.push.openedController.add(PushMessage.fromData({'type': 'team_invite', 'targetUrl': '/organizer/invites'}));
      await pumpEventQueue();

      expect(svc.pendingRoute, '/organizer/invites');
      expect(h.routes, contains('/login'));

      await h.container.read(authControllerProvider.notifier).login(email: 'a@b.com', password: 'x');
      await pumpEventQueue();

      expect(svc.pendingRoute, isNull);
      expect(h.routes, contains('/organizer/invites'));
    });

    test('cold-start public target navigates without waiting for login', () async {
      final h = _harness();
      h.push.initial = PushMessage.fromData({'type': 'campaign_update', 'targetUrl': '/campaigns/c5'});
      final svc = h.container.read(pushNotificationServiceProvider);
      await svc.bootstrap();
      await pumpEventQueue();

      expect(h.routes, contains('/campaign/c5/updates'));
      expect(svc.pendingRoute, isNull);
    });

    test('cold-start auth-required target is held until login', () async {
      final h = _harness();
      h.push.initial = PushMessage.fromData({'type': 'support_reply', 'targetUrl': '/support'});
      final svc = h.container.read(pushNotificationServiceProvider);
      await svc.bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();

      expect(svc.pendingRoute, '/support');

      await h.container.read(authControllerProvider.notifier).login(email: 'a@b.com', password: 'x');
      await pumpEventQueue();

      expect(h.routes, contains('/support'));
    });
  });

  group('foreground message', () {
    test('refreshes the in-app feed but does not mark read', () async {
      final h = _harness(authed: true);
      await h.container.read(pushNotificationServiceProvider).bootstrap();
      await h.container.read(authControllerProvider.notifier).bootstrap();
      await pumpEventQueue();
      final before = h.notifs.listCalls;

      h.push.foregroundController.add(PushMessage.fromData(
        {'type': 'donation_confirmed', 'targetUrl': '/campaigns/c1', 'notificationId': 'n1'},
        body: 'You received a donation',
      ));
      await pumpEventQueue();

      expect(h.notifs.listCalls, greaterThan(before));
      expect(h.notifs.calls, isNot(contains('markRead:n1')));
    });
  });

  group('NoopPushService (Firebase not configured)', () {
    test('every member is a safe no-op', () async {
      const s = NoopPushService();
      await s.init();
      expect(await s.getToken(), isNull);
      expect(await s.requestPermission(), PushPermission.notDetermined);
      expect(await s.initialMessage(), isNull);
      await s.deleteToken();
      expect(s.onTokenRefresh, emitsDone);
    });
  });
}
