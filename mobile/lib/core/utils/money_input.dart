import 'package:flutter/services.dart';

/// Accepts digits and at most one decimal point with up to two fraction
/// digits — for donation amount entry. Rejects anything else keystroke by
/// keystroke so the field can never hold a non-parseable value.
class DecimalAmountFormatter extends TextInputFormatter {
  const DecimalAmountFormatter({this.maxFractionDigits = 2});

  final int maxFractionDigits;

  static final _pattern = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!_pattern.hasMatch(text)) return oldValue;
    if ('.'.allMatches(text).length > 1) return oldValue;
    final dot = text.indexOf('.');
    if (dot >= 0 && text.length - dot - 1 > maxFractionDigits) return oldValue;
    return newValue;
  }
}

/// Parses a user-entered amount string to a positive number, or null if it is
/// blank / not a number / not positive.
double? parseAmount(String raw) {
  final v = double.tryParse(raw.trim());
  if (v == null || !v.isFinite || v <= 0) return null;
  return v;
}

/// Money with cents only when needed: `USD 25` / `USD 25.50`.
String formatAmount(num value, String currency) {
  final rounded = (value * 100).round() / 100;
  final isWhole = rounded == rounded.roundToDouble();
  final body = isWhole ? rounded.round().toString() : rounded.toStringAsFixed(2);
  final parts = body.split('.');
  final intPart = parts.first;
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  final grouped = parts.length > 1 ? '$buf.${parts[1]}' : buf.toString();
  return '$currency $grouped';
}
