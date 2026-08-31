import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_routes.dart';
import '../storage/secure_token_store.dart';

/// Exchanges the stored refresh token for a fresh token pair via
/// `POST /auth/refresh`. Uses its own bare Dio so it never re-enters the
/// authenticated client's interceptor, and single-flights concurrent calls.
class TokenRefresher {
  TokenRefresher(this._store, AppConfig config, {Dio? httpClient})
      : _dio = httpClient ??
            Dio(BaseOptions(
              baseUrl: config.apiBaseUrl,
              connectTimeout: config.connectTimeout,
              receiveTimeout: config.receiveTimeout,
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
            ));

  final SecureTokenStore _store;
  final Dio _dio;

  Future<bool>? _inFlight;

  Future<bool> refresh() => _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<bool> _run() async {
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiRoutes.refresh,
        data: {'refreshToken': refreshToken},
      );
      final data = res.data ?? const {};
      final access = '${data['accessToken'] ?? ''}';
      final nextRefresh = '${data['refreshToken'] ?? ''}';
      if (access.isEmpty) return false;
      await _store.writeTokens(
        accessToken: access,
        refreshToken: nextRefresh.isEmpty ? refreshToken : nextRefresh,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
