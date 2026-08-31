import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/organizer_repository.dart';

@immutable
class CampaignManageState {
  const CampaignManageState({this.busy = false, this.error});

  final bool busy;
  final Object? error;

  CampaignManageState copyWith({bool? busy, Object? error, bool clearError = false}) =>
      CampaignManageState(busy: busy ?? this.busy, error: clearError ? null : (error ?? this.error));
}

/// Owner lifecycle actions for one campaign: submit for review, cancel, delete.
/// Each call is single-flight; a failure is surfaced via [CampaignManageState.error]
/// without changing anything locally — the caller refreshes from the backend on
/// success (never fakes the new status).
class CampaignManageController extends StateNotifier<CampaignManageState> {
  CampaignManageController(this._repo, this._campaignId) : super(const CampaignManageState());

  final OrganizerRepository _repo;
  final String _campaignId;

  Future<bool> _run(Future<void> Function() action) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, clearError: true);
    try {
      await action();
      state = state.copyWith(busy: false);
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e);
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<bool> submit() => _run(() => _repo.submitCampaign(_campaignId));

  Future<bool> cancel() => _run(() => _repo.cancelCampaign(_campaignId));

  Future<bool> deleteDraft() => _run(() => _repo.deleteCampaign(_campaignId));
}
