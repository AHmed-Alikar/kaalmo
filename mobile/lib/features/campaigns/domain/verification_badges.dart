import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';

/// The four verification badge values the backend places on
/// `Campaign.verificationBadges`. Nothing here is invented — a badge is only
/// shown when the backend returns it.
enum CampaignBadge {
  identityVerified('identity_verified', Icons.verified_user_outlined),
  beneficiaryVerified('beneficiary_verified', Icons.shield_outlined),
  organizationVerified('organization_verified', Icons.domain_verification_outlined),
  paymentVerified('payment_verified', Icons.payments_outlined);

  const CampaignBadge(this.value, this.icon);

  final String value;
  final IconData icon;

  String label(AppL10n l10n) => switch (this) {
        CampaignBadge.identityVerified => l10n.badgeIdentityVerified,
        CampaignBadge.beneficiaryVerified => l10n.badgeBeneficiaryVerified,
        CampaignBadge.organizationVerified => l10n.badgeOrganizationVerified,
        CampaignBadge.paymentVerified => l10n.badgePaymentVerified,
      };

  static CampaignBadge? fromValue(String value) {
    for (final b in CampaignBadge.values) {
      if (b.value == value) return b;
    }
    return null;
  }
}

/// Parse the raw string list, dropping anything unrecognised.
List<CampaignBadge> parseBadges(Iterable<String> raw) =>
    raw.map(CampaignBadge.fromValue).whereType<CampaignBadge>().toList();
