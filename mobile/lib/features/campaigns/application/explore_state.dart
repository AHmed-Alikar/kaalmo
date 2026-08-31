import 'package:flutter/foundation.dart';

import '../data/models/campaign.dart';

enum ExploreStatus { initial, loading, ready, loadingMore, error }

@immutable
class ExploreFilters {
  const ExploreFilters({this.query = '', this.category, this.region});

  final String query;
  final String? category;
  final String? region;

  bool get isActive => query.isNotEmpty || category != null || region != null;

  ExploreFilters copyWith({String? query, String? Function()? category, String? Function()? region}) =>
      ExploreFilters(
        query: query ?? this.query,
        category: category != null ? category() : this.category,
        region: region != null ? region() : this.region,
      );
}

@immutable
class ExploreState {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.filters = const ExploreFilters(),
    this.campaigns = const [],
    this.total = 0,
    this.page = 0,
    this.error,
  });

  final ExploreStatus status;
  final ExploreFilters filters;
  final List<Campaign> campaigns;
  final int total;
  final int page;
  final Object? error;

  bool get hasMore => campaigns.length < total;
  bool get isFirstLoad => status == ExploreStatus.loading;
  bool get isLoadingMore => status == ExploreStatus.loadingMore;
  bool get isError => status == ExploreStatus.error;
  bool get isEmptyResult => status == ExploreStatus.ready && campaigns.isEmpty;

  ExploreState copyWith({
    ExploreStatus? status,
    ExploreFilters? filters,
    List<Campaign>? campaigns,
    int? total,
    int? page,
    Object? error,
    bool clearError = false,
  }) =>
      ExploreState(
        status: status ?? this.status,
        filters: filters ?? this.filters,
        campaigns: campaigns ?? this.campaigns,
        total: total ?? this.total,
        page: page ?? this.page,
        error: clearError ? null : (error ?? this.error),
      );
}
