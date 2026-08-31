/// Thousands-separated integer money with a leading currency code, e.g.
/// `USD 6,400`. Shared by the campaign summary and supporter rows so
/// formatting stays consistent.
String formatMoney(num value, String currency) {
  final s = value.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '$currency $buf';
}
