import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/features/notifications/application/notifications_controller.dart';
import 'package:kaalmo_mobile/features/notifications/data/models/app_notification.dart';
import 'package:kaalmo_mobile/features/notifications/domain/notification_kind.dart';
import 'package:kaalmo_mobile/features/notifications/domain/notification_target.dart';
import 'package:kaalmo_mobile/core/localization/generated/app_localizations_en.dart';
import 'package:kaalmo_mobile/core/localization/generated/app_localizations_so.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

ProviderContainer _c(FakeNotificationRepository repo, {bool authed = true}) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(
      authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
    ),
    notificationRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

Future<NotificationsController> _controller(ProviderContainer c) async {
  await c.read(authControllerProvider.notifier).bootstrap();
  final sub = c.listen(notificationsControllerProvider, (_, _) {});
  addTearDown(sub.close);
  await pumpEventQueue();
  return c.read(notificationsControllerProvider.notifier);
}

void main() {
  group('model parsing', () {
    test('AppNotification.fromJson — full', () {
      final n = AppNotification.fromJson({
        '_id': 'n1',
        'type': 'donation_confirmed',
        'title': 'Donation confirmed',
        'body': 'Your donation of \$25 has been confirmed.',
        'targetUrl': '/campaigns/c1',
        'read': false,
        'createdAt': '2026-08-29T10:00:00.000Z',
      });
      expect(n.id, 'n1');
      expect(n.type, 'donation_confirmed');
      expect(n.read, isFalse);
      expect(n.body, isNotNull);
      expect(n.targetUrl, '/campaigns/c1');
      expect(n.createdAt, isA<DateTime>());
    });

    test('AppNotification tolerates missing optionals', () {
      final n = AppNotification.fromJson({'_id': 'x', 'type': 'system', 'title': 'Hi', 'read': true});
      expect(n.body, isNull);
      expect(n.targetUrl, isNull);
      expect(n.createdAt, isNull);
      expect(n.read, isTrue);
    });

    test('NotificationFeed.fromJson keeps unreadCount and skips bad rows', () {
      final f = NotificationFeed.fromJson({
        'items': [
          {'_id': 'a', 'type': 't', 'title': 'A', 'read': false},
          'bad',
        ],
        'unreadCount': 3,
      });
      expect(f.items, hasLength(1));
      expect(f.unreadCount, 3);
    });
  });

  group('NotificationKind.fromType', () {
    test('maps known prefixes and falls back to system', () {
      expect(NotificationKind.fromType('donation_confirmed'), NotificationKind.donation);
      expect(NotificationKind.fromType('campaign_update'), NotificationKind.campaignUpdate);
      expect(NotificationKind.fromType('campaign_reject'), NotificationKind.campaignRejected);
      expect(NotificationKind.fromType('campaign_suspend'), NotificationKind.campaignRejected);
      expect(NotificationKind.fromType('campaign_approve'), NotificationKind.campaignApproved);
      expect(NotificationKind.fromType('campaign_status_change'), NotificationKind.campaignApproved);
      expect(NotificationKind.fromType('beneficiary_verified'), NotificationKind.beneficiary);
      expect(NotificationKind.fromType('beneficiary_rejected'), NotificationKind.campaignRejected);
      expect(NotificationKind.fromType('withdrawal_processing'), NotificationKind.withdrawal);
      expect(NotificationKind.fromType('team_invite'), NotificationKind.team);
      expect(NotificationKind.fromType('support_reply'), NotificationKind.support);
      expect(NotificationKind.fromType('account_status'), NotificationKind.security);
      expect(NotificationKind.fromType('brand_new_type'), NotificationKind.system);
      expect(NotificationKind.fromType(''), NotificationKind.system);
    });
  });

  group('resolveNotificationRoute', () {
    test('campaign target → details, update target → updates', () {
      expect(resolveNotificationRoute(fakeNotification(type: 'donation_confirmed', targetUrl: '/campaigns/c9')),
          '/campaign/c9');
      expect(resolveNotificationRoute(fakeNotification(type: 'campaign_update', targetUrl: '/campaigns/c9')),
          '/campaign/c9/updates');
    });

    test('known non-campaign web paths map or return null; missing → null', () {
      expect(resolveNotificationRoute(fakeNotification(targetUrl: '/organizer')), '/organizer');
      expect(resolveNotificationRoute(fakeNotification(targetUrl: '/organizer/invites')), '/organizer/invites');
      expect(resolveNotificationRoute(fakeNotification(targetUrl: '/verification')), '/beneficiary');
      expect(resolveNotificationRoute(fakeNotification(targetUrl: '/support')), '/support');
      expect(resolveNotificationRoute(fakeNotification(targetUrl: '/organizer/withdrawals')), isNull);
      expect(resolveNotificationRoute(fakeNotification(targetUrl: null)), isNull);
    });
  });

  group('localization', () {
    test('English strings', () {
      final l = AppL10nEn();
      expect(l.notificationsTitle, 'Notifications');
      expect(l.notificationsEmptyTitle, 'No notifications yet');
      expect(l.notificationsMarkAllRead, 'Mark all read');
      expect(l.notifKindDonation, 'Donation');
    });

    test('Somali strings', () {
      final l = AppL10nSo();
      expect(l.notificationsTitle, 'Ogeysiisyo');
      expect(l.notificationsEmptyTitle, 'Weli ogeysiis ma jiro');
      expect(l.notificationsMarkAllRead, 'Calaamadee dhammaan la akhriyay');
      expect(l.notifKindDonation, 'Deeq');
    });
  });

  group('NotificationsController', () {
    test('loads the feed', () async {
      final repo = FakeNotificationRepository()
        ..feed = NotificationFeed(items: [fakeNotification(id: 'a'), fakeNotification(id: 'b', read: true)], unreadCount: 1);
      final c = _c(repo);
      await _controller(c);
      final s = c.read(notificationsControllerProvider);
      expect(s.status, NotificationsStatus.ready);
      expect(s.items, hasLength(2));
      expect(s.unreadCount, 1);
    });

    test('error state when the first load fails', () async {
      final repo = FakeNotificationRepository()..listError = const NetworkException('offline');
      final c = _c(repo);
      await _controller(c);
      expect(c.read(notificationsControllerProvider).status, NotificationsStatus.error);
    });

    test('empty feed', () async {
      final c = _c(FakeNotificationRepository());
      await _controller(c);
      expect(c.read(notificationsControllerProvider).isEmpty, isTrue);
    });

    test('markRead is optimistic and decrements the unread count', () async {
      final repo = FakeNotificationRepository()
        ..feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 1);
      final c = _c(repo);
      final ctrl = await _controller(c);
      await ctrl.markRead('a');
      final s = c.read(notificationsControllerProvider);
      expect(s.items.first.read, isTrue);
      expect(s.unreadCount, 0);
      expect(repo.calls, contains('markRead:a'));
    });

    test('markRead reverts and surfaces the error on failure', () async {
      final repo = FakeNotificationRepository()
        ..feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 1)
        ..markReadError = const ApiException('boom', statusCode: 500, code: 'SERVER_ERROR');
      final c = _c(repo);
      final ctrl = await _controller(c);
      await ctrl.markRead('a');
      final s = c.read(notificationsControllerProvider);
      expect(s.items.first.read, isFalse);
      expect(s.unreadCount, 1);
      expect(s.mutationError, isA<ApiException>());
    });

    test('markRead on an already-read notification does nothing', () async {
      final repo = FakeNotificationRepository()
        ..feed = NotificationFeed(items: [fakeNotification(id: 'a', read: true)], unreadCount: 0);
      final c = _c(repo);
      final ctrl = await _controller(c);
      await ctrl.markRead('a');
      expect(repo.calls, isEmpty);
    });

    test('markAllRead clears every unread and reverts on failure', () async {
      final repo = FakeNotificationRepository()
        ..feed = NotificationFeed(
          items: [fakeNotification(id: 'a'), fakeNotification(id: 'b'), fakeNotification(id: 'c', read: true)],
          unreadCount: 2,
        );
      final c = _c(repo);
      final ctrl = await _controller(c);
      await ctrl.markAllRead();
      var s = c.read(notificationsControllerProvider);
      expect(s.items.every((n) => n.read), isTrue);
      expect(s.unreadCount, 0);
      expect(repo.calls, contains('markAllRead'));

      // Now with a failure.
      repo.feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 1);
      repo.markAllError = const NetworkException('offline');
      await ctrl.refresh();
      await ctrl.markAllRead();
      s = c.read(notificationsControllerProvider);
      expect(s.items.first.read, isFalse);
      expect(s.unreadCount, 1);
      expect(s.mutationError, isA<NetworkException>());
    });

    test('does not auto-load for an unauthenticated session', () async {
      final repo = FakeNotificationRepository();
      final c = _c(repo, authed: false);
      await c.read(authControllerProvider.notifier).bootstrap();
      final sub = c.listen(notificationsControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();
      expect(repo.listCalls, 0);
    });
  });
}
