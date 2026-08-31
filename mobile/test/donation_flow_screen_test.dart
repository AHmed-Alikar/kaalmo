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
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/features/donations/presentation/donate_flow_screen.dart';
import 'package:kaalmo_mobile/features/donations/presentation/widgets/donation_receipt_card.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

Campaign _campaign() => Campaign.fromJson(campaignJson(id: 'c1', status: 'active'));

Future<void> _pumpDonate(
  WidgetTester tester, {
  required FakeCampaignRepository campaigns,
  required FakeDonationRepository donations,
  bool authed = true,
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
        campaignRepositoryProvider.overrideWithValue(campaigns),
        donationRepositoryProvider.overrideWithValue(donations),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go('/campaign/c1/donate');
  await tester.pumpAndSettle();
}

FakeCampaignRepository _campaignRepo() => FakeCampaignRepository()
  ..campaign = _campaign()
  ..updates = const []
  ..comments = const []
  ..supporters = const SupporterList(items: [], supporterCount: 0);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('shows preset amounts and enables Continue once an amount is valid', (tester) async {
    await _pumpDonate(tester, campaigns: _campaignRepo(), donations: FakeDonationRepository());

    expect(find.byType(DonateFlowScreen), findsOneWidget);
    expect(find.text('Choose an amount'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'USD 25'), findsOneWidget);

    final continueBtn = find.widgetWithText(FilledButton, 'Continue');
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNull);

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 25'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNotNull);
  });

  testWidgets('custom amount → review shows amount and payment methods', (tester) async {
    await _pumpDonate(
      tester,
      campaigns: _campaignRepo(),
      donations: FakeDonationRepository(config: fakePaymentConfig(providers: ['manual', 'evc_plus'])),
    );

    await tester.enterText(find.byType(TextField).first, '40');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Review your donation'), findsOneWidget);
    expect(find.text('USD 40'), findsWidgets);
    expect(find.text('Payment method'), findsOneWidget);
    expect(find.text('EVC Plus'), findsOneWidget);
    // `manual` (offline recording) is never offered to a donor — the flow must
    // always drive a real payment.
    expect(find.text('Cash / offline'), findsNothing);
    // EVC Plus needs a phone number, shown right away.
    expect(find.widgetWithText(TextField, 'Mobile money number'), findsOneWidget);
  });

  testWidgets('anonymous choice is carried into the review step', (tester) async {
    await _pumpDonate(tester, campaigns: _campaignRepo(), donations: FakeDonationRepository());

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 10'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Anonymous'), findsWidgets);
  });

  testWidgets('a confirmed payment shows the receipt and refreshes the campaign', (tester) async {
    final campaigns = _campaignRepo();
    final donations = FakeDonationRepository()
      ..result = fakeDonationResult(donationId: 'don-9', amount: 25, raisedAmount: 3000);
    await _pumpDonate(tester, campaigns: campaigns, donations: donations);
    final refreshesBefore = campaigns.getCampaignCalls;

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 25'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    // EVC Plus is preselected; enter the number to charge, then donate.
    await tester.enterText(find.widgetWithText(TextField, 'Mobile money number'), '0615123456');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Donate USD 25'));
    await tester.pumpAndSettle();

    expect(find.text('Thank you for your support'), findsOneWidget);
    expect(find.byType(DonationReceiptCard), findsOneWidget);
    expect(find.text('don-9'), findsOneWidget);
    expect(donations.donateCalls, hasLength(1));
    expect(donations.donateCalls.first['provider'], 'evc_plus');
    expect(donations.donateCalls.first['phone'], '0615123456');
    // The detail controller was asked to reload from the backend.
    expect(campaigns.getCampaignCalls, greaterThan(refreshesBefore));
  });

  testWidgets('Donate is disabled until the EVC Plus number is entered', (tester) async {
    await _pumpDonate(tester, campaigns: _campaignRepo(), donations: FakeDonationRepository());

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 25'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    final donateBtn = find.widgetWithText(FilledButton, 'Donate USD 25');
    expect(tester.widget<FilledButton>(donateBtn).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Mobile money number'), '0615123456');
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(donateBtn).onPressed, isNotNull);
  });

  testWidgets('when only manual is configured, no payment method is offered and Donate stays disabled',
      (tester) async {
    await _pumpDonate(
      tester,
      campaigns: _campaignRepo(),
      donations: FakeDonationRepository(config: fakePaymentConfig(providers: ['manual'])),
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 25'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    expect(find.text('EVC Plus'), findsNothing);
    expect(find.text('Cash / offline'), findsNothing);
    expect(find.textContaining('No payment methods'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Donate USD 25')).onPressed, isNull);
  });

  testWidgets('a declined payment shows the failure with a retry', (tester) async {
    final donations = FakeDonationRepository()
      ..donateError = const ApiException('The payment was declined.', statusCode: 402, code: 'PAYMENT_DECLINED');
    await _pumpDonate(tester, campaigns: _campaignRepo(), donations: donations);

    await tester.tap(find.widgetWithText(ChoiceChip, 'USD 25'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Mobile money number'), '0615123456');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Donate USD 25'));
    await tester.pumpAndSettle();

    expect(find.text('Donation not completed'), findsOneWidget);
    expect(find.textContaining('declined'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
  });

  testWidgets('an unauthenticated visitor gets the login gate, not the form', (tester) async {
    await _pumpDonate(
      tester,
      campaigns: _campaignRepo(),
      donations: FakeDonationRepository(),
      authed: false,
    );

    expect(find.text('Log in to donate'), findsOneWidget);
    expect(find.text('Choose an amount'), findsNothing);
  });
}
