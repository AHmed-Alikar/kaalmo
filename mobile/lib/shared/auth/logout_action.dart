import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../core/localization/l10n.dart';

/// App-bar logout button + confirm dialog. Reused wherever an authenticated
/// screen needs a sign-out affordance. After [AuthController.logout] the auth
/// state flips and GoRouter redirects to `/login`.
class LogoutAction extends ConsumerWidget {
  const LogoutAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: l10n.authLogOut,
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.logoutConfirmTitle),
            content: Text(l10n.logoutConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.authLogOut),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authControllerProvider.notifier).logout();
        }
      },
    );
  }
}
