import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../domain/payment_method.dart';

/// Radio list of the payment providers the backend reports. Provider-agnostic:
/// an unrecognised id still shows (labelled by its id).
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.providerIds,
    required this.selectedId,
    required this.onSelected,
    this.enabled = true,
  });

  final List<String> providerIds;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    if (providerIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(l10n.payNoMethods,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
      );
    }

    return Column(
      children: [
        for (final id in providerIds)
          Builder(builder: (context) {
            final method = PaymentMethod(id);
            final selected = id == selectedId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: selected ? scheme.primary.withValues(alpha: 0.06) : scheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: selected ? 1.6 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: enabled ? () => onSelected(id) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(method.icon, color: scheme.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(method.title(l10n),
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              const SizedBox(height: 2),
                              Text(method.subtitle(l10n),
                                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: selected ? scheme.primary : scheme.outline,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
