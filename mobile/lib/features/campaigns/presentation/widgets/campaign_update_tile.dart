import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../shared/widgets/network_image_box.dart';
import '../../data/models/campaign_update.dart';
import 'media_gallery.dart';

class CampaignUpdateTile extends StatelessWidget {
  const CampaignUpdateTile({super.key, required this.update});

  final CampaignUpdate update;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.campaign_outlined, size: 15, color: scheme.primary),
            const SizedBox(width: 6),
            Text(l10n.updateFromOrganizer,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: scheme.primary)),
            const Spacer(),
            Text(formatRelative(update.createdAt, l10n),
                style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        Text(update.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
        if (update.imageUrl != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => MediaGalleryPage.open(context, [update.imageUrl!]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(aspectRatio: 16 / 9, child: NetworkImageBox(url: update.imageUrl)),
            ),
          ),
        ],
      ],
    );
  }
}
