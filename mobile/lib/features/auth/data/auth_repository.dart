import '../../../core/storage/secure_token_store.dart';
import 'auth_api.dart';
import 'models/auth_session.dart';
import 'models/auth_user.dart';

/// Coordinates [AuthApi] with the secure token store. This is the seam the
/// network layer calls back into for a token refresh.
class AuthRepository {
  AuthRepository(this._api, this._store);

  final AuthApi _api;
  final SecureTokenStore _store;

  Future<AuthUser?> restoreUser() => _store.readUser().then(
        (json) => json == null ? null : AuthUser.fromJson(json),
      );

  Future<bool> hasTokens() async => (await _store.readAccessToken())?.isNotEmpty ?? false;

  Future<AuthUser> login({required String email, required String password}) =>
      _persist(_api.login(email: email, password: password));

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? language,
  }) =>
      _persist(_api.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        language: language,
      ));

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) =>
      _api.resetPassword(email: email, code: code, password: password);

  Future<void> resendVerificationEmail() => _api.resendVerificationEmail();

  Future<AuthUser> verifyEmailOtp(String code) async {
    await _api.verifyEmailOtp(code);
    return refreshProfile();
  }

  Future<AuthUser> refreshProfile() async {
    final user = await _api.me();
    await _store.writeUser(user.toJson());
    return user;
  }

  /// Step 1 of becoming an organizer — sends the email confirmation code.
  Future<void> requestOrganizerAccess({String? fullName, String? purpose}) =>
      _api.requestOrganizerAccess(fullName: fullName, purpose: purpose);

  /// Step 2 — submits the code. The backend returns a fresh token pair that
  /// carries the new `organizer` role; store it, then re-fetch the profile so
  /// the app sees the updated roles.
  Future<AuthUser> confirmOrganizerAccess(String code) async {
    final pair = await _api.confirmOrganizerAccess(code);
    await _store.writeTokens(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );
    return refreshProfile();
  }

  /// `PATCH /users/me` — updates the profile fields the backend allows and
  /// persists the returned user.
  Future<AuthUser> updateProfile({String? fullName, String? language, bool? pushEnabled}) async {
    final user = await _api.updateMe(fullName: fullName, language: language, pushEnabled: pushEnabled);
    await _store.writeUser(user.toJson());
    return user;
  }

  /// Called by [AuthInterceptor] on a 401. Returns true if a new token pair
  /// was obtained and stored.
  Future<bool> refreshSession() async {
    final refreshToken = await _store.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final pair = await _api.refresh(refreshToken);
      if (pair.accessToken.isEmpty) return false;
      await _store.writeTokens(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => _store.clearSession();

  Future<AuthUser> _persist(Future<AuthSession> pending) async {
    final session = await pending;
    await _store.writeTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _store.writeUser(session.user.toJson());
    return session.user;
  }
}
