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
import 'package:kaalmo_mobile/features/campaigns/presentation/campaign_details_screen.dart';
import 'package:kaalmo_mobile/features/donations/presentation/donation_detail_screen.dart';
import 'package:kaalmo_mobile/features/donations/presentation/my_donations_screen.dart';
import 'package:kaalmo_mobile/features/donations/presentation/widgets/donation_receipt_card.dart';
import 'package:kaalmo_mobile/features/donations/presentation/widgets/my_donation_tile.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

Future<void> _pump(
  WidgetTester tester, {
  required FakeDonationRepository donations,
  FakeCampaignRepository? campaigns,
  bool authed = true,
  String start = '/profile/donations',
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
        donationRepositoryProvider.overrideWithValue(donations),
        campaignRepositoryProvider.overrideWithValue(campaigns ?? FakeCampaignRepository()),
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

  testWidgets('Profile tab links into My Donations', (tester) async {
    await _pump(
      tester,
      donations: FakeDonationRepository()..myDonations = [fakeMyDonation(id: 'a')],
      start: '/profile',
    );

    await tester.tap(find.text('My donations'));
    await tester.pumpAndSettle();
    expect(find.byType(MyDonationsScreen), findsOneWidget);
    expect(find.byType(MyDonationTile), findsOneWidget);
  });

  testWidgets('loading then a list of donations', (tester) async {
    final repo = FakeDonationRepository()
      ..myDonations = [
        fakeMyDonation(id: 'a', amount: 50),
        fakeMyDonation(id: 'b', amount: 10, status: 'pending', isAnonymous: true),
      ];
    await _pump(tester, donations: repo);

    expect(find.byType(MyDonationsScreen), findsOneWidget);
    expect(find.byType(MyDonationTile), findsNWidgets(2));
    expect(find.text('USD 50'), findsOneWidget);
    expect(find.text('Confirmed'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
  });

  testWidgets('empty state explains there are no donations yet', (tester) async {
    await _pump(tester, donations: FakeDonationRepository()..myDonations = const []);
    expect(find.text('No donations yet'), findsOneWidget);
    expect(find.byType(MyDonationTile), findsNothing);
  });

  testWidgets('error state offers a retry that refetches', (tester) async {
    final repo = FakeDonationRepository()..myDonationsError = const NetworkException('offline');
    await _pump(tester, donations: repo);

    expect(find.byType(ErrorView), findsOneWidget);
    final before = repo.myDonationsCalls;
    repo.myDonationsError = null;
    repo.myDonations = [fakeMyDonation(id: 'a')];
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();

    expect(repo.myDonationsCalls, greaterThan(before));
    expect(find.byType(MyDonationTile), findsOneWidget);
  });

  testWidgets('pull to refresh refetches the history', (tester) async {
    final repo = FakeDonationRepository()..myDonations = [fakeMyDonation(id: 'a')];
    await _pump(tester, donations: repo);
    final before = repo.myDonationsCalls;

    // RefreshIndicator triggers at ~25% of the viewport height; the test
    // surface is tall, so drag well past that.
    await tester.drag(find.byType(ListView), const Offset(0, 2500), touchSlopY: 0);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repo.myDonationsCalls, greaterThan(before));
  });

  testWidgets('tapping a donation opens the receipt; View campaign navigates', (tester) async {
    final campaigns = FakeCampaignRepository()..campaign = fakeCampaign(id: 'c1');
    final repo = FakeDonationRepository()
      ..myDonations = [fakeMyDonation(id: 'a', amount: 25, message: 'Stay strong', campaignId: 'c1')];
    await _pump(tester, donations: repo, campaigns: campaigns);

    await tester.tap(find.byType(MyDonationTile).first);
    await tester.pumpAndSettle();

    expect(find.byType(DonationDetailScreen), findsOneWidget);
    expect(find.byType(DonationReceiptCard), findsOneWidget);
    expect(find.textContaining('Stay strong'), findsWidgets);
    expect(find.text('a'), findsWidgets); // reference = donation id

    await tester.tap(find.widgetWithText(FilledButton, 'View campaign'));
    await tester.pumpAndSettle();
    expect(find.byType(CampaignDetailsScreen), findsOneWidget);
  });

  testWidgets('a donation whose campaign was deleted shows a safe state', (tester) async {
    final repo = FakeDonationRepository()
      ..myDonations = [fakeMyDonation(id: 'a', withCampaign: false)];
    await _pump(tester, donations: repo);

    expect(find.text('Campaign unavailable'), findsWidgets);
    await tester.tap(find.byType(MyDonationTile).first);
    await tester.pumpAndSettle();

    expect(find.text('This campaign is no longer available.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'View campaign'), findsNothing);
  });

  testWidgets('a guest is asked to log in', (tester) async {
    await _pump(
      tester,
      donations: FakeDonationRepository(),
      authed: false,
      start: '/profile/donations',
    );
    // Router bounces an unauthenticated user to login before the screen renders.
    expect(find.byType(MyDonationsScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
