import 'package:flutter/foundation.dart';

import '../data/models/auth_user.dart';

enum AuthStatus {
  /// Startup — restoring any persisted session. The router shows /splash.
  unknown,
  authenticated,
  unauthenticated,
}

@immutable
class AuthState {
  const AuthState({required this.status, this.user, this.sessionExpired = false});

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final AuthUser? user;

  /// True for one transition when a refresh failed, so the UI can show a
  /// "your session ended" message before landing on login.
  final bool sessionExpired;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isResolved => status != AuthStatus.unknown;

  AuthState copyWith({AuthStatus? status, AuthUser? user, bool? sessionExpired}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        sessionExpired: sessionExpired ?? this.sessionExpired,
      );
}
