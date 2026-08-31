import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/app.dart';
import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/router/app_router.dart';
import 'package:kaalmo_mobile/features/auth/presentation/login_screen.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/campaign_details_screen.dart';
import 'package:kaalmo_mobile/features/notifications/data/models/app_notification.dart';
import 'package:kaalmo_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:kaalmo_mobile/features/notifications/presentation/widgets/notification_bell.dart';
import 'package:kaalmo_mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

FakeCampaignRepository _campaignRepo() => FakeCampaignRepository()
  ..campaign = fakeCampaign(id: 'c1')
  ..updates = const []
  ..comments = const []
  ..supporters = const SupporterList(items: [], supporterCount: 0);

Future<void> _pump(
  WidgetTester tester, {
  required FakeNotificationRepository notifications,
  FakeCampaignRepository? campaigns,
  bool authed = true,
  bool settle = true,
  String start = '/notifications',
}) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(
          authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
        ),
        notificationRepositoryProvider.overrideWithValue(notifications),
        campaignRepositoryProvider.overrideWithValue(campaigns ?? _campaignRepo()),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go(start);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    // A perpetual spinner (loading state) never lets pumpAndSettle finish.
    await tester.pump();
    await tester.pump();
  }
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('loading indicator while the feed resolves', (tester) async {
    final repo = FakeNotificationRepository()..hang = true;
    await _pump(tester, notifications: repo, settle: false);
    expect(find.byType(LoadingView), findsOneWidget);
  });

  testWidgets('renders the list with unread and read rows', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(
        items: [
          fakeNotification(id: 'a', title: 'Donation confirmed'),
          fakeNotification(id: 'b', title: 'New update', type: 'campaign_update', read: true),
        ],
        unreadCount: 1,
      );
    await _pump(tester, notifications: repo);

    expect(find.byType(NotificationsScreen), findsOneWidget);
    expect(find.byType(NotificationTile), findsNWidgets(2));
    expect(find.text('Donation confirmed'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await _pump(tester, notifications: FakeNotificationRepository());
    expect(find.text('No notifications yet'), findsOneWidget);
    expect(find.byType(NotificationTile), findsNothing);
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('error state with retry that refetches', (tester) async {
    final repo = FakeNotificationRepository()..listError = const NetworkException('offline');
    await _pump(tester, notifications: repo);
    expect(find.byType(ErrorView), findsOneWidget);

    repo.listError = null;
    repo.feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 1);
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationTile), findsOneWidget);
  });

  testWidgets('mark all read clears the count and hides the action', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(items: [fakeNotification(id: 'a'), fakeNotification(id: 'b')], unreadCount: 2);
    await _pump(tester, notifications: repo);

    await tester.tap(find.text('Mark all read'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains('markAllRead'));
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('tapping a notification marks it read and navigates to the campaign', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(
        items: [fakeNotification(id: 'a', targetUrl: '/campaigns/c1')],
        unreadCount: 1,
      );
    await _pump(tester, notifications: repo, campaigns: _campaignRepo());

    await tester.tap(find.byType(NotificationTile).first);
    await tester.pumpAndSettle();

    expect(repo.calls, contains('markRead:a'));
    expect(find.byType(CampaignDetailsScreen), findsOneWidget);
  });

  testWidgets('a notification without a mobile target still marks read without crashing', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(
        items: [fakeNotification(id: 'a', type: 'withdrawal_pending', targetUrl: '/organizer/withdrawals')],
        unreadCount: 1,
      );
    await _pump(tester, notifications: repo);

    await tester.tap(find.byType(NotificationTile).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(repo.calls, contains('markRead:a'));
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('pull to refresh refetches', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 1);
    await _pump(tester, notifications: repo);
    final before = repo.listCalls;

    await tester.drag(find.byType(ListView), const Offset(0, 2500), touchSlopY: 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repo.listCalls, greaterThan(before));
  });

  testWidgets('the Home bell shows the unread badge and opens notifications', (tester) async {
    final repo = FakeNotificationRepository()
      ..feed = NotificationFeed(items: [fakeNotification(id: 'a')], unreadCount: 3);
    await _pump(tester, notifications: repo, start: '/home');

    expect(find.byType(NotificationBell), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.byType(NotificationBell));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('a guest is redirected to login', (tester) async {
    await _pump(tester, notifications: FakeNotificationRepository(), authed: false);
    expect(find.byType(NotificationsScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
