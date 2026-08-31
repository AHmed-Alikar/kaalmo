import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/campaign_status.dart';

/// Compact status pill for a campaign in an organizer context (draft, in
/// review, live, completed, …). Colour follows the lifecycle stage.
class CampaignStatusPill extends StatelessWidget {
  const CampaignStatusPill({super.key, required this.status});

  final CampaignStatusView status;

  Color get _color {
    if (status.isNegative || status == CampaignStatusView.rejected) return AppColors.error;
    if (status == CampaignStatusView.completed || status == CampaignStatusView.goalReached) {
      return AppColors.success;
    }
    if (status.isInReviewPipeline) return AppColors.warning;
    if (status.isOpenForDonations || status == CampaignStatusView.withdrawal) return AppColors.info;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label(context.l10n),
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
