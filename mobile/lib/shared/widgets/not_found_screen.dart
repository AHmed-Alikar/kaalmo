import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n.dart';
import '../../core/router/app_routes.dart';
import '../buttons/primary_button.dart';

/// GoRouter's fallback when a path doesn't match — a calm, localized "not found"
/// with a way back home. Never shown in normal use.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFoundTitle)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_outline, size: 48, color: scheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(l10n.notFoundBody,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: scheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.notFoundGoHome,
                  fullWidth: false,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
