import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/providers.dart';
import 'core/push/fcm_push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push notifications are optional: initialise Firebase only if a real
  // configuration is bundled (google-services.json on Android). Without it the
  // app runs normally with in-app notifications only.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (_) {
    // Not configured on this build — FcmPushService detects the missing app and
    // becomes a no-op.
  }

  final config = AppConfig.resolve();

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const KaalmoApp(),
    ),
  );
}
