import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Inline, dismissible-feeling error strip shown above an auth form. Renders
/// nothing when [message] is null so screens can place it unconditionally.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key, this.tone = AuthBannerTone.error});

  final String? message;
  final AuthBannerTone tone;

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) return const SizedBox.shrink();

    final (color, icon) = switch (tone) {
      AuthBannerTone.error => (AppColors.error, Icons.error_outline),
      AuthBannerTone.info => (AppColors.info, Icons.info_outline),
      AuthBannerTone.success => (AppColors.success, Icons.check_circle_outline),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(fontSize: 13, color: color, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

enum AuthBannerTone { error, info, success }
