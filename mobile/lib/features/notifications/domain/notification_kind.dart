import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';
import '../../../core/theme/app_colors.dart';

/// Presentation category for a backend notification `type` string. The backend
/// emits free-form types (`donation_confirmed`, `campaign_update`,
/// `campaign_reject`, `withdrawal_processing`, `beneficiary_verified`,
/// `team_invite`, `support_reply`, `account_status`, …). Unrecognised types
/// fall back to [system] — never a crash.
enum NotificationKind {
  donation,
  campaignUpdate,
  campaignApproved,
  campaignRejected,
  beneficiary,
  withdrawal,
  team,
  support,
  security,
  system;

  static NotificationKind fromType(String type) {
    final t = type.toLowerCase();
    if (t.startsWith('donation')) return donation;
    if (t == 'campaign_update') return campaignUpdate;
    if (t == 'campaign_reject' || t == 'campaign_suspend') return campaignRejected;
    if (t.startsWith('campaign')) return campaignApproved; // approve/publish/restore/status_change
    if (t == 'beneficiary_rejected') return campaignRejected;
    if (t.startsWith('beneficiary')) return beneficiary;
    if (t.startsWith('withdrawal')) return withdrawal;
    if (t == 'team_invite') return team;
    if (t.startsWith('support')) return support;
    if (t == 'account_status') return security;
    return system;
  }

  IconData get icon => switch (this) {
        donation => Icons.volunteer_activism_outlined,
        campaignUpdate => Icons.campaign_outlined,
        campaignApproved => Icons.verified_outlined,
        campaignRejected => Icons.error_outline,
        beneficiary => Icons.verified_user_outlined,
        withdrawal => Icons.account_balance_wallet_outlined,
        team => Icons.group_add_outlined,
        support => Icons.support_agent_outlined,
        security => Icons.shield_outlined,
        system => Icons.notifications_none,
      };

  /// Accent used for the icon chip. Kept subtle — most kinds share the brand
  /// colour; only genuinely negative events use the error tone.
  Color get accent => switch (this) {
        campaignRejected => AppColors.error,
        security => AppColors.warning,
        _ => AppColors.primary,
      };

  /// Short category label — used for accessibility / grouping, not the tile body
  /// (which shows the backend's own title + message).
  String label(AppL10n l10n) => switch (this) {
        donation => l10n.notifKindDonation,
        campaignUpdate => l10n.notifKindCampaignUpdate,
        campaignApproved => l10n.notifKindCampaignStatus,
        campaignRejected => l10n.notifKindCampaignStatus,
        beneficiary => l10n.notifKindBeneficiary,
        withdrawal => l10n.notifKindWithdrawal,
        team => l10n.notifKindTeam,
        support => l10n.notifKindSupport,
        security => l10n.notifKindSecurity,
        system => l10n.notifKindSystem,
      };
}
