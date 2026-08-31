import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money_format.dart';
import '../../../../core/utils/relative_time.dart';
import '../../data/models/supporter.dart';

/// A recent supporter. Anonymous donors show as "Anonymous" — the backend
/// never sends their name.
class SupporterTile extends StatelessWidget {
  const SupporterTile({super.key, required this.supporter});

  final Supporter supporter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: scheme.primary.withValues(alpha: 0.12),
          child: Icon(
            supporter.isAnonymous ? Icons.person_off_outlined : Icons.favorite_outline,
            size: 18,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      supporter.isAnonymous ? l10n.supporterAnonymous : supporter.donorName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(formatMoney(supporter.amount, supporter.currency),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: scheme.primary)),
                ],
              ),
              if (supporter.message != null) ...[
                const SizedBox(height: 2),
                Text('“${supporter.message}”',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 2),
              Text(formatRelative(supporter.createdAt, l10n),
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
