import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/states/state_views.dart';
import 'widgets/campaign_update_tile.dart';

class CampaignUpdatesScreen extends ConsumerWidget {
  const CampaignUpdatesScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final updates = ref.watch(campaignUpdatesProvider(campaignId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.campaignUpdates)),
      body: updates.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          title: l10n.stateErrorTitle,
          message: presentError(err, l10n),
          onRetry: () => ref.invalidate(campaignUpdatesProvider(campaignId)),
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyView(
              title: l10n.updatesEmptyTitle,
              message: l10n.updatesEmpty,
              icon: Icons.campaign_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(campaignUpdatesProvider(campaignId)),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: list.length,
              separatorBuilder: (_, _) => const Divider(height: 32),
              itemBuilder: (context, i) => CampaignUpdateTile(update: list[i]),
            ),
          );
        },
      ),
    );
  }
}
