import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/states/state_views.dart';
import 'widgets/supporter_tile.dart';

/// The backend exposes only a *recent* confirmed-donation list (no offset
/// pagination) plus a total count — so this screen shows exactly that, with
/// the count made prominent and anonymous donors preserved.
class CampaignSupportersScreen extends ConsumerWidget {
  const CampaignSupportersScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final supporters = ref.watch(campaignSupportersProvider(campaignId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supporters)),
      body: supporters.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          title: l10n.stateErrorTitle,
          message: presentError(err, l10n),
          onRetry: () => ref.invalidate(campaignSupportersProvider(campaignId)),
        ),
        data: (data) {
          if (data.supporterCount == 0) {
            return EmptyView(
              title: l10n.supportersEmptyTitle,
              message: l10n.supportersEmpty,
              icon: Icons.favorite_outline,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(campaignSupportersProvider(campaignId)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(l10n.supportersCountHeadline(data.supporterCount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                if (data.items.length < data.supporterCount) ...[
                  const SizedBox(height: 4),
                  Text(l10n.supportersRecentOnly,
                      style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
                const SizedBox(height: 16),
                for (var i = 0; i < data.items.length; i++) ...[
                  SupporterTile(supporter: data.items[i]),
                  if (i != data.items.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
