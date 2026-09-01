import 'package:dio/dio.dart';

import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/auth_interceptor.dart';
import 'models/auth_session.dart';
import 'models/auth_user.dart';

/// Raw HTTP calls for the auth surface of the existing backend. No token
/// storage or state here — that is the repository's job.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Options get _skipAuth => Options(extra: {kSkipAuthExtra: true});

  Future<AuthSession> login({required String email, required String password}) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiRoutes.login,
      body: {'email': email, 'password': password},
      options: _skipAuth,
    );
    return AuthSession.fromJson(json);
  }

  Future<AuthSession> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? language,
  }) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiRoutes.register,
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'language': ?language,
      },
      options: _skipAuth,
    );
    return AuthSession.fromJson(json);
  }

  Future<TokenPair> refresh(String refreshToken) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiRoutes.refresh,
      body: {'refreshToken': refreshToken},
      options: _skipAuth,
    );
    return TokenPair.fromJson(json);
  }

  Future<void> forgotPassword(String email) => _client.post<Map<String, dynamic>>(
        ApiRoutes.forgotPassword,
        body: {'email': email},
        options: _skipAuth,
      );

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.resetPassword,
        body: {'email': email, 'code': code, 'password': password},
        options: _skipAuth,
      );

  Future<void> verifyEmailOtp(String code) =>
      _client.post<Map<String, dynamic>>(ApiRoutes.verifyEmailOtp, body: {'code': code});

  Future<void> resendVerificationEmail() =>
      _client.post<Map<String, dynamic>>(ApiRoutes.resendVerificationEmail);

  /// Backend currently returns `501 NOT_IMPLEMENTED` — surfaced as an
  /// [ApiException] so the UI can show a "coming soon" state.
  Future<void> verifyPhoneOtp({required String phone, required String code}) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.verifyPhoneOtp,
        body: {'phone': phone, 'code': code},
        options: _skipAuth,
      );

  Future<AuthUser> me() async {
    final json = await _client.get<Map<String, dynamic>>(ApiRoutes.me);
    return AuthUser.fromJson(json);
  }

  /// `POST /api/v1/users/me/request-organizer-access` — sends the 6-digit
  /// email confirmation code. Never grants the role by itself. Returns
  /// `{ sent: true }`.
  Future<void> requestOrganizerAccess({String? fullName, String? purpose}) =>
      _client.post<Map<String, dynamic>>(
        ApiRoutes.requestOrganizerAccess,
        body: {'fullName': ?fullName, 'purpose': ?purpose},
      );

  /// `POST /api/v1/users/me/confirm-organizer-access` — submits the emailed
  /// code. On success the backend adds the `organizer` role and returns a
  /// fresh token pair (`{ confirmed, accessToken, refreshToken }`).
  Future<TokenPair> confirmOrganizerAccess(String code) async {
    final json = await _client.post<Map<String, dynamic>>(
      ApiRoutes.confirmOrganizerAccess,
      body: {'code': code},
    );
    return TokenPair.fromJson(json);
  }

  /// `PATCH /api/v1/users/me` — backend only accepts `fullName`, `language`,
  /// `pushEnabled`; returns the updated public user.
  Future<AuthUser> updateMe({String? fullName, String? language, bool? pushEnabled}) async {
    final json = await _client.patch<Map<String, dynamic>>(
      ApiRoutes.me,
      body: {
        'fullName': ?fullName,
        'language': ?language,
        'pushEnabled': ?pushEnabled,
      },
    );
    return AuthUser.fromJson(json);
  }
}
