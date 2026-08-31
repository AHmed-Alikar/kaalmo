import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'core/localization/l10n.dart';
import 'core/push/push_notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class KaalmoApp extends ConsumerStatefulWidget {
  const KaalmoApp({super.key});

  @override
  ConsumerState<KaalmoApp> createState() => _KaalmoAppState();
}

class _KaalmoAppState extends ConsumerState<KaalmoApp> {
  @override
  void initState() {
    super.initState();
    // Restore any persisted session; the router waits on /splash until this
    // resolves.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authControllerProvider.notifier).bootstrap();
      ref.read(pushNotificationServiceProvider).bootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    return MaterialApp.router(
      title: 'Kaalmo',
      scaffoldMessengerKey: pushMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: supportedLocales,
      localeResolutionCallback: (device, supported) {
        if (device != null) {
          for (final l in supported) {
            if (l.languageCode == device.languageCode) return l;
          }
        }
        return fallbackLocale;
      },
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
