import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/auth/login_required_sheet.dart';
import '../../../shared/states/state_views.dart';
import '../application/campaign_detail_state.dart';
import '../data/models/campaign.dart';
import '../data/models/campaign_update.dart';
import '../data/models/supporter.dart';
import '../domain/campaign_status.dart';
import 'widgets/campaign_action_bar.dart';
import 'widgets/campaign_hero.dart';
import 'widgets/campaign_status_banner.dart';
import 'widgets/campaign_story_view.dart';
import 'widgets/campaign_summary.dart';
import 'widgets/campaign_trust_row.dart';
import 'widgets/campaign_update_tile.dart';
import 'widgets/report_sheet.dart';
import 'widgets/supporter_tile.dart';

class CampaignDetailsScreen extends ConsumerWidget {
  const CampaignDetailsScreen({super.key, required this.campaignId});

  final String campaignId;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _guarded(
    BuildContext context,
    WidgetRef ref, {
    required String actionLabel,
    required Future<void> Function() run,
  }) async {
    final authed = ref.read(authControllerProvider).isAuthenticated;
    if (!authed) {
      await showLoginRequiredSheet(context,
          actionLabel: actionLabel, returnTo: AppRoutes.campaign(campaignId));
      return;
    }
    await run();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(campaignDetailControllerProvider(campaignId));
    final controller = ref.read(campaignDetailControllerProvider(campaignId).notifier);

    ref.listen(campaignDetailControllerProvider(campaignId).select((s) => s.mutationError), (_, err) {
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(presentError(err, l10n))),
        );
        controller.clearMutationError();
      }
    });

    return Scaffold(
      body: switch (state.status) {
        CampaignDetailStatus.loading => _Chrome(onBack: () => _back(context), child: const LoadingView()),
        CampaignDetailStatus.error => _Chrome(
            onBack: () => _back(context),
            child: ErrorView(
              title: l10n.campaignLoadErrorTitle,
              message: presentError(state.error ?? l10n.errorUnexpected, l10n),
              onRetry: controller.refresh,
            ),
          ),
        CampaignDetailStatus.ready => _Content(
            campaignId: campaignId,
            campaign: state.campaign!,
            state: state,
            onBack: () => _back(context),
            onShare: () => _share(context, ref, state.campaign!),
            onReport: () => _guarded(context, ref,
                actionLabel: l10n.reportAction, run: () async => showReportSheet(context, campaignId: campaignId)),
            onFollow: () => _guarded(context, ref, actionLabel: l10n.follow, run: controller.toggleFollow),
            onSave: () => _guarded(context, ref, actionLabel: l10n.save, run: controller.toggleSave),
          ),
      },
      bottomNavigationBar: state.isReady
          ? CampaignActionBar(
              status: CampaignStatusView.from(state.campaign!.status),
              following: state.interactions.following,
              saved: state.interactions.saved,
              followBusy: state.followBusy,
              saveBusy: state.saveBusy,
              onFollow: () =>
                  _guarded(context, ref, actionLabel: l10n.follow, run: controller.toggleFollow),
              onSave: () => _guarded(context, ref, actionLabel: l10n.save, run: controller.toggleSave),
              onShare: () => _share(context, ref, state.campaign!),
              onDonateTap: () => _openDonate(context),
            )
          : null,
    );
  }

  void _openDonate(BuildContext context) {
    // Auth is enforced inside the donate flow (it needs the donor identity for
    // the receipt), with the same login-return behaviour as other actions.
    context.push('${AppRoutes.campaign(campaignId)}/donate');
  }

  Future<void> _share(BuildContext context, WidgetRef ref, Campaign campaign) {
    final lang = Localizations.localeOf(context).languageCode;
    final config = ref.read(appConfigProvider);
    final story = campaign.storyFor(lang);
    final excerpt = story.length > 160 ? '${story.substring(0, 160).trim()}…' : story;
    return ref.read(shareServiceProvider).shareCampaign(
          title: campaign.titleFor(lang),
          excerpt: excerpt,
          url: '${config.webBaseUrl}/campaigns/${campaign.id}',
        );
  }
}

