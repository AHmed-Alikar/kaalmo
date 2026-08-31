import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../shared/widgets/network_image_box.dart';
import '../../data/models/campaign.dart';
import '../../domain/campaign_status.dart';
import 'media_gallery.dart';

/// Cover image + (optional) media-gallery entry point + status pill.
class CampaignHero extends StatelessWidget {
  const CampaignHero({super.key, required this.campaign});

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = CampaignStatusView.from(campaign.status);

    final gallery = <String>[
      if (campaign.coverImageUrl != null && campaign.coverImageUrl!.isNotEmpty) campaign.coverImageUrl!,
      ...campaign.mediaUrls,
    ];
    final extraCount = gallery.length - 1;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: GestureDetector(
        onTap: gallery.isEmpty ? null : () => MediaGalleryPage.open(context, gallery),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageBox(url: campaign.coverImageUrl, cacheWidth: 1200),
            // Legibility gradient for the pills.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black26, Colors.transparent, Colors.black38],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            if (status.needsBanner)
              Positioned(
                top: 12,
                left: 12,
                child: _Pill(
                  text: status.label(l10n),
                  color: status.isNegative ? Colors.black87 : Theme.of(context).colorScheme.primary,
                ),
              ),
            if (extraCount > 0)
              Positioned(
                bottom: 12,
                right: 12,
                child: _Pill(text: l10n.galleryMoreCount(extraCount), color: Colors.black54, icon: Icons.photo_library_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: Colors.white), const SizedBox(width: 5)],
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
