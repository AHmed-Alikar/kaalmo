import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/money_input.dart';
import '../../../shared/states/state_views.dart';
import '../../campaigns/data/models/campaign.dart';
import '../data/models/organizer_stats.dart';
import 'widgets/organizer_campaign_tile.dart';

/// `/organizer` — the organizer's home. Every number is a tally of the real
/// `/campaigns/mine` list; nothing is invented.
class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    if (user == null || !user.isOrganizer) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.organizerDashboardTitle)),
        body: SafeArea(
          child: EmptyView(
            icon: Icons.workspace_premium_outlined,
            title: l10n.organizerNotAvailableTitle,
            message: l10n.organizerNotAvailableBody,
          ),
        ),
      );
    }

    final campaigns = ref.watch(myCampaignsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizerDashboardTitle)),
      body: SafeArea(
        child: campaigns.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.organizerLoadErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(myCampaignsProvider),
          ),
          data: (list) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(myCampaignsProvider),
            child: _Body(campaigns: list),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = OrganizerStats.from(campaigns);
    final recent = campaigns.take(3).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Text(l10n.organizerDashboardHeadline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        _RaisedCard(amount: stats.totalRaised, currency: stats.currency),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            _StatCard(label: l10n.organizerStatTotal, value: '${stats.total}'),
            _StatCard(label: l10n.organizerStatLive, value: '${stats.live}'),
            _StatCard(label: l10n.organizerStatInReview, value: '${stats.inReview}'),
            _StatCard(label: l10n.organizerStatDrafts, value: '${stats.drafts}'),
            _StatCard(label: l10n.organizerStatCompleted, value: '${stats.completed}'),
            if (stats.rejected > 0)
              _StatCard(label: l10n.organizerStatRejected, value: '${stats.rejected}'),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(l10n.organizerRecentCampaigns,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.organizerCampaigns),
              child: Text(l10n.organizerViewAll),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (recent.isEmpty)
          _EmptyHint(text: l10n.organizerNoCampaignsYet)
        else
          for (final c in recent) ...[
            OrganizerCampaignTile(
              campaign: c,
              onTap: () => context.push(AppRoutes.organizerCampaign(c.id)),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _RaisedCard extends StatelessWidget {
  const _RaisedCard({required this.amount, required this.currency});

  final num amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.organizerTotalRaised,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            formatAmount(amount, currency),
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary),
          ),
          const SizedBox(height: 2),
          Text(l10n.organizerTotalRaisedNote,
              style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900, color: scheme.primary)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant), maxLines: 2),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
    );
  }
}
