import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../shared/widgets/network_image_box.dart';

/// Full-screen, swipeable image viewer. Pushed as an opaque page route.
class MediaGalleryPage extends StatefulWidget {
  const MediaGalleryPage({super.key, required this.imageUrls, this.initialIndex = 0});

  final List<String> imageUrls;
  final int initialIndex;

  static Future<void> open(BuildContext context, List<String> imageUrls, {int initialIndex = 0}) {
    if (imageUrls.isEmpty) return Future.value();
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MediaGalleryPage(imageUrls: imageUrls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  State<MediaGalleryPage> createState() => _MediaGalleryPageState();
}

class _MediaGalleryPageState extends State<MediaGalleryPage> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.imageUrls.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: count > 1 ? Text(context.l10n.galleryCounter(_index + 1, count)) : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: count,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: NetworkImageBox(url: widget.imageUrls[i], fit: BoxFit.contain, cacheWidth: 1600),
          ),
        ),
      ),
    );
  }
}
