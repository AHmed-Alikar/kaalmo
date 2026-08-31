import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/app.dart';
import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/router/main_shell.dart';
import 'package:kaalmo_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:kaalmo_mobile/features/auth/presentation/login_screen.dart';
import 'package:kaalmo_mobile/features/auth/presentation/reset_password_screen.dart';
import 'package:kaalmo_mobile/features/auth/presentation/verify_email_screen.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://localhost:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

Future<void> _pumpApp(WidgetTester tester, FakeAuthRepository repo) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(repo),
        campaignRepositoryProvider.overrideWithValue(FakeCampaignRepository()),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
}

// Fields render top-to-bottom in a fixed order per screen.
Future<void> _type(WidgetTester tester, int index, String text) async {
  final field = find.byType(TextField).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
}

Finder _filled(String label) => find.widgetWithText(FilledButton, label);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

const _termsLabel = "I agree to Kaalmo's Terms of Service and Privacy Policy.";

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('routing based on auth state', () {
    testWidgets('no session → Login', (tester) async {
      await _pumpApp(tester, FakeAuthRepository());
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('authenticated + verified → Home', (tester) async {
      await _pumpApp(tester, FakeAuthRepository(startWithSession: fakeUser()));
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('authenticated + unverified → Verify email', (tester) async {
      await _pumpApp(
        tester,
        FakeAuthRepository(startWithSession: fakeUser(emailVerified: false)),
      );
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });
  });

  group('login', () {
    testWidgets('success routes to Home and stores the session', (tester) async {
      final repo = FakeAuthRepository()..afterLogin = fakeUser();
      await _pumpApp(tester, repo);

      await _type(tester, 0, 'amina@example.com');
      await _type(tester, 1, 'secret12');
      await _tap(tester, _filled('Log in'));

      expect(repo.calls, contains('login'));
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('invalid credentials shows a localized error, stays on Login', (tester) async {
      final repo = FakeAuthRepository()
        ..loginError = const ApiException('Email or password is incorrect',
            statusCode: 401, code: AppErrorCode.invalidCredentials);
      await _pumpApp(tester, repo);

      await _type(tester, 0, 'amina@example.com');
      await _type(tester, 1, 'wrongpass');
      await _tap(tester, _filled('Log in'));

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('empty fields are validated before any request', (tester) async {
      final repo = FakeAuthRepository();
      await _pumpApp(tester, repo);

      await _tap(tester, _filled('Log in'));

      expect(find.text('This field is required'), findsWidgets);
      expect(repo.calls, isEmpty);
    });

    testWidgets('session-expired banner is shown after a dead session', (tester) async {
      final repo = FakeAuthRepository(startWithSession: fakeUser());
      await _pumpApp(tester, repo);
      final container =
          ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

      container.read(authControllerProvider.notifier).markSessionExpired();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Your session has ended. Please log in again.'), findsOneWidget);
    });
  });

  group('register', () {
    Future<void> gotoRegister(WidgetTester tester) =>
        _tap(tester, find.widgetWithText(TextButton, 'Create account'));

    Future<void> fillValidForm(WidgetTester tester) async {
      await _type(tester, 0, 'Amina Ali');
      await _type(tester, 1, 'amina@example.com');
      await _type(tester, 2, '+252611234567');
      await _type(tester, 3, 'secret12');
      await _type(tester, 4, 'secret12');
      await _tap(tester, find.text(_termsLabel));
    }

    testWidgets('validation blocks submit and shows field errors', (tester) async {
      final repo = FakeAuthRepository();
      await _pumpApp(tester, repo);
      await gotoRegister(tester);

      await _tap(tester, _filled('Create account'));

      expect(find.text('This field is required'), findsWidgets);
      expect(find.text('Please accept the terms to continue'), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('success routes to email verification', (tester) async {
      final repo = FakeAuthRepository()..afterRegister = fakeUser(emailVerified: false);
      await _pumpApp(tester, repo);
      await gotoRegister(tester);
      await fillValidForm(tester);

      await _tap(tester, _filled('Create account'));

      expect(repo.calls, contains('register'));
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
    });

    testWidgets('duplicate account surfaces a localized message', (tester) async {
      final repo = FakeAuthRepository()
        ..registerError = const ApiException('exists', statusCode: 409, code: 'ALREADY_EXISTS');
      await _pumpApp(tester, repo);
      await gotoRegister(tester);
      await fillValidForm(tester);

      await _tap(tester, _filled('Create account'));

      expect(find.text('An account with this email or phone already exists.'), findsOneWidget);
    });
  });

  group('forgot / reset password', () {
    testWidgets('forgot-password always shows the neutral confirmation', (tester) async {
      final repo = FakeAuthRepository();
      await _pumpApp(tester, repo);
      await _tap(tester, find.widgetWithText(TextButton, 'Forgot password?'));
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);

      await _type(tester, 0, 'unknown@example.com');
      await _tap(tester, _filled('Send reset code'));

      expect(repo.calls, contains('forgotPassword'));
      expect(find.text('Check your email'), findsOneWidget);
    });

    Future<void> gotoResetScreen(WidgetTester tester, FakeAuthRepository repo) async {
      await _pumpApp(tester, repo);
      await _tap(tester, find.widgetWithText(TextButton, 'Forgot password?'));
      await _type(tester, 0, 'amina@example.com');
      await _tap(tester, _filled('Send reset code'));
      await _tap(tester, _filled('Enter reset code'));
      expect(find.byType(ResetPasswordScreen), findsOneWidget);
    }

    testWidgets('reset-password success shows the confirmation screen', (tester) async {
      final repo = FakeAuthRepository();
      await gotoResetScreen(tester, repo);

      await _type(tester, 1, '482913'); // OTP
      await _type(tester, 2, 'newsecret12');
      await _tap(tester, _filled('Reset password'));

      expect(repo.calls, contains('resetPassword'));
      expect(find.text('Password updated'), findsOneWidget);
    });

    testWidgets('reset-password invalid code shows an inline code error', (tester) async {
      final repo = FakeAuthRepository()
        ..resetError = const ApiException('bad', statusCode: 400, code: 'INVALID_CODE');
      await gotoResetScreen(tester, repo);

      await _type(tester, 1, '000000');
      await _type(tester, 2, 'newsecret12');
      await _tap(tester, _filled('Reset password'));

      expect(
        find.text('This reset code is invalid or has expired. Request a new one.'),
        findsOneWidget,
      );
    });
  });

  group('email verification', () {
    testWidgets('verifying routes on to Home', (tester) async {
      final repo = FakeAuthRepository(startWithSession: fakeUser(emailVerified: false))
        ..afterVerify = fakeUser();
      await _pumpApp(tester, repo);
      expect(find.byType(VerifyEmailScreen), findsOneWidget);

      // Entering the 6th digit auto-submits (OtpInput.onCompleted).
      await _type(tester, 0, '482913');
      await tester.pumpAndSettle();

      expect(repo.calls, contains('verifyEmailOtp'));
      expect(find.byType(VerifyEmailScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('resend triggers the API and starts a cooldown', (tester) async {
      final repo = FakeAuthRepository(startWithSession: fakeUser(emailVerified: false));
      await _pumpApp(tester, repo);

      await tester.ensureVisible(find.widgetWithText(TextButton, 'Resend code'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Resend code'));
      await tester.pump();
      await tester.pump();

      expect(repo.calls, contains('resendVerificationEmail'));
      expect(find.textContaining('Resend code in'), findsOneWidget);

      await tester.pump(const Duration(seconds: 61)); // drain cooldown timer
    });
  });

  group('logout', () {
    testWidgets('confirming logout clears the session and returns to Login', (tester) async {
      final repo = FakeAuthRepository(startWithSession: fakeUser());
      await _pumpApp(tester, repo);

      // Logout lives on the Profile tab (bottom nav — not scrollable, so plain tap).
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      await tester.tap(_filled('Log out'));
      await tester.pumpAndSettle();

      expect(repo.calls, contains('logout'));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
