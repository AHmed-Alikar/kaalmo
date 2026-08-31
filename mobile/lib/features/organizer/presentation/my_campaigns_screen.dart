import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/states/state_views.dart';
import 'widgets/organizer_campaign_tile.dart';

/// `/organizer/campaigns` — the full list of the organizer's campaigns.
class MyCampaignsScreen extends ConsumerWidget {
  const MyCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final campaigns = ref.watch(myCampaignsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizerMyCampaignsTitle)),
      body: SafeArea(
        child: campaigns.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.organizerLoadErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(myCampaignsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return _EmptyScrollable(
                onRefresh: () async => ref.invalidate(myCampaignsProvider),
                child: EmptyView(
                  icon: Icons.campaign_outlined,
                  title: l10n.organizerNoCampaignsTitle,
                  message: l10n.organizerNoCampaignsBody,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myCampaignsProvider),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => OrganizerCampaignTile(
                  campaign: list[i],
                  onTap: () => context.push(AppRoutes.organizerCampaign(list[i].id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyScrollable extends StatelessWidget {
  const _EmptyScrollable({required this.child, required this.onRefresh});

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ),
        ),
      );
}
