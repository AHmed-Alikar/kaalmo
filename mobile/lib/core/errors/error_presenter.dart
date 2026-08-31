import '../localization/l10n.dart';
import 'app_exception.dart';

/// Maps an [AppException] to a single, already-safe user-facing message.
///
/// Connectivity problems get localized copy; known backend error codes get
/// localized copy; anything else falls back to the backend's own `message`
/// (those strings are written as user-facing copy and never leak internals).
String presentError(Object error, AppL10n l10n) {
  if (error is! AppException) return l10n.errorUnexpected;

  return switch (error) {
    NetworkException() => l10n.errorNetwork,
    TimeoutException() => l10n.errorTimeout,
    UnexpectedException() => l10n.errorUnexpected,
    ApiException(:final code, :final message) => switch (code) {
        AppErrorCode.invalidCredentials => l10n.errorInvalidCredentials,
        'ACCOUNT_DISABLED' => l10n.errorAccountDisabled,
        'ALREADY_EXISTS' => l10n.errorAccountExists,
        AppErrorCode.rateLimited => l10n.errorRateLimited,
        'EMAIL_SEND_FAILED' => l10n.errorEmailSendFailed,
        'CAMPAIGN_NOT_OPEN' => l10n.errorCampaignNotOpen,
        // PAYMENT_DECLINED carries a provider-specific, already user-safe
        // message from the backend (e.g. "Insufficient EVC Plus balance") —
        // surface it rather than a generic string.
        _ => message,
      },
  };
}

/// Field-level errors from a backend validation response
/// (`error.fields`: name -> message). Empty when not a validation failure.
Map<String, String> fieldErrorsOf(Object error) =>
    error is ApiException ? error.fieldErrors : const {};
