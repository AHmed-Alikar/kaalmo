import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/states/state_views.dart';
import '../../campaigns/presentation/widgets/campaign_card.dart';
import '../../campaigns/presentation/widgets/category_chips.dart';
import '../../notifications/presentation/widgets/notification_bell.dart';
import '../application/home_feed.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/stats_strip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final feed = ref.watch(homeFeedProvider);
    final firstName = _firstName(ref.watch(authControllerProvider).user?.fullName);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(homeFeedProvider.future),
          child: feed.when(
            loading: () => const _HomeScrollable(child: LoadingView()),
            error: (err, _) => _HomeScrollable(
              child: ErrorView(
                title: l10n.stateErrorTitle,
                message: presentError(err, l10n),
                onRetry: () => ref.invalidate(homeFeedProvider),
              ),
            ),
            data: (data) => _HomeBody(data: data, greetingName: firstName),
          ),
        ),
      ),
    );
  }

  static String? _firstName(String? full) {
    if (full == null || full.trim().isEmpty) return null;
    return full.trim().split(RegExp(r'\s+')).first;
  }
}

/// Keeps loading/error states scrollable so RefreshIndicator still works.
class _HomeScrollable extends StatelessWidget {
  const _HomeScrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(padding: const EdgeInsets.only(top: 80), child: child),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.data, this.greetingName});

  final HomeFeed data;
  final String? greetingName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.appName,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                    ),
                    const NotificationBell(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  greetingName == null ? l10n.homeGreetingGeneric : l10n.homeGreeting(greetingName!),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(l10n.homeGreetingSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )),
                const SizedBox(height: 14),
                const HomeSearchBar(),
              ],
            ),
          ),
        ),

        if (data.stats != null)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            sliver: SliverToBoxAdapter(child: StatsStrip(stats: data.stats!)),
          ),

        if (data.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(title: l10n.homeEmptyTitle, message: l10n.homeEmptyBody),
          )
        else ...[
          // Featured — horizontal carousel.
          SliverToBoxAdapter(
            child: SectionHeader(title: l10n.homeFeatured),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: data.featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) => SizedBox(
                  width: 240,
                  child: CampaignCard(campaign: data.featured[i], compact: true),
                ),
              ),
            ),
          ),

          // Categories.
          SliverToBoxAdapter(child: SectionHeader(title: l10n.homeCategories)),
          SliverToBoxAdapter(
            child: CategoryChips(
              selected: null,
              onSelected: (value) => context.go(
                value == null ? AppRoutes.explore : '${AppRoutes.explore}?category=${Uri.encodeQueryComponent(value)}',
              ),
            ),
          ),

          // Recent.
          SliverToBoxAdapter(
            child: SectionHeader(
              title: l10n.homeRecent,
              actionLabel: l10n.homeViewAll,
              onAction: () => context.go(AppRoutes.explore),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.separated(
              itemCount: data.recent.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => CampaignCard(campaign: data.recent[i]),
            ),
          ),
        ],
      ],
    );
  }
}
