import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/campaign_repository.dart';
import '../data/models/campaign.dart';
import 'explore_state.dart';

const _pageSize = 20;
const _searchDebounce = Duration(milliseconds: 400);

/// Owns the Explore screen's paged, filtered, searchable campaign list.
///
/// - Search input is debounced; a superseded request is cancelled and its
///   result ignored (a monotonically increasing token guards against races).
/// - Filters (category / region) reload from page 1.
/// - [loadMore] appends the next page while [ExploreState.hasMore].
class ExploreController extends StateNotifier<ExploreState> {
  ExploreController(this._repository) : super(const ExploreState());

  final CampaignRepository _repository;

  Timer? _debounce;
  CancelToken? _inFlight;
  int _requestToken = 0;

  Future<void> init() {
    if (state.status != ExploreStatus.initial) return Future.value();
    return _reload();
  }

  void search(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      if (value.trim() == state.filters.query) return;
      state = state.copyWith(filters: state.filters.copyWith(query: value.trim()));
      _reload();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    if (state.filters.query.isEmpty) return;
    state = state.copyWith(filters: state.filters.copyWith(query: ''));
    _reload();
  }

  void setCategory(String? category) {
    if (category == state.filters.category) return;
    state = state.copyWith(filters: state.filters.copyWith(category: () => category));
    _reload();
  }

  void setRegion(String? region) {
    if (region == state.filters.region) return;
    state = state.copyWith(filters: state.filters.copyWith(region: () => region));
    _reload();
  }

  Future<void> refresh() => _reload(isRefresh: true);

  Future<void> loadMore() async {
    if (state.status == ExploreStatus.loadingMore || state.isFirstLoad || !state.hasMore) return;
    final token = ++_requestToken;
    state = state.copyWith(status: ExploreStatus.loadingMore, clearError: true);
    try {
      final next = await _fetch(page: state.page + 1);
      if (token != _requestToken) return;
      state = state.copyWith(
        status: ExploreStatus.ready,
        campaigns: [...state.campaigns, ...next.items],
        total: next.total,
        page: next.page,
      );
    } catch (e) {
      if (token != _requestToken) return;
      // Keep what we have; surface the error non-destructively.
      state = state.copyWith(status: ExploreStatus.ready, error: e);
    }
  }

  Future<void> _reload({bool isRefresh = false}) async {
    final token = ++_requestToken;
    _inFlight?.cancel('superseded');
    _inFlight = CancelToken();

    if (!isRefresh) {
      state = state.copyWith(status: ExploreStatus.loading, clearError: true);
    }

    try {
      final first = await _fetch(page: 1, cancelToken: _inFlight);
      if (token != _requestToken) return;
      state = state.copyWith(
        status: ExploreStatus.ready,
        campaigns: first.items,
        total: first.total,
        page: first.page,
        clearError: true,
      );
    } on DioException catch (e) {
      if (token != _requestToken || CancelToken.isCancel(e)) return;
      state = state.copyWith(status: ExploreStatus.error, error: e);
    } catch (e) {
      if (token != _requestToken) return;
      state = state.copyWith(status: ExploreStatus.error, error: e);
    }
  }

  Future<_Page> _fetch({required int page, CancelToken? cancelToken}) async {
    final f = state.filters;
    final result = await _repository.list(
      query: f.query.isEmpty ? null : f.query,
      category: f.category,
      region: f.region,
      page: page,
      limit: _pageSize,
      cancelToken: cancelToken,
    );
    return _Page(result.items, result.total, result.page);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _inFlight?.cancel('disposed');
    super.dispose();
  }
}

class _Page {
  const _Page(this.items, this.total, this.page);
  final List<Campaign> items;
  final int total;
  final int page;
}
