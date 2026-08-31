import 'package:flutter/material.dart';

import '../widgets/app_progress_bar.dart';
import '../widgets/network_image_box.dart';
import '../widgets/verification_badge.dart';

/// Presentation-only campaign card. Takes primitives (not a data-layer model)
/// so it can be previewed and reused anywhere. Feature code maps its
/// `Campaign` onto these props.
class CampaignCardShell extends StatelessWidget {
  const CampaignCardShell({
    super.key,
    required this.title,
    required this.raised,
    required this.goal,
    this.category,
    this.imageUrl,
    this.currency = 'USD',
    this.verification,
    this.statusLabel,
    this.location,
    this.completed = false,
    this.onTap,
    this.compact = false,
  });

  final String title;
  final num raised;
  final num goal;
  final String? category;
  final String? imageUrl;
  final String currency;
  final VerificationLevel? verification;
  final String? statusLabel;
  final String? location;
  final bool completed;
  final VoidCallback? onTap;

  /// Narrower layout for horizontal "featured" carousels.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: NetworkImageBox(url: imageUrl)),
                if (completed)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _Pill(text: statusLabel ?? '', color: scheme.primary),
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 12 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (category != null)
                        Expanded(
                          child: Text(
                            category!.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w700,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      if (verification != null) VerificationBadge(level: verification!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 14 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (location != null && location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 13, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(location!, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  AppProgressBar(raised: raised, goal: goal, currency: currency, compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
