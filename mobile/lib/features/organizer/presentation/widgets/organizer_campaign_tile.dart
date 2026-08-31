import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money_input.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/network_image_box.dart';
import '../../../campaigns/data/models/campaign.dart';
import '../../../campaigns/domain/campaign_categories.dart';
import '../../../campaigns/domain/campaign_status.dart';
import '../../../campaigns/presentation/widgets/campaign_status_pill.dart';

/// One campaign row in the organizer's list — status-forward, not donor-facing.
class OrganizerCampaignTile extends StatelessWidget {
  const OrganizerCampaignTile({super.key, required this.campaign, required this.onTap});

  final Campaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                      width: 52,
                      height: 52,
                      child: NetworkImageBox(url: campaign.coverImageUrl, cacheWidth: 150),
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
                        const SizedBox(height: 3),
                        Text(
                          categoryLabelFor(campaign.category, l10n),
                          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CampaignStatusPill(status: CampaignStatusView.from(campaign.status)),
                  if (campaign.isCoOrganizer) ...[
                    const SizedBox(width: 6),
                    _Chip(text: l10n.organizerRoleCoOrganizer),
                  ],
                  const Spacer(),
                  Text(
                    formatAmount(campaign.raisedAmount, campaign.currency),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: scheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(
                raised: campaign.raisedAmount,
                goal: campaign.goalAmount,
                currency: campaign.currency,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
    );
  }
}
