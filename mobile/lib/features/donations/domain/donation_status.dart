import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';
import '../../../core/theme/app_colors.dart';

/// Presentation of a `Donation.status` value. Mirrors the backend enum
/// (`pending | confirmed | failed | refunded`) — no invented statuses. An
/// unrecognised value falls back to [unknown] rather than crashing.
enum DonationStatusView {
  pending,
  confirmed,
  failed,
  refunded,
  unknown;

  static DonationStatusView from(String? raw) => switch (raw) {
        'pending' => pending,
        'confirmed' => confirmed,
        'failed' => failed,
        'refunded' => refunded,
        _ => unknown,
      };

  String label(AppL10n l10n) => switch (this) {
        pending => l10n.donationStatusPending,
        confirmed => l10n.donationStatusConfirmed,
        failed => l10n.donationStatusFailed,
        refunded => l10n.donationStatusRefunded,
        unknown => l10n.donationStatusUnknown,
      };

  Color get color => switch (this) {
        confirmed => AppColors.success,
        pending => AppColors.warning,
        failed => AppColors.error,
        refunded => AppColors.info,
        unknown => AppColors.textSecondary,
      };

  IconData get icon => switch (this) {
        confirmed => Icons.check_circle_outline,
        pending => Icons.schedule,
        failed => Icons.error_outline,
        refunded => Icons.replay_outlined,
        unknown => Icons.help_outline,
      };
}
