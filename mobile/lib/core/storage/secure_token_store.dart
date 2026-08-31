import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the session (access + refresh tokens, cached user JSON) and the
/// chosen locale in the platform keystore / keychain. Nothing sensitive ever
/// touches SharedPreferences.
class SecureTokenStore {
  SecureTokenStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
              aOptions: AndroidOptions(),
            );

  final FlutterSecureStorage _storage;

  static const _kAccess = 'kaalmo.access_token';
  static const _kRefresh = 'kaalmo.refresh_token';
  static const _kUser = 'kaalmo.user_json';
  static const _kLocale = 'kaalmo.locale';

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> writeTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUser(Map<String, dynamic> user) =>
      _storage.write(key: _kUser, value: jsonEncode(user));

  Future<String?> readLocale() => _storage.read(key: _kLocale);

  Future<void> writeLocale(String? languageCode) => languageCode == null
      ? _storage.delete(key: _kLocale)
      : _storage.write(key: _kLocale, value: languageCode);

  /// Wipe everything session-related (logout / hard 401).
  Future<void> clearSession() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}
