// One-off: generates the FCM status-bar notification icon as raster PNGs.
//
// FCM's `default_notification_icon` must be a raster (pure-alpha) drawable for
// the system to render it reliably when the app is backgrounded / terminated —
// a VectorDrawable there can make the background notification silently fail to
// post on some Android builds. Android uses only the alpha channel of this
// image, so it is a solid-white bell silhouette on transparency.
//
//   dart run tool/make_notification_icon.dart
//
// Writes android/app/src/main/res/drawable-{m,h,x,xx,xxx}hdpi/ic_stat_notification.png
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

const _base = 96; // xxxhdpi px; other densities scale down from this
const _densities = {
  'mdpi': 24,
  'hdpi': 36,
  'xhdpi': 48,
  'xxhdpi': 72,
  'xxxhdpi': 96,
};

void main() {
  final canvas = img.Image(width: _base, height: _base, numChannels: 4);
  // start fully transparent
  img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 0));

  final white = img.ColorRgba8(255, 255, 255, 255);

  // Bell body: dome (circle) + flared skirt (polygon) + rim.
  img.fillCircle(canvas, x: 48, y: 42, radius: 22, color: white);
  img.fillPolygon(
    canvas,
    vertices: [
      img.Point(26, 42),
      img.Point(70, 42),
      img.Point(80, 70),
      img.Point(16, 70),
    ],
    color: white,
  );
  // rim
  img.fillRect(canvas, x1: 14, y1: 66, x2: 82, y2: 74, radius: 3, color: white);
  // handle on top
  img.fillCircle(canvas, x: 48, y: 14, radius: 5, color: white);
  // clapper
  img.fillCircle(canvas, x: 48, y: 84, radius: 7, color: white);

  // Anti-alias a touch by rendering at base then Gaussian-free downscale.
  for (final entry in _densities.entries) {
    final size = entry.value;
    final resized = img.copyResize(
      canvas,
      width: size,
      height: size,
      interpolation: img.Interpolation.average,
    );
    final dir = Directory('android/app/src/main/res/drawable-${entry.key}');
    dir.createSync(recursive: true);
    final file = File('${dir.path}/ic_stat_notification.png');
    file.writeAsBytesSync(img.encodePng(resized));
    stdout.writeln('wrote ${file.path} (${size}x$size)');
  }
  // touch math import so analyzer stays quiet if the shape is simplified later
  assert(math.pi > 3);
}
