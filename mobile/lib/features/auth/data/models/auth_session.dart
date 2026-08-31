import 'package:flutter/foundation.dart';

import 'auth_user.dart';

/// Response body of `POST /auth/login` and `POST /auth/register`.
@immutable
class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        user: AuthUser.fromJson((json['user'] as Map).cast<String, dynamic>()),
        accessToken: '${json['accessToken'] ?? ''}',
        refreshToken: '${json['refreshToken'] ?? ''}',
      );
}

/// Response body of `POST /auth/refresh`.
@immutable
class TokenPair {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
        accessToken: '${json['accessToken'] ?? ''}',
        refreshToken: '${json['refreshToken'] ?? ''}',
      );
}
