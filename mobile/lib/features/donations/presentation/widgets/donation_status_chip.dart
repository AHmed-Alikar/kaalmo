import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../domain/donation_status.dart';

/// Small status pill for a donation, coloured by [DonationStatusView].
class DonationStatusChip extends StatelessWidget {
  const DonationStatusChip({super.key, required this.status, this.dense = false});

  final DonationStatusView status;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: dense ? 12 : 14, color: color),
          const SizedBox(width: 5),
          Text(
            status.label(l10n),
            style: TextStyle(fontSize: dense ? 11 : 12, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
