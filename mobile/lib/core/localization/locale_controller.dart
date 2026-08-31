import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_token_store.dart';
import 'l10n.dart';

// The provider is declared in core/di/providers.dart alongside the rest of the
// dependency graph.

/// Holds the user's language choice. `null` = follow the device locale.
/// Persisted so the choice survives restarts; also pushed to the backend
/// (`PATCH /users/me { language }`) by the auth layer once signed in.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController(this._store) : super(null) {
    _restore();
  }

  final SecureTokenStore _store;

  Future<void> _restore() async {
    final code = await _store.readLocale();
    if (code != null && supportedLocales.any((l) => l.languageCode == code)) {
      state = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _store.writeLocale(locale?.languageCode);
  }
}
