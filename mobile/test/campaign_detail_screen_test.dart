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
import 'package:kaalmo_mobile/features/campaigns/presentation/campaign_details_screen.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/campaign_updates_screen.dart';
import 'package:kaalmo_mobile/features/home/presentation/home_screen.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/widgets/campaign_action_bar.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/widgets/campaign_trust_row.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/widgets/supporter_tile.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';
import 'package:kaalmo_mobile/shared/widgets/network_image_box.dart';

import 'support/fake_share_service.dart';
import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

FakeShareService? _lastShare;

Future<void> _pumpApp(
  WidgetTester tester, {
  required FakeCampaignRepository campaigns,
  bool authed = true,
  String start = '/campaign/c1',
}) async {
  // The details screen is a long vertical scroll (500px+ hero, then the
  // summary / trust / story / preview sections). Give the test a tall surface
  // so the lazily-built slivers are all laid out and findable without paging.
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final share = _lastShare = FakeShareService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(
          authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
        ),
        campaignRepositoryProvider.overrideWithValue(campaigns),
        shareServiceProvider.overrideWithValue(share),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
  // Land on the campaign under test.
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go(start);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  Campaign campaignWith({
    String status = 'active',
    String? cover = 'http://localhost:5000/uploads/x.jpg',
    List<String> badges = const ['identity_verified', 'beneficiary_verified'],
    String? storySo,
    String? storyEn,
  }) {
    final json = campaignJson(id: 'c1', status: status, coverImageUrl: cover);
    json['verificationBadges'] = badges;
    if (storySo != null || storyEn != null) {
      json['story'] = {'so': storySo ?? 's', 'en': storyEn ?? 'e'};
    }
    return Campaign.fromJson(json);
  }

  FakeCampaignRepository baseRepo({
    String status = 'active',
    String? cover = 'http://localhost:5000/uploads/x.jpg',
    List<String> badges = const ['identity_verified', 'beneficiary_verified'],
  }) =>
      FakeCampaignRepository()
        ..campaign = campaignWith(status: status, cover: cover, badges: badges)
        ..updates = [fakeUpdate()]
        ..comments = [fakeComment()]
        ..supporters = SupporterList(items: [fakeSupporter()], supporterCount: 3);

  group('Campaign details screen', () {
    testWidgets('renders the campaign and the sticky action bar', (tester) async {
      await _pumpApp(tester, campaigns: baseRepo());
      expect(find.byType(CampaignDetailsScreen), findsOneWidget);
      expect(find.byType(CampaignActionBar), findsOneWidget);
      expect(find.text('Medical help'), findsWidgets);
    });

    testWidgets('error state offers retry that reloads', (tester) async {
      final repo = FakeCampaignRepository()
        ..campaignError = const ApiException('nope', statusCode: 404, code: 'NOT_FOUND');
      await _pumpApp(tester, campaigns: repo);

      expect(find.byType(ErrorView), findsOneWidget);
      repo.campaignError = null;
      repo.campaign = fakeCampaign(id: 'c1');
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(CampaignActionBar), findsOneWidget);
    });

    testWidgets('renders verification badges from the backend', (tester) async {
      final repo = baseRepo();
      await _pumpApp(tester, campaigns: repo);
      expect(find.byType(CampaignTrustRow), findsOneWidget);
      expect(find.text('Identity verified'), findsOneWidget);
      expect(find.text('Beneficiary verified'), findsOneWidget);
    });

    testWidgets('a completed campaign shows a status banner and closed donate slot', (tester) async {
      final repo = baseRepo(status: 'completed');
      await _pumpApp(tester, campaigns: repo);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('Donations closed'), findsOneWidget);
    });

    testWidgets('missing cover image shows a placeholder, no crash', (tester) async {
      final repo = baseRepo(cover: null);
      await _pumpApp(tester, campaigns: repo);
      expect(tester.takeException(), isNull);
      expect(find.byType(NetworkImageBox), findsWidgets);
    });

    testWidgets('long story can be expanded', (tester) async {
      final longStory = List.filled(60, 'This campaign needs sustained help over many weeks.').join(' ');
      final repo = FakeCampaignRepository()
        ..campaign = campaignWith(storyEn: longStory, storySo: longStory)
        ..updates = const []
        ..comments = const []
        ..supporters = const SupporterList(items: [], supporterCount: 0);
      await _pumpApp(tester, campaigns: repo);

      final readMore = find.text('Read more');
      expect(readMore, findsOneWidget);
      await tester.ensureVisible(readMore);
      await tester.tap(readMore);
      await tester.pumpAndSettle();
      expect(find.text('Show less'), findsOneWidget);
    });

    testWidgets('anonymous supporter renders as "Anonymous"', (tester) async {
      final repo = baseRepo();
      repo.supporters = SupporterList(
        items: [fakeSupporter(name: null), fakeSupporter(id: 's2', name: 'Yusuf M.')],
        supporterCount: 2,
      );
      await _pumpApp(tester, campaigns: repo);
      // Preview shows supporter tiles on the detail screen.
      expect(find.byType(SupporterTile), findsWidgets);
      expect(find.text('Anonymous'), findsWidgets);
    });

    testWidgets('follow requires auth — an anonymous user gets the login sheet', (tester) async {
      final repo = baseRepo();
      await _pumpApp(tester, campaigns: repo, authed: false);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Follow'));
      await tester.pumpAndSettle();
      expect(find.text('Log in to continue'), findsOneWidget);
      expect(repo.mutations, isEmpty);
    });

    testWidgets('an authenticated user can follow the campaign', (tester) async {
      final repo = baseRepo();
      await _pumpApp(tester, campaigns: repo, authed: true);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Follow'));
      await tester.pumpAndSettle();
      expect(repo.mutations, contains('follow:true'));
      expect(find.widgetWithText(OutlinedButton, 'Following'), findsOneWidget);
    });

    testWidgets('share action invokes the share service with a campaign link', (tester) async {
      final repo = baseRepo();
      await _pumpApp(tester, campaigns: repo);

      await tester.tap(find.byIcon(Icons.ios_share).first);
      await tester.pumpAndSettle();
      expect(_lastShare!.calls, isNotEmpty);
      expect(_lastShare!.calls.first['url'], 'https://kaalmo.test/campaigns/c1');
    });

    testWidgets('report flow: menu → reason → submit → confirmation', (tester) async {
      final repo = baseRepo();
      await _pumpApp(tester, campaigns: repo, authed: true);

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report campaign').last);
      await tester.pumpAndSettle();

      final scam = find.text('Scam or fraud');
      await tester.ensureVisible(scam);
      await tester.tap(scam);
      await tester.pumpAndSettle();
      final submit = find.widgetWithText(FilledButton, 'Submit report');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(repo.mutations.any((m) => m.startsWith('report:')), isTrue);
      expect(find.text('Report received'), findsOneWidget);
    });

    testWidgets('navigates to the updates sub-screen', (tester) async {
      final repo = baseRepo();
      repo.updates = [fakeUpdate(id: 'u1'), fakeUpdate(id: 'u2'), fakeUpdate(id: 'u3')];
      await _pumpApp(tester, campaigns: repo);

      final seeAll = find.textContaining('See all');
      await tester.ensureVisible(seeAll.first);
      await tester.tap(seeAll.first);
      await tester.pumpAndSettle();
      expect(find.byType(CampaignUpdatesScreen), findsOneWidget);
    });
  });

  group('navigation into the campaign', () {
    testWidgets('Home card → details, and back returns Home', (tester) async {
      final repo = FakeCampaignRepository(all: [fakeCampaign(id: 'c1')])
        ..campaign = fakeCampaign(id: 'c1')
        ..updates = const []
        ..comments = const []
        ..supporters = const SupporterList(items: [], supporterCount: 0);
      await _pumpApp(tester, campaigns: repo, start: '/home');

      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(find.byType(CampaignDetailsScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pumpAndSettle();
      expect(find.byType(CampaignDetailsScreen), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
