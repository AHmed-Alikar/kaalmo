import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/l10n.dart';
import '../../core/router/app_routes.dart';
import '../buttons/primary_button.dart';
import '../buttons/secondary_button.dart';

/// Shown when an unauthenticated user taps a protected action (follow / save /
/// comment / report). On "Log in" it routes to `/login?from=<returnTo>` so the
/// router can bring the user back to the campaign after authenticating.
Future<void> showLoginRequiredSheet(
  BuildContext context, {
  required String actionLabel,
  required String returnTo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 36, color: Theme.of(sheetContext).colorScheme.primary),
              const SizedBox(height: 12),
              Text(l10n.loginRequiredTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l10n.loginRequiredBody(actionLabel),
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                      )),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l10n.authLogIn,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  sheetContext.push('${AppRoutes.login}?from=${Uri.encodeQueryComponent(returnTo)}');
                },
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: l10n.actionCancel,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
