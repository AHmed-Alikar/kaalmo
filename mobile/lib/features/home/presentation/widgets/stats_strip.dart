import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../campaigns/data/models/platform_stats.dart';

/// Real, derivable platform numbers — never invented totals.
class StatsStrip extends StatelessWidget {
  const StatsStrip({super.key, required this.stats});

  final PlatformStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          _Stat(value: _money(stats.totalRaised), label: l10n.statsRaised),
          _Divider(color: scheme.primary.withValues(alpha: 0.2)),
          _Stat(value: '${stats.campaignCount}', label: l10n.statsCampaigns),
          _Divider(color: scheme.primary.withValues(alpha: 0.2)),
          _Stat(value: '${stats.donorCount}', label: l10n.statsDonors),
        ],
      ),
    );
  }

  static String _money(num value) {
    final s = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '\$$buf';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            child: Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.primary)),
          ),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: color);
}
