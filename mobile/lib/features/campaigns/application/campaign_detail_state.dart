import 'package:flutter/foundation.dart';

import '../data/models/campaign.dart';
import '../data/models/campaign_interactions.dart';

enum CampaignDetailStatus { loading, ready, error }

@immutable
class CampaignDetailState {
  const CampaignDetailState({
    this.status = CampaignDetailStatus.loading,
    this.campaign,
    this.interactions = const CampaignInteractions(),
    this.error,
    this.followBusy = false,
    this.saveBusy = false,
    this.mutationError,
  });

  final CampaignDetailStatus status;
  final Campaign? campaign;
  final CampaignInteractions interactions;
  final Object? error;

  final bool followBusy;
  final bool saveBusy;

  /// Set for one build after a follow/save call fails, so the screen can show
  /// a snackbar. Never replaces the on-screen state.
  final Object? mutationError;

  bool get isLoading => status == CampaignDetailStatus.loading;
  bool get isError => status == CampaignDetailStatus.error;
  bool get isReady => status == CampaignDetailStatus.ready && campaign != null;

  CampaignDetailState copyWith({
    CampaignDetailStatus? status,
    Campaign? campaign,
    CampaignInteractions? interactions,
    Object? error,
    bool? followBusy,
    bool? saveBusy,
    Object? mutationError,
    bool clearMutationError = false,
  }) =>
      CampaignDetailState(
        status: status ?? this.status,
        campaign: campaign ?? this.campaign,
        interactions: interactions ?? this.interactions,
        error: error ?? this.error,
        followBusy: followBusy ?? this.followBusy,
        saveBusy: saveBusy ?? this.saveBusy,
        mutationError: clearMutationError ? null : (mutationError ?? this.mutationError),
      );
}
