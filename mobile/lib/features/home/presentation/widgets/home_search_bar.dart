import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/router/app_routes.dart';

/// Read-only search affordance on Home — tapping it opens Explore with the
/// search field focused. Keeps Home light and defers the real search UX to
/// one place (Explore).
class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('${AppRoutes.explore}?focus=1'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                context.l10n.homeSearchHint,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
