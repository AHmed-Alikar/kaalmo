import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/app.dart';
import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/localization/l10n.dart';
import 'package:kaalmo_mobile/features/home/presentation/home_screen.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/campaign_details_screen.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:kaalmo_mobile/features/campaigns/presentation/widgets/category_chips.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';
import 'package:kaalmo_mobile/shared/widgets/network_image_box.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://localhost:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

/// Pumps just the Home screen (no router) — enough for the data states.
Future<void> _pumpHome(WidgetTester tester, FakeCampaignRepository campaigns) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        campaignRepositoryProvider.overrideWithValue(campaigns),
      ],
      child: const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: HomeScreen(),
      ),
    ),
  );
}

/// Pumps the full app authenticated so router-driven flows work.
Future<void> _pumpApp(WidgetTester tester, FakeCampaignRepository campaigns) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository(startWithSession: fakeUser())),
        campaignRepositoryProvider.overrideWithValue(campaigns),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
}

AppL10n _l10n(WidgetTester tester) => AppL10n.of(tester.element(find.byType(Scaffold).first));

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('Home data states', () {
    testWidgets('loading indicator while the feed resolves', (tester) async {
      final repo = FakeCampaignRepository(all: [fakeCampaign(id: 'a')])..hang = true;
      await _pumpHome(tester, repo);
      await tester.pump();

      expect(find.byType(LoadingView), findsOneWidget);
    });

    testWidgets('renders featured + recent campaigns on success', (tester) async {
      final repo = FakeCampaignRepository(
        all: List.generate(8, (i) => fakeCampaign(id: 'c$i', verified: i.isEven)),
      );
      await _pumpHome(tester, repo);
      await tester.pumpAndSettle();

      final l10n = _l10n(tester);
      expect(find.byType(CampaignCard), findsWidgets); // featured carousel
      expect(find.text(l10n.homeFeatured), findsOneWidget);

      // Categories + Recent live further down the vertical scroll view.
      final verticalScroll = find
          .descendant(of: find.byType(CustomScrollView), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.byType(CategoryChips), 300, scrollable: verticalScroll);
      expect(find.byType(CategoryChips), findsOneWidget);
      await tester.scrollUntilVisible(find.text(l10n.homeRecent), 300, scrollable: verticalScroll);
      expect(find.text(l10n.homeRecent), findsOneWidget);
    });

    testWidgets('empty state when there are no campaigns', (tester) async {
      await _pumpHome(tester, FakeCampaignRepository(all: const []));
      await tester.pumpAndSettle();

      expect(find.text(_l10n(tester).homeEmptyTitle), findsOneWidget);
      expect(find.byType(CampaignCard), findsNothing);
    });

    testWidgets('error state with retry that re-fetches', (tester) async {
      final repo = FakeCampaignRepository(all: const [])
        ..listError = const NetworkException('offline');
      await _pumpHome(tester, repo);
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      final before = repo.listCalls;

      repo.listError = null;
      repo.all = [fakeCampaign(id: 'x')];
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(repo.listCalls, greaterThan(before));
      expect(find.byType(CampaignCard), findsWidgets);
    });
  });

  group('Explore', () {
    testWidgets('reachable from the bottom nav and lists campaigns', (tester) async {
      final repo = FakeCampaignRepository(all: List.generate(5, (i) => fakeCampaign(id: 'e$i')));
      await _pumpApp(tester, repo);

      final l10n = _l10n(tester);
      await tester.tap(find.text(l10n.navExplore).last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, l10n.exploreTitle), findsOneWidget);
      expect(find.byType(CampaignCard), findsWidgets);
    });
  });

  group('CampaignCard', () {
    Widget harness(Widget child) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(body: Center(child: SizedBox(width: 320, child: child))),
        );

    testWidgets('image placeholder when coverImageUrl is missing', (tester) async {
      await tester.pumpWidget(harness(
        CampaignCard(campaign: fakeCampaign(id: 'noimg', coverImageUrl: null), onTap: () {}),
      ));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(NetworkImageBox), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('progress line reflects a safe calculation', (tester) async {
      await tester.pumpWidget(harness(
        CampaignCard(campaign: fakeCampaign(goal: 8000, raised: 2500), onTap: () {}),
      ));
      await tester.pump();
      expect(find.textContaining('31%'), findsOneWidget);
    });

    testWidgets('zero-goal campaign renders 0% without crashing', (tester) async {
      await tester.pumpWidget(harness(
        CampaignCard(campaign: fakeCampaign(goal: 0, raised: 100), onTap: () {}),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('0%'), findsOneWidget);
    });
  });

  group('navigation', () {
    testWidgets('tapping a campaign card opens the /campaign/:id route', (tester) async {
      final repo = FakeCampaignRepository(all: [fakeCampaign(id: 'c123')]);
      await _pumpApp(tester, repo);

      final card = find.byType(CampaignCard).first;
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(find.byType(CampaignDetailsScreen), findsOneWidget);
    });
  });
}
