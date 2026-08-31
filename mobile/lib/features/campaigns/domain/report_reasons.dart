import '../../../core/localization/l10n.dart';

/// Client-side report categories. The backend's `reason` field is a free-text
/// string (5–500 chars) with **no enum**, so mobile supplies the categories.
/// [backendPhrase] is always ≥5 chars (English, for the admin queue); the
/// localized [label] is what the user sees.
enum ReportReason {
  scam('Scam or fraudulent campaign'),
  falseInformation('False or misleading information'),
  misuseOfFunds('Misuse of funds'),
  inappropriateContent('Inappropriate content'),
  duplicate('Duplicate campaign'),
  other('Other concern');

  const ReportReason(this.backendPhrase);

  final String backendPhrase;

  String label(AppL10n l10n) => switch (this) {
        scam => l10n.reportReasonScam,
        falseInformation => l10n.reportReasonFalseInfo,
        misuseOfFunds => l10n.reportReasonMisuse,
        inappropriateContent => l10n.reportReasonInappropriate,
        duplicate => l10n.reportReasonDuplicate,
        other => l10n.reportReasonOther,
      };

  /// Combine the category with an optional free-text explanation, capped to
  /// the backend's 500-char limit.
  String compose(String explanation) {
    final trimmed = explanation.trim();
    final full = trimmed.isEmpty ? backendPhrase : '$backendPhrase — $trimmed';
    return full.length <= 500 ? full : full.substring(0, 500);
  }
}
