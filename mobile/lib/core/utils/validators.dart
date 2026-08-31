import '../localization/l10n.dart';

/// Field validators. Each returns a localized error string, or null when the
/// value is acceptable. Backend validation is still authoritative — these
/// just catch obvious mistakes before a round-trip.
class Validators {
  const Validators._();

  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value, AppL10n l10n) {
    return (value == null || value.trim().isEmpty) ? l10n.validationRequired : null;
  }

  static String? email(String? value, AppL10n l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.validationRequired;
    return _email.hasMatch(v) ? null : l10n.validationEmailInvalid;
  }

  static String? password(String? value, AppL10n l10n) {
    final v = value ?? '';
    if (v.isEmpty) return l10n.validationRequired;
    if (v.length < 8) return l10n.validationPasswordTooShort;
    if (v.length > 72) return l10n.validationPasswordTooLong;
    return null;
  }

  static String? confirmPassword(String? value, String original, AppL10n l10n) {
    if (value == null || value.isEmpty) return l10n.validationRequired;
    return value == original ? null : l10n.validationPasswordMismatch;
  }

  static String? fullName(String? value, AppL10n l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.validationRequired;
    return v.length >= 2 ? null : l10n.validationNameTooShort;
  }

  static String? phone(String? value, AppL10n l10n) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return l10n.validationRequired;
    final digits = v.replaceAll(RegExp(r'\D'), '');
    return (digits.length >= 7 && digits.length <= 20) ? null : l10n.validationPhoneInvalid;
  }

  static String? code6(String? value, AppL10n l10n) {
    final v = value?.trim() ?? '';
    return RegExp(r'^\d{6}$').hasMatch(v) ? null : l10n.validationCodeLength;
  }
}
