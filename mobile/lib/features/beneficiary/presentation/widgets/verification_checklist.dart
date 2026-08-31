import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';

class VerificationItem {
  const VerificationItem({required this.label, required this.done, this.pending = false});
  final String label;
  final bool done;
  final bool pending;
}

/// Shows only the verification states the backend actually reports
/// (`/users/me` flags + the beneficiary profile status).
class VerificationChecklist extends StatelessWidget {
  const VerificationChecklist({super.key, required this.items});

  final List<VerificationItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.beneficiaryVerificationTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    item.done
                        ? Icons.check_circle
                        : (item.pending ? Icons.hourglass_bottom : Icons.radio_button_unchecked),
                    size: 18,
                    color: item.done
                        ? AppColors.success
                        : (item.pending ? AppColors.warning : scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.label, style: const TextStyle(fontSize: 13.5))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
