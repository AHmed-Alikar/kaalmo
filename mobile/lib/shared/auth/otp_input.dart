import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A single 6-digit numeric code entry used by email verification and
/// password reset. Deliberately one field (not 6 boxes) — simpler, pastes
/// cleanly, and works well with autofill on low-end devices.
class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required this.controller,
    this.errorText,
    this.enabled = true,
    this.onCompleted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  static const length = 6;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      autofillHints: const [AutofillHints.oneTimeCode],
      maxLength: length,
      style: const TextStyle(fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.w700),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        counterText: '',
        hintText: '––––––',
        hintStyle: const TextStyle(letterSpacing: 10),
        errorText: errorText,
      ),
      onChanged: (value) {
        onChanged?.call(value);
        if (value.length == length) onCompleted?.call(value);
      },
    );
  }
}
