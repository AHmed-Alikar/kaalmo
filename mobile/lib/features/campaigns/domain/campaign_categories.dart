import 'package:flutter/material.dart';

import '../../../core/localization/l10n.dart';

/// The backend exposes no categories endpoint — the set is a fixed enum on
/// the `Campaign` model. This list mirrors that enum exactly (the `value` is
/// what the `?category=` query param expects); labels are localized and icons
/// are UI-only.
class CampaignCategory {
  const CampaignCategory(this.value, this.icon);

  final String value;
  final IconData icon;

  String label(AppL10n l10n) => switch (value) {
        'Medical' => l10n.categoryMedical,
        'Education' => l10n.categoryEducation,
        'Emergency' => l10n.categoryEmergency,
        'Family' => l10n.categoryFamily,
        'Funeral' => l10n.categoryFuneral,
        'Community' => l10n.categoryCommunity,
        'Mosque' => l10n.categoryMosque,
        'School' => l10n.categorySchool,
        'Orphan Support' => l10n.categoryOrphanSupport,
        'Disaster Relief' => l10n.categoryDisasterRelief,
        'Business/Startup' => l10n.categoryBusiness,
        'NGO' => l10n.categoryNgo,
        'Public Projects' => l10n.categoryPublicProjects,
        _ => l10n.categoryOther,
      };
}

const kCampaignCategories = <CampaignCategory>[
  CampaignCategory('Medical', Icons.medical_services_outlined),
  CampaignCategory('Emergency', Icons.emergency_outlined),
  CampaignCategory('Education', Icons.school_outlined),
  CampaignCategory('Family', Icons.family_restroom_outlined),
  CampaignCategory('Funeral', Icons.local_florist_outlined),
  CampaignCategory('Community', Icons.groups_outlined),
  CampaignCategory('Mosque', Icons.mosque_outlined),
  CampaignCategory('School', Icons.cases_outlined),
  CampaignCategory('Orphan Support', Icons.volunteer_activism_outlined),
  CampaignCategory('Disaster Relief', Icons.cyclone_outlined),
  CampaignCategory('Business/Startup', Icons.storefront_outlined),
  CampaignCategory('NGO', Icons.diversity_3_outlined),
  CampaignCategory('Public Projects', Icons.account_balance_outlined),
  CampaignCategory('Other', Icons.category_outlined),
];

CampaignCategory? categoryByValue(String? value) {
  if (value == null || value.isEmpty) return null;
  for (final c in kCampaignCategories) {
    if (c.value == value) return c;
  }
  return null;
}

/// Localized label for a raw category value (used on cards where we only have
/// the string). Falls back to the raw value for anything unexpected.
String categoryLabelFor(String value, AppL10n l10n) =>
    categoryByValue(value)?.label(l10n) ?? value;

/// `Campaign.region` is a free-text field; the backend has no region list.
/// These mirror the four regions the web client offers as filters.
const kCampaignRegions = <String>['Mogadishu', 'Hargeisa', 'Puntland', 'Nairobi'];
