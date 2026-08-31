import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/money_input.dart';
import '../../../../core/utils/relative_time.dart';
import '../../../../shared/widgets/network_image_box.dart';
import '../../data/models/my_donation.dart';
import 'donation_status_chip.dart';

/// One row in the donor's history: campaign thumbnail + name, amount, date and
/// status. Falls back gracefully when the campaign has been deleted.
class MyDonationTile extends StatelessWidget {
  const MyDonationTile({super.key, required this.donation, required this.onTap});

  final MyDonation donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final campaignName = donation.campaign?.titleFor(lang) ?? l10n.donationCampaignUnavailable;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: NetworkImageBox(url: donation.campaign?.coverImageUrl, cacheWidth: 150),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaignName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.25),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          formatAmount(donation.amount, donation.currency),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: scheme.primary,
                          ),
                        ),
                        if (donation.isAnonymous) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.visibility_off_outlined, size: 13, color: scheme.onSurfaceVariant),
                        ],
                        const Spacer(),
                        Text(
                          formatRelative(donation.createdAt, l10n),
                          style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DonationStatusChip(status: donation.statusView, dense: true),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
