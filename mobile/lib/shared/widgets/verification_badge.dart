import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum VerificationLevel { verified, pending, unverified }

/// Trust marker used on campaigns / organizers. Tappable to explain what it
/// means (wired by the caller).
class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.level,
    this.label,
    this.onTap,
  });

  final VerificationLevel level;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (color, icon, fallback) = switch (level) {
      VerificationLevel.verified => (AppColors.success, Icons.verified_outlined, 'Verified'),
      VerificationLevel.pending => (AppColors.warning, Icons.hourglass_empty, 'Pending review'),
      VerificationLevel.unverified => (AppColors.textSecondary, Icons.help_outline, 'Not verified'),
    };

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label ?? fallback,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: chip,
    );
  }
}
