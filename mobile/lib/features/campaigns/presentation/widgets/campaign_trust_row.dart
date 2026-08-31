import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/verification_badges.dart';

/// Trust section — shows only the verification badges the backend actually
/// returned. Renders nothing when there are none (badges are never invented).
class CampaignTrustRow extends StatelessWidget {
  const CampaignTrustRow({super.key, required this.rawBadges});

  final List<String> rawBadges;

  @override
  Widget build(BuildContext context) {
    final badges = parseBadges(rawBadges);
    if (badges.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.trustSectionTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final b in badges) _BadgeChip(icon: b.icon, label: b.label(l10n))],
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.success),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.success)),
        ],
      ),
    );
  }
}
