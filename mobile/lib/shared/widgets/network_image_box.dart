import 'package:flutter/material.dart';

/// Remote image with a themed loading placeholder and a graceful broken-image
/// fallback. Uses Flutter's built-in in-memory `ImageCache` (adequate for a
/// browsing session); persistent disk caching can be layered in later without
/// touching call sites.
class NetworkImageBox extends StatelessWidget {
  const NetworkImageBox({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_outlined,
    this.cacheWidth = 800,
  });

  final String? url;
  final BoxFit fit;
  final IconData fallbackIcon;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(fallbackIcon, color: scheme.onSurfaceVariant, size: 28)),
    );

    if (url == null || url!.isEmpty) return placeholder;

    return Image.network(
      url!,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, _, _) => ColoredBox(
        color: scheme.surfaceContainerHighest,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant, size: 26),
        ),
      ),
    );
  }
}
