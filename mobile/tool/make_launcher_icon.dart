// One-off: turns the Kaalmo logo (client/public/favicon.png, copied to
// assets/icon/kaalmo_icon_src.png) into a tight 1024x1024 launcher source with
// a small, even margin so the adaptive-icon mask doesn't crop the mark.
//
//   dart run tool/make_launcher_icon.dart
//
// Output: assets/icon/kaalmo_icon.png
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('assets/icon/kaalmo_icon_src.png').readAsBytesSync())!;

  // Find the non-white content bounds (the logo mark).
  int minX = src.width, minY = src.height, maxX = 0, maxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      final isWhiteish = p.r > 245 && p.g > 245 && p.b > 245;
      if (!isWhiteish) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  final cw = maxX - minX + 1;
  final ch = maxY - minY + 1;
  final side = (cw > ch ? cw : ch);
  // ~62% of the canvas is the mark → comfortable inside the adaptive safe zone.
  final canvas = (side / 0.62).round();
  final out = img.Image(width: canvas, height: canvas)
    ..clear(img.ColorRgb8(255, 255, 255));

  final cropped = img.copyCrop(src, x: minX, y: minY, width: cw, height: ch);
  img.compositeImage(
    out,
    cropped,
    dstX: ((canvas - cw) / 2).round(),
    dstY: ((canvas - ch) / 2).round(),
  );

  final resized = img.copyResize(out, width: 1024, height: 1024, interpolation: img.Interpolation.cubic);
  File('assets/icon/kaalmo_icon.png').writeAsBytesSync(img.encodePng(resized));
  stdout.writeln('wrote assets/icon/kaalmo_icon.png (content ${cw}x$ch -> 1024x1024, canvas $canvas)');
}
