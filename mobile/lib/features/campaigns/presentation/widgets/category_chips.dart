import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../domain/campaign_categories.dart';

/// Horizontal, scrollable category selector. `null` selection = "All".
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String? selected;
  final ValueChanged<String?> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: kCampaignCategories.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _Chip(
              label: l10n.categoryAll,
              icon: Icons.grid_view_rounded,
              selected: selected == null,
              onTap: () => onSelected(null),
            );
          }
          final category = kCampaignCategories[index - 1];
          return _Chip(
            label: category.label(l10n),
            icon: category.icon,
            selected: selected == category.value,
            onTap: () => onSelected(category.value),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 16, color: selected ? scheme.onPrimary : scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
