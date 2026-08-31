import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/states/state_views.dart';
import '../data/models/my_donation.dart';
import 'widgets/donation_receipt_card.dart';

/// Receipt / details for one donation from the donor's history, on
/// `/profile/donations/:id`. The backend has no per-donation endpoint, so the
/// donation is read from the already-loaded history list.
class DonationDetailScreen extends ConsumerWidget {
  const DonationDetailScreen({super.key, required this.donationId});

  final String donationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final history = ref.watch(myDonationsProvider);
    final donation = ref.watch(myDonationByIdProvider(donationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donationDetailTitle)),
      body: SafeArea(
        child: history.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.myDonationsErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(myDonationsProvider),
          ),
          data: (_) {
            if (donation == null) {
              return EmptyView(
                icon: Icons.receipt_long_outlined,
                title: l10n.donationNotFoundTitle,
                message: l10n.donationNotFoundBody,
                actionLabel: l10n.donationBackToList,
                onAction: () => context.canPop() ? context.pop() : context.go(AppRoutes.myDonations),
              );
            }
            return _Details(donation: donation);
          },
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.donation});

  final MyDonation donation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final campaign = donation.campaign;
    final campaignName = campaign?.titleFor(lang) ?? l10n.donationCampaignUnavailable;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        DonationReceiptCard(
          campaignTitle: campaignName,
          amount: donation.amount,
          currency: donation.currency,
          isAnonymous: donation.isAnonymous,
          date: donation.createdAt,
          statusLabel: donation.statusView.label(l10n),
          statusColor: donation.statusView.color,
          reference: donation.reference,
          message: donation.message,
        ),
        const SizedBox(height: 20),
        if (campaign != null)
          PrimaryButton(
            label: l10n.donationViewCampaign,
            icon: Icons.open_in_new,
            onPressed: () => context.push(AppRoutes.campaign(campaign.id)),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l10n.donationCampaignRemoved,
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
