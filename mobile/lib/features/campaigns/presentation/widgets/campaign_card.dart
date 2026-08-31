import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/cards/campaign_card_shell.dart';
import '../../../../shared/widgets/verification_badge.dart';
import '../../data/models/campaign.dart';
import '../../domain/campaign_categories.dart';

/// Real campaign card: maps a [Campaign] onto [CampaignCardShell] and routes
/// to `/campaign/:id` on tap. Only fields the API actually provides are shown
/// (no organizer name — the list endpoint doesn't populate it).
class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required this.campaign, this.compact = false, this.onTap});

  final Campaign campaign;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;

    return CampaignCardShell(
      title: campaign.titleFor(lang),
      raised: campaign.raisedAmount,
      goal: campaign.goalAmount,
      currency: campaign.currency,
      category: categoryLabelFor(campaign.category, l10n),
      imageUrl: campaign.coverImageUrl,
      location: campaign.region,
      compact: compact,
      completed: campaign.isCompleted,
      statusLabel: campaign.isCompleted ? l10n.campaignCompleted : null,
      verification: campaign.isVerified ? VerificationLevel.verified : null,
      onTap: onTap ?? () => context.push(AppRoutes.campaign(campaign.id)),
    );
  }
}