/// App bar chrome shared by the loading / error states.
class _Chrome extends StatelessWidget {
  const _Chrome({required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({
    required this.campaignId,
    required this.campaign,
    required this.state,
    required this.onBack,
    required this.onShare,
    required this.onReport,
    required this.onFollow,
    required this.onSave,
  });

  final String campaignId;
  final Campaign campaign;
  final CampaignDetailState state;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onReport;
  final VoidCallback onFollow;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final status = CampaignStatusView.from(campaign.status);
    final updates = ref.watch(campaignUpdatesProvider(campaignId));
    final supporters = ref.watch(campaignSupportersProvider(campaignId));
    final supporterCount = supporters.asData?.value.supporterCount;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(campaignDetailControllerProvider(campaignId).notifier).refresh();
        ref.invalidate(campaignUpdatesProvider(campaignId));
        ref.invalidate(campaignSupportersProvider(campaignId));
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back)),
            actions: [
              IconButton(onPressed: onShare, icon: const Icon(Icons.ios_share), tooltip: l10n.share),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'report') onReport();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'report', child: Text(l10n.reportAction)),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(child: CampaignHero(campaign: campaign)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            sliver: SliverList.list(
              children: [
                CampaignSummary(campaign: campaign, supporterCount: supporterCount),
                if (status.needsBanner) ...[
                  const SizedBox(height: 18),
                  CampaignStatusBanner(status: status),
                ],
                const SizedBox(height: 22),
                CampaignTrustRow(rawBadges: campaign.verificationBadges),
                if (campaign.verificationBadges.isNotEmpty) const SizedBox(height: 22),
                CampaignStoryView(story: campaign.storyFor(lang)),
                const SizedBox(height: 24),
                _UpdatesPreview(campaignId: campaignId, updates: updates),
                const SizedBox(height: 24),
                _SupportersPreview(campaignId: campaignId, supporters: supporters),
                const SizedBox(height: 16),
                _NavRow(
                  icon: Icons.forum_outlined,
                  label: l10n.comments,
                  onTap: () => context.push('${AppRoutes.campaign(campaignId)}/comments'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      );
}

class _UpdatesPreview extends StatelessWidget {
  const _UpdatesPreview({required this.campaignId, required this.updates});

  final String campaignId;
  final AsyncValue<List<CampaignUpdate>> updates;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.campaignUpdates),
        const SizedBox(height: 10),
        updates.when(
          loading: () => const _InlineLoading(),
          error: (_, _) => _InlineNote(l10n.updatesLoadError),
          data: (list) {
            if (list.isEmpty) return _InlineNote(l10n.updatesEmpty);
            final preview = list.take(2).toList();
            return Column(
              children: [
                for (final u in preview) ...[
                  CampaignUpdateTile(update: u),
                  if (u != preview.last) const Divider(height: 24),
                ],
                if (list.length > preview.length) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => context.push('${AppRoutes.campaign(campaignId)}/updates'),
                      child: Text(l10n.seeAllUpdates(list.length)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SupportersPreview extends StatelessWidget {
  const _SupportersPreview({required this.campaignId, required this.supporters});

  final String campaignId;
  final AsyncValue<SupporterList> supporters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.supporters),
        const SizedBox(height: 10),
        supporters.when(
          loading: () => const _InlineLoading(),
          error: (_, _) => _InlineNote(l10n.supportersLoadError),
          data: (data) {
            if (data.supporterCount == 0) return _InlineNote(l10n.supportersEmpty);
            final preview = data.items.take(3).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in preview) ...[
                  SupporterTile(supporter: s),
                  if (s != preview.last) const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('${AppRoutes.campaign(campaignId)}/supporters'),
                    child: Text(l10n.seeAllSupporters(data.supporterCount)),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))),
      );
}

class _InlineNote extends StatelessWidget {
  const _InlineNote(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}
