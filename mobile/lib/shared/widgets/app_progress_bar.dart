import 'package:flutter/material.dart';

/// Fundraising progress — a bar plus the real numbers (never just a visual).
/// Text rows use flexible children so long amounts can't overflow.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.raised,
    required this.goal,
    this.currency = 'USD',
    this.compact = false,
  });

  final num raised;
  final num goal;
  final String currency;
  final bool compact;

  double get _fraction {
    if (goal <= 0) return 0;
    final r = raised / goal;
    if (r.isNaN || r.isInfinite || r < 0) return 0;
    return r > 1 ? 1 : r.toDouble();
  }

  int get _percent => (_fraction * 100).round();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: _fraction,
            minHeight: compact ? 6 : 8,
            backgroundColor: scheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
        SizedBox(height: compact ? 5 : 7),
        Row(
          children: [
            Expanded(
              child: Text(
                '$currency ${_format(raised)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_percent%',
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ],
        ),
        if (!compact)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'of $currency ${_format(goal)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  static String _format(num value) {
    final s = value.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
