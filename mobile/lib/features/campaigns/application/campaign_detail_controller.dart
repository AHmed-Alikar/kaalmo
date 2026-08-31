import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/campaign_repository.dart';
import '../data/models/campaign_interactions.dart';
import 'campaign_detail_state.dart';

/// Loads a single campaign and (for a signed-in user) the follow / save
/// relationship, then owns the follow / save mutations.
///
/// Mutations are **not** optimistic — the button shows a spinner, the call is
/// awaited, and the visible state only changes on success. A failure is
/// surfaced via [CampaignDetailState.mutationError] without disturbing the
/// current state.
class CampaignDetailController extends StateNotifier<CampaignDetailState> {
  CampaignDetailController(this._repository, this._campaignId, this._isAuthenticated)
      : super(const CampaignDetailState());

  final CampaignRepository _repository;
  final String _campaignId;
  final bool _isAuthenticated;

  Future<void> load() async {
    state = state.copyWith(status: CampaignDetailStatus.loading);
    try {
      final campaign = await _repository.getCampaign(_campaignId);
      var interactions = const CampaignInteractions();
      if (_isAuthenticated) {
        try {
          interactions = await _repository.getInteractions(_campaignId);
        } catch (_) {
          // Non-fatal — the campaign still renders; buttons default to "not
          // following / not saved".
        }
      }
      state = CampaignDetailState(
        status: CampaignDetailStatus.ready,
        campaign: campaign,
        interactions: interactions,
      );
    } catch (e) {
      state = CampaignDetailState(status: CampaignDetailStatus.error, error: e);
    }
  }

  Future<void> refresh() => load();

  Future<void> toggleFollow() async {
    if (!_isAuthenticated || state.followBusy) return;
    final target = !state.interactions.following;
    state = state.copyWith(followBusy: true, clearMutationError: true);
    try {
      final result = await _repository.setFollowing(_campaignId, target);
      state = state.copyWith(
        interactions: state.interactions.copyWith(following: result),
        followBusy: false,
      );
    } catch (e) {
      state = state.copyWith(followBusy: false, mutationError: e);
    }
  }

  Future<void> toggleSave() async {
    if (!_isAuthenticated || state.saveBusy) return;
    final target = !state.interactions.saved;
    state = state.copyWith(saveBusy: true, clearMutationError: true);
    try {
      final result = await _repository.setSaved(_campaignId, target);
      state = state.copyWith(
        interactions: state.interactions.copyWith(saved: result),
        saveBusy: false,
      );
    } catch (e) {
      state = state.copyWith(saveBusy: false, mutationError: e);
    }
  }

  void clearMutationError() {
    if (state.mutationError != null) state = state.copyWith(clearMutationError: true);
  }
}
