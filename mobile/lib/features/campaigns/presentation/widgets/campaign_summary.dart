import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../data/models/campaign.dart';
import '../../domain/campaign_categories.dart';

/// Title, category · region, the progress block, and the supporter count.
class CampaignSummary extends StatelessWidget {
  const CampaignSummary({super.key, required this.campaign, this.supporterCount});

  final Campaign campaign;

  /// From the supporters endpoint — null while it loads / on failure.
  final int? supporterCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    final metaBits = <String>[
      categoryLabelFor(campaign.category, l10n),
      if (campaign.subcategory != null && campaign.subcategory!.isNotEmpty) campaign.subcategory!,
      if (campaign.region != null && campaign.region!.isNotEmpty) campaign.region!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(campaign.titleFor(lang),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.25)),
        const SizedBox(height: 8),
        Text(metaBits.join('  ·  '),
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        const SizedBox(height: 18),

        Text(l10n.campaignRaisedAmount(formatMoney(campaign.raisedAmount, campaign.currency)),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: scheme.primary)),
        const SizedBox(height: 4),
        Text(l10n.campaignOfGoal(formatMoney(campaign.goalAmount, campaign.currency)),
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        AppProgressBar(raised: campaign.raisedAmount, goal: campaign.goalAmount, currency: campaign.currency),
        const SizedBox(height: 10),

        Row(
          children: [
            Icon(Icons.people_outline, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              supporterCount == null
                  ? l10n.campaignFundedPercent(campaign.progressPercent)
                  : l10n.campaignSupportersLine(supporterCount!, campaign.progressPercent),
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ),

        if (campaign.endDate != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(_endDateLabel(context, campaign.endDate!, l10n),
                  style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ],
    );
  }

  static String _endDateLabel(BuildContext context, DateTime endDate, AppL10n l10n) {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return l10n.campaignEnded;
    final days = endDate.difference(now).inDays;
    return days <= 0 ? l10n.campaignEndsToday : l10n.campaignDaysLeft(days);
  }
}
