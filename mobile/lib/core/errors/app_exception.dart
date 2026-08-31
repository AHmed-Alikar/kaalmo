/// The single error type surfaced to the app layer.
///
/// Every network failure — an HTTP error carrying the backend's
/// `{ "error": { "code", "message", "fields" } }` body, a timeout, or a
/// connectivity problem — is normalised into an [AppException] by
/// `ApiExceptionMapper`, so UI and controllers only ever handle one shape.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Human-readable, already safe to show.
  final String message;

  /// Stable machine code (backend `error.code`, or one of the [AppErrorCode]s).
  String? get code;

  @override
  String toString() => 'AppException($code): $message';
}

/// An error returned by the backend with a structured body.
class ApiException extends AppException {
  const ApiException(
    super.message, {
    required this.statusCode,
    this.code,
    this.fieldErrors = const {},
  });

  final int statusCode;

  @override
  final String? code;

  /// `error.fields` — field name -> message. Empty when not a validation error.
  final Map<String, String> fieldErrors;

  bool get isValidation => code == AppErrorCode.validation || fieldErrors.isNotEmpty;
  bool get isUnauthorized => statusCode == 401;
  bool get isRateLimited => statusCode == 429 || code == AppErrorCode.rateLimited;
}

/// No usable response — offline, DNS failure, connection refused/reset.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network unavailable']);

  @override
  String? get code => AppErrorCode.network;
}

/// The request exceeded its connect/receive timeout.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);

  @override
  String? get code => AppErrorCode.timeout;
}

/// Anything we could not classify.
class UnexpectedException extends AppException {
  const UnexpectedException([super.message = 'Unexpected error']);

  @override
  String? get code => AppErrorCode.unexpected;
}

/// Client-side codes (backend codes pass through as-is on [ApiException.code]).
class AppErrorCode {
  const AppErrorCode._();

  static const network = 'NETWORK';
  static const timeout = 'TIMEOUT';
  static const unexpected = 'UNEXPECTED';
  static const sessionExpired = 'SESSION_EXPIRED';

  // Common backend codes worth referencing by name.
  static const validation = 'VALIDATION_ERROR';
  static const unauthorized = 'UNAUTHORIZED';
  static const invalidCredentials = 'INVALID_CREDENTIALS';
  static const rateLimited = 'RATE_LIMITED';
  static const notImplemented = 'NOT_IMPLEMENTED';
}
