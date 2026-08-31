import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:kaalmo_mobile/app.dart';
import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/router/app_router.dart';
import 'package:kaalmo_mobile/features/auth/application/auth_state.dart';
import 'package:kaalmo_mobile/features/auth/presentation/login_screen.dart';
import 'package:kaalmo_mobile/features/auth/presentation/splash_screen.dart';

const _testConfig = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://localhost:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  testWidgets('boots on the splash screen, then routes to login when no session', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(_testConfig)],
        child: const KaalmoApp(),
      ),
    );

    // First frame: splash.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Kaalmo'), findsOneWidget);

    // bootstrap() runs post-frame; with no stored tokens it resolves to
    // unauthenticated and the router redirects to /login.
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('the theme exposes the Kaalmo primary colour', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(_testConfig)],
        child: const KaalmoApp(),
      ),
    );
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(ctx).colorScheme.primary, const Color(0xFF0B7189));
  });

  test('AuthController starts in the unknown state', () {
    final container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(_testConfig)],
    );
    addTearDown(container.dispose);

    expect(container.read(authControllerProvider).status, AuthStatus.unknown);
  });

  test('GoRouter is constructable from the provider graph', () {
    final container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(_testConfig)],
    );
    addTearDown(container.dispose);

    expect(container.read(goRouterProvider), isA<GoRouter>());
  });
}
