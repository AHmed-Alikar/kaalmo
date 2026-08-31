import '../../../core/localization/l10n.dart';

/// Presentation of a `Campaign.status` value. Drives which actions the UI
/// offers — a completed / suspended campaign must not show a donate call to
/// action, a live campaign must not show "submit for review", etc.
enum CampaignStatusView {
  draft,
  submitted,
  underReview,
  approved,
  published,
  active,
  goalReached,
  withdrawal,
  completed,
  suspended,
  frozen,
  cancelled,
  expired,
  rejected,
  other;

  static CampaignStatusView from(String raw) => switch (raw) {
        'draft' => draft,
        'submitted' => submitted,
        'under_review' => underReview,
        'approved' => approved,
        'published' => published,
        'active' => active,
        'goal_reached' => goalReached,
        'withdrawal' => withdrawal,
        'completed' => completed,
        'suspended' => suspended,
        'frozen' => frozen,
        'cancelled' => cancelled,
        'expired' => expired,
        'rejected' => rejected,
        _ => other,
      };

  /// Open to donations (mirrors the backend `PUBLIC_STATUSES` donatable set).
  bool get isOpenForDonations =>
      this == published || this == active || this == goalReached;

  /// Publicly visible (mirrors backend `PUBLIC_STATUSES`).
  bool get isPublic =>
      this == published ||
      this == active ||
      this == goalReached ||
      this == withdrawal ||
      this == completed;

  /// Still moving through the moderation pipeline before it can go live.
  bool get isInReviewPipeline =>
      this == draft || this == submitted || this == underReview || this == approved;

  /// A closed / restricted state worth calling out with a banner.
  bool get needsBanner =>
      this == completed ||
      this == goalReached ||
      this == suspended ||
      this == frozen ||
      this == cancelled ||
      this == expired;

  bool get isNegative =>
      this == suspended || this == frozen || this == cancelled || this == expired || this == rejected;

  String label(AppL10n l10n) => switch (this) {
        draft => l10n.statusDraft,
        submitted => l10n.statusSubmitted,
        underReview => l10n.statusUnderReview,
        approved => l10n.statusApproved,
        published => l10n.statusPublished,
        active => l10n.statusActive,
        goalReached => l10n.statusGoalReached,
        withdrawal => l10n.statusWithdrawal,
        completed => l10n.statusCompleted,
        suspended => l10n.statusSuspended,
        frozen => l10n.statusFrozen,
        cancelled => l10n.statusCancelled,
        expired => l10n.statusExpired,
        rejected => l10n.statusRejected,
        other => l10n.statusUnavailable,
      };

  String bannerMessage(AppL10n l10n) => switch (this) {
        completed => l10n.statusBannerCompleted,
        goalReached => l10n.statusBannerGoalReached,
        suspended => l10n.statusBannerSuspended,
        frozen => l10n.statusBannerFrozen,
        cancelled => l10n.statusBannerCancelled,
        expired => l10n.statusBannerExpired,
        _ => '',
      };
}
