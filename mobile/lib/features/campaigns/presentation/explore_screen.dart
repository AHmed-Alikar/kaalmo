import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/inputs/search_field.dart';
import '../../../shared/states/state_views.dart';
import '../application/explore_state.dart';
import '../domain/campaign_categories.dart';
import 'widgets/campaign_card.dart';
import 'widgets/category_chips.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key, this.initialCategory, this.autofocusSearch = false});

  final String? initialCategory;
  final bool autofocusSearch;

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(exploreControllerProvider.notifier);
      if (widget.initialCategory != null && categoryByValue(widget.initialCategory) != null) {
        controller.setCategory(widget.initialCategory);
      } else {
        controller.init();
      }
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
      ref.read(exploreControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(exploreControllerProvider);
    final controller = ref.read(exploreControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.exploreTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchField(
              hintText: l10n.exploreSearchHint,
              autofocus: widget.autofocusSearch,
              initialValue: state.filters.query,
              onChanged: controller.search,
              onCleared: controller.clearSearch,
            ),
          ),
          CategoryChips(
            selected: state.filters.category,
            onSelected: controller.setCategory,
          ),
          _RegionBar(
            selected: state.filters.region,
            onSelected: controller.setRegion,
          ),
          const Divider(height: 1),
          Expanded(child: _ExploreBody(state: state, scrollController: _scroll)),
        ],
      ),
    );
  }
}

class _RegionBar extends StatelessWidget {
  const _RegionBar({required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: PopupMenuButton<String?>(
          initialValue: selected,
          onSelected: onSelected,
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem<String?>(value: null, child: Text(l10n.regionAll)),
            ...kCampaignRegions.map((r) => PopupMenuItem<String?>(value: r, child: Text(r))),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: scheme.outlineVariant),
              color: selected == null ? scheme.surface : scheme.primary.withValues(alpha: 0.08),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place_outlined, size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(selected ?? l10n.regionAll,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreBody extends ConsumerWidget {
  const _ExploreBody({required this.state, required this.scrollController});

  final ExploreState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(exploreControllerProvider.notifier);

    if (state.isFirstLoad || state.status == ExploreStatus.initial) {
      return const LoadingView();
    }

    if (state.isError) {
      return ErrorView(
        title: l10n.stateErrorTitle,
        message: presentError(state.error ?? l10n.errorUnexpected, l10n),
        onRetry: controller.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: state.isEmptyResult
          ? _EmptyScrollable(
              child: EmptyView(
                title: state.filters.isActive ? l10n.exploreNoResultsTitle : l10n.homeEmptyTitle,
                message: state.filters.isActive ? l10n.exploreNoResultsBody : l10n.homeEmptyBody,
                icon: Icons.search_off,
              ),
            )
          : ListView.separated(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: state.campaigns.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.campaigns.length) {
                  return _ListFooter(state: state);
                }
                return CampaignCard(campaign: state.campaigns[index]);
              },
            ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});
  final ExploreState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (!state.hasMore && state.campaigns.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            context.l10n.exploreEndOfList,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ),
      );
    }
    return const SizedBox(height: 8);
  }
}

class _EmptyScrollable extends StatelessWidget {
  const _EmptyScrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
}
