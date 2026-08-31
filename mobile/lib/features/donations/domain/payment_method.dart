import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';

/// A payment provider the backend says is available, mapped to display copy.
/// The layer stays provider-agnostic: an unknown id still renders (labelled by
/// its id) rather than crashing or being silently dropped.
class PaymentMethod {
  const PaymentMethod(this.id);

  final String id;

  bool get requiresPhone => id == 'evc_plus';

  IconData get icon => switch (id) {
        'evc_plus' => Icons.smartphone_outlined,
        'manual' => Icons.volunteer_activism_outlined,
        'bank' => Icons.account_balance_outlined,
        'card' => Icons.credit_card_outlined,
        _ => Icons.payments_outlined,
      };

  String title(AppL10n l10n) => switch (id) {
        'evc_plus' => l10n.payMethodEvcPlusTitle,
        'manual' => l10n.payMethodManualTitle,
        'bank' => l10n.payMethodBankTitle,
        'card' => l10n.payMethodCardTitle,
        _ => id,
      };

  String subtitle(AppL10n l10n) => switch (id) {
        'evc_plus' => l10n.payMethodEvcPlusSubtitle,
        'manual' => l10n.payMethodManualSubtitle,
        'bank' => l10n.payMethodBankSubtitle,
        'card' => l10n.payMethodCardSubtitle,
        _ => l10n.payMethodGenericSubtitle,
      };
}
