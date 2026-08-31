import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money_input.dart';

/// A plain donation receipt built only from data the backend returned. No
/// private payment details (no phone, no PIN, no provider response) are shown.
///
/// Shared by the post-donation success screen and the My Donations detail
/// screen — each passes only the fields it actually has (method / status are
/// optional).
class DonationReceiptCard extends StatelessWidget {
  const DonationReceiptCard({
    super.key,
    required this.campaignTitle,
    required this.amount,
    required this.currency,
    required this.isAnonymous,
    this.date,
    this.statusLabel,
    this.statusColor,
    this.methodLabel,
    this.reference,
    this.message,
  });

  final String campaignTitle;
  final num amount;
  final String currency;
  final bool isAnonymous;
  final DateTime? date;
  final String? statusLabel;
  final Color? statusColor;
  final String? methodLabel;
  final String? reference;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final created = date?.toLocal();

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
          Text(l10n.receiptTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _Row(label: l10n.receiptCampaign, value: campaignTitle),
          _Row(label: l10n.receiptAmount, value: formatAmount(amount, currency)),
          if (created != null)
            _Row(
              label: l10n.receiptDate,
              value: '${created.year}-${_two(created.month)}-${_two(created.day)}  '
                  '${_two(created.hour)}:${_two(created.minute)}',
            ),
          if (statusLabel != null)
            _Row(label: l10n.receiptStatus, value: statusLabel!, valueColor: statusColor),
          if (methodLabel != null) _Row(label: l10n.receiptMethod, value: methodLabel!),
          _Row(
            label: l10n.receiptVisibility,
            value: isAnonymous ? l10n.donateAnonymousYes : l10n.donateAnonymousNo,
          ),
          if (reference != null && reference!.isNotEmpty)
            _Row(label: l10n.receiptReference, value: reference!, mono: true),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(l10n.receiptMessage, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text('“$message”',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.mono = false, this.valueColor});

  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
