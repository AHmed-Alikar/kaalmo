import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/network_image_box.dart';
import '../../../campaigns/data/models/campaign.dart';
import '../../../campaigns/domain/campaign_categories.dart';
import '../../../../core/localization/l10n.dart';

/// Compact "what you're supporting" card shown at the top of every donation
/// step so the donor always sees the campaign and its live progress.
class DonateCampaignHeader extends StatelessWidget {
  const DonateCampaignHeader({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: NetworkImageBox(url: campaign.coverImageUrl, cacheWidth: 160),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.titleFor(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.25),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      categoryLabelFor(campaign.category, l10n),
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(
            raised: campaign.raisedAmount,
            goal: campaign.goalAmount,
            currency: campaign.currency,
            compact: true,
          ),
        ],
      ),
    );
  }
}
