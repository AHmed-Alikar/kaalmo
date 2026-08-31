import 'package:flutter/material.dart';

/// Kaalmo design-system palette. Kept as raw tokens so widgets can reference a
/// role directly when the [ColorScheme] doesn't express it (borders, the
/// distinct info / warning colours, etc.).
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF0B7189);
  static const primaryDark = Color(0xFF07566A);
  static const accent = Color(0xFFD8A63C);

  static const background = Color(0xFFF8FAF9);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF172121);
  static const textSecondary = Color(0xFF5E6B6B);
  static const border = Color(0xFFDCE4E3);

  static const success = Color(0xFF2E7D5B);
  static const warning = Color(0xFFB7791F);
  static const error = Color(0xFFC94A4A);
  static const info = Color(0xFF3478A6);

  // Dark-theme surfaces (derived; the brand hues stay constant).
  static const darkBackground = Color(0xFF0E1514);
  static const darkSurface = Color(0xFF16211F);
  static const darkTextPrimary = Color(0xFFEAF1EF);
  static const darkTextSecondary = Color(0xFF9BABA8);
  static const darkBorder = Color(0xFF2A3835);
}
