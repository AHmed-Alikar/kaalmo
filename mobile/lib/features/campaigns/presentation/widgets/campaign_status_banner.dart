import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/campaign_status.dart';

/// A calm, informative banner for a campaign that is completed, suspended,
/// frozen, cancelled or expired. Nothing is shown for a normal live campaign.
class CampaignStatusBanner extends StatelessWidget {
  const CampaignStatusBanner({super.key, required this.status});

  final CampaignStatusView status;

  @override
  Widget build(BuildContext context) {
    if (!status.needsBanner) return const SizedBox.shrink();
    final l10n = context.l10n;

    final (color, icon) = status.isNegative
        ? (AppColors.warning, Icons.info_outline)
        : (AppColors.success, Icons.check_circle_outline);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.label(l10n),
                    style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
                const SizedBox(height: 2),
                Text(status.bannerMessage(l10n),
                    style: TextStyle(fontSize: 12.5, color: color, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
