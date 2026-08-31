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
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/campaign_edit_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/campaign_manage_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/organizer_dashboard_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/post_update_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/widgets/organizer_campaign_tile.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

FakeCampaignRepository _campaignRepo(String status, {String organizerId = 'u1'}) =>
    FakeCampaignRepository()
      ..campaign = fakeCampaign(id: 'c1', status: status, organizerId: organizerId)
      ..updates = const []
      ..comments = const []
      ..supporters = const SupporterList(items: [], supporterCount: 0);

Future<void> _pump(
  WidgetTester tester, {
  required FakeOrganizerRepository organizer,
  FakeCampaignRepository? campaigns,
  String start = '/organizer',
  List<String> roles = const ['organizer'],
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
          FakeAuthRepository(startWithSession: fakeUser(roles: roles)),
        ),
        organizerRepositoryProvider.overrideWithValue(organizer),
        campaignRepositoryProvider.overrideWithValue(campaigns ?? _campaignRepo('draft')),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go(start);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('Profile → Organizer for an organizer user', (tester) async {
    await _pump(tester, organizer: FakeOrganizerRepository()..campaigns = const [], start: '/profile');
    await tester.tap(find.text('Organizer'));
    await tester.pumpAndSettle();
    expect(find.byType(OrganizerDashboardScreen), findsOneWidget);
  });

  testWidgets('dashboard shows stats and recent campaigns from the real list', (tester) async {
    final repo = FakeOrganizerRepository()
      ..campaigns = [
        fakeCampaign(id: 'a', status: 'active', raised: 500),
        fakeCampaign(id: 'b', status: 'draft', raised: 0),
      ];
    await _pump(tester, organizer: repo);
    expect(find.byType(OrganizerDashboardScreen), findsOneWidget);
    expect(find.text('Your campaigns at a glance'), findsOneWidget);
    expect(find.byType(OrganizerCampaignTile), findsNWidgets(2));
  });

  testWidgets('a donor without the organizer role sees a not-available state', (tester) async {
    await _pump(tester, organizer: FakeOrganizerRepository(), roles: const ['donor']);
    expect(find.text('Not an organizer yet'), findsOneWidget);
  });

  testWidgets('My campaigns: empty and error states', (tester) async {
    final repo = FakeOrganizerRepository()..campaignsError = const NetworkException('offline');
    await _pump(tester, organizer: repo, start: '/organizer/campaigns');
    expect(find.byType(ErrorView), findsOneWidget);

    repo.campaignsError = null;
    repo.campaigns = const [];
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No campaigns yet'), findsOneWidget);
  });

  testWidgets('manage screen shows the right actions for a draft and navigates to edit', (tester) async {
    final repo = FakeOrganizerRepository()..campaigns = [fakeCampaign(id: 'c1', status: 'draft')];
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('draft'), start: '/organizer/campaign/c1');

    expect(find.byType(CampaignManageScreen), findsOneWidget);
    expect(find.text('Submit for review'), findsOneWidget);
    expect(find.text('Delete draft'), findsOneWidget);

    await tester.tap(find.text('Edit campaign'));
    await tester.pumpAndSettle();
    expect(find.byType(CampaignEditScreen), findsOneWidget);
  });

  testWidgets('an active campaign never offers submit / delete', (tester) async {
    final repo = FakeOrganizerRepository();
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('active'), start: '/organizer/campaign/c1');
    expect(find.text('Submit for review'), findsNothing);
    expect(find.text('Delete draft'), findsNothing);
    expect(find.text('View public page'), findsOneWidget);
  });

  testWidgets('submit for review: confirm → success', (tester) async {
    final repo = FakeOrganizerRepository();
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('draft'), start: '/organizer/campaign/c1');

    await tester.tap(find.text('Submit for review'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Submit for review'));
    await tester.pumpAndSettle();

    expect(repo.calls, contains('submit:c1'));
    expect(find.text('Campaign submitted for review.'), findsOneWidget);
  });

  testWidgets('submit failure shows the backend message', (tester) async {
    final repo = FakeOrganizerRepository()
      ..submitError = const ApiException('Cannot move campaign from "active" to "submitted"',
          statusCode: 400, code: 'INVALID_TRANSITION');
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('draft'), start: '/organizer/campaign/c1');

    await tester.tap(find.text('Submit for review'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Submit for review'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Cannot move campaign'), findsWidgets);
  });

  testWidgets('edit: short title disables save; valid save succeeds', (tester) async {
    final repo = FakeOrganizerRepository()..updateResult = fakeCampaign(id: 'c1', status: 'under_review');
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('draft'),
        start: '/organizer/campaign/c1/edit');

    final save = find.widgetWithText(FilledButton, 'Save changes');
    await tester.enterText(find.byType(TextField).first, 'abc');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'A proper campaign title');
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(repo.calls, contains('update:c1'));
  });

  testWidgets('post update: too short blocks publish; valid text posts', (tester) async {
    final repo = FakeOrganizerRepository();
    await _pump(tester, organizer: repo, campaigns: _campaignRepo('active'),
        start: '/organizer/campaign/c1/update');

    expect(find.byType(PostUpdateScreen), findsOneWidget);
    final publish = find.widgetWithText(FilledButton, 'Publish update');
    await tester.enterText(find.byType(TextField).first, 'short');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(publish).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, 'We finished the school roof this week!');
    await tester.pumpAndSettle();
    await tester.tap(publish);
    await tester.pumpAndSettle();
    expect(repo.calls.any((x) => x.startsWith('postUpdate:c1')), isTrue);
  });
}
