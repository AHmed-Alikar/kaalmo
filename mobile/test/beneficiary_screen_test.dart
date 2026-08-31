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
import 'package:kaalmo_mobile/features/beneficiary/presentation/beneficiary_dashboard_screen.dart';
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
  required FakeBeneficiaryRepository repo,
  bool authed = true,
  String start = '/beneficiary',
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
        beneficiaryRepositoryProvider.overrideWithValue(repo),
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

  testWidgets('Profile → Beneficiary', (tester) async {
    await _pump(tester, repo: FakeBeneficiaryRepository(), start: '/profile');
    await tester.tap(find.text('Beneficiary'));
    await tester.pumpAndSettle();
    expect(find.byType(BeneficiaryDashboardScreen), findsOneWidget);
  });

  testWidgets('no profile yet → "Not started" and a start-verification CTA', (tester) async {
    await _pump(tester, repo: FakeBeneficiaryRepository()..profile = null);
    expect(find.text('Verification'), findsOneWidget);
    expect(find.text('Not started'), findsWidgets);
    expect(find.widgetWithText(FilledButton, 'Start beneficiary verification'), findsOneWidget);
  });

  testWidgets('a verified profile with a linked account shows payout ready', (tester) async {
    final repo = FakeBeneficiaryRepository()
      ..profile = fakeBeneficiaryProfile(status: 'verified', payoutAccountId: 'pa1')
      ..payoutAccounts = [fakePayoutAccount(verified: true)];
    await _pump(tester, repo: repo);
    expect(find.text('Ready for withdrawal'), findsWidgets);
    expect(find.textContaining('***1234'), findsOneWidget);
  });

  testWidgets('verified but no linked account → not-ready linkage message', (tester) async {
    final repo = FakeBeneficiaryRepository()..profile = fakeBeneficiaryProfile(status: 'verified');
    await _pump(tester, repo: repo);
    expect(find.text('Not ready for payout yet'), findsOneWidget);
    expect(find.textContaining('link your payout account'), findsOneWidget);
  });

  testWidgets('error + retry', (tester) async {
    final repo = FakeBeneficiaryRepository()..profileError = const NetworkException('offline');
    await _pump(tester, repo: repo);
    expect(find.byType(ErrorView), findsOneWidget);

    repo.profileError = null;
    repo.profile = fakeBeneficiaryProfile(status: 'pending');
    await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Under review'), findsWidgets);
  });

  testWidgets('submit identity flow updates the profile', (tester) async {
    final repo = FakeBeneficiaryRepository()..profile = null;
    await _pump(tester, repo: repo);

    await tester.tap(find.widgetWithText(FilledButton, 'Start beneficiary verification'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Amina Ali');
    await tester.pumpAndSettle();
    // After submit the fake returns a pending profile; the sheet closes.
    repo.profile = fakeBeneficiaryProfile(fullName: 'Amina Ali', status: 'pending');
    await tester.tap(find.widgetWithText(FilledButton, 'Submit for verification'));
    await tester.pumpAndSettle();

    expect(repo.calls, contains('submitProfile:Amina Ali'));
    expect(find.text('Details submitted for verification.'), findsOneWidget);
  });

  testWidgets('add payout account flow', (tester) async {
    final repo = FakeBeneficiaryRepository()..profile = fakeBeneficiaryProfile(status: 'pending');
    await _pump(tester, repo: repo);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Add payout account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Provider name'), 'EVC Plus');
    await tester.enterText(find.widgetWithText(TextField, 'Account number'), '0612345678');
    await tester.pumpAndSettle();
    repo.payoutAccounts = [fakePayoutAccount(providerName: 'EVC Plus')];
    await tester.tap(find.widgetWithText(FilledButton, 'Add payout account'));
    await tester.pumpAndSettle();

    expect(repo.calls.any((x) => x.startsWith('createPayout:')), isTrue);
    expect(find.text('Payout account added.'), findsOneWidget);
  });

  testWidgets('a guest is redirected to login', (tester) async {
    await _pump(tester, repo: FakeBeneficiaryRepository(), authed: false);
    expect(find.byType(BeneficiaryDashboardScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
