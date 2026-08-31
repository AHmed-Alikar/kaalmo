import 'dart:math';

/// A fresh key for one payment attempt. Sent as the `Idempotency-Key` header so
/// a retried donation (double tap, network retry, timeout retry) returns the
/// original result instead of charging again. The backend scopes the key to the
/// caller, so it only needs to be unique per attempt — not globally.
String newIdempotencyKey() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  return 'kaalmo-$ts-$hex';
}
