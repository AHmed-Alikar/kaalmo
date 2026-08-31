import 'package:dio/dio.dart';

import '../storage/secure_token_store.dart';

/// Marks a request that must NOT carry the Authorization header and must NOT
/// trigger a refresh-retry (login, register, refresh, forgot/reset password).
/// Set it via `Options(extra: {kSkipAuthExtra: true})`.
const kSkipAuthExtra = 'kaalmo.skipAuth';

/// Injects the access token, and on a 401 performs a single-flight token
/// refresh then retries the original request exactly once. If the refresh
/// fails the session is considered dead and [_onSessionExpired] fires.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(
    this._store,
    this._refreshSession,
    this._onSessionExpired,
    this._retryClient,
  );

  final SecureTokenStore _store;
  final Future<bool> Function() _refreshSession;
  final void Function() _onSessionExpired;
  final Dio Function() _retryClient;

  static const _retriedExtra = 'kaalmo.retried';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[kSkipAuthExtra] != true) {
      final token = await _store.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final skip = request.extra[kSkipAuthExtra] == true;
    final alreadyRetried = request.extra[_retriedExtra] == true;

    if (!is401 || skip || alreadyRetried) {
      return handler.next(err);
    }

    final refreshed = await _refreshSession();
    if (!refreshed) {
      _onSessionExpired();
      return handler.next(err);
    }

    try {
      final token = await _store.readAccessToken();
      final retryOptions = request
        ..extra[_retriedExtra] = true
        ..headers['Authorization'] = 'Bearer $token';
      final response = await _retryClient().fetch<dynamic>(retryOptions);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }
}
