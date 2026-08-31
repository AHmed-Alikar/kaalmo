import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/models/auth_user.dart';
import 'auth_state.dart';

/// App-wide session state. The router listens to this to guard routes; the
/// (future) login/register screens call into it.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository) : super(const AuthState.unknown());

  final AuthRepository _repository;

  /// Called once at startup. Must never throw — a storage failure degrades to
  /// "unauthenticated" rather than crashing the app.
  Future<void> bootstrap() async {
    try {
      final hasTokens = await _repository.hasTokens();
      if (!hasTokens) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      final cached = await _repository.restoreUser();
      state = AuthState(
        status: cached != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: cached,
      );
      // Best-effort freshening; a failure here is handled by the 401 flow.
      if (cached != null) {
        try {
          final fresh = await _repository.refreshProfile();
          _setAuthenticated(fresh);
        } catch (_) {/* keep cached user */}
      }
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<AuthUser> login({required String email, required String password}) async {
    final user = await _repository.login(email: email, password: password);
    _setAuthenticated(user);
    return user;
  }

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? language,
  }) async {
    final user = await _repository.register(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      language: language,
    );
    _setAuthenticated(user);
    return user;
  }

  Future<void> refreshProfile() async {
    final user = await _repository.refreshProfile();
    _setAuthenticated(user);
  }

  /// `PATCH /users/me`. Throws on failure so the caller can surface it.
  Future<void> updateProfile({String? fullName, String? language, bool? pushEnabled}) async {
    final user = await _repository.updateProfile(
      fullName: fullName,
      language: language,
      pushEnabled: pushEnabled,
    );
    _setAuthenticated(user);
  }

  /// Submits the emailed 6-digit code; on success the fresh (verified) user
  /// is stored, which lets the router move past `/verify-email`.
  Future<void> verifyEmailOtp(String code) async {
    final user = await _repository.verifyEmailOtp(code);
    _setAuthenticated(user);
  }

  Future<void> resendVerificationEmail() => _repository.resendVerificationEmail();

  // Pre-session flows — no state change, just a single call surface for the
  // screens so presentation never depends on the repository directly.
  Future<void> forgotPassword(String email) => _repository.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) =>
      _repository.resetPassword(email: email, code: code, password: password);

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Invoked by the network layer when a token refresh fails.
  void markSessionExpired() {
    _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated, sessionExpired: true);
  }

  void acknowledgeSessionExpired() {
    if (state.sessionExpired) {
      state = state.copyWith(sessionExpired: false);
    }
  }

  void _setAuthenticated(AuthUser user) {
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }
}
