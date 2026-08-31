import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../campaigns/data/models/campaign.dart';
import '../data/organizer_repository.dart';
import 'campaign_editor_state.dart';

/// Owns the campaign edit form. Sends only a partial body of the fields the
/// backend `updateCampaignSchema` accepts. On success the caller refreshes the
/// campaign (editing a reviewed campaign moves it back to `under_review` —
/// that is surfaced before saving, never hidden).
class CampaignEditorController extends StateNotifier<CampaignEditorState> {
  CampaignEditorController(this._repo, this._campaignId) : super(const CampaignEditorState());

  final OrganizerRepository _repo;
  final String _campaignId;

  bool _hydrated = false;

  /// Fill the form from the loaded campaign, once. Safe to call on every build.
  void hydrate(Campaign c) {
    if (_hydrated) return;
    _hydrated = true;
    state = CampaignEditorState.fromCampaign(c);
  }

  void setTitleSo(String v) => state = state.copyWith(titleSo: v, clearError: true);
  void setTitleEn(String v) => state = state.copyWith(titleEn: v, clearError: true);
  void setStorySo(String v) => state = state.copyWith(storySo: v, clearError: true);
  void setStoryEn(String v) => state = state.copyWith(storyEn: v, clearError: true);
  void setCategory(String v) => state = state.copyWith(category: v, clearError: true);
  void setGoal(String v) => state = state.copyWith(goalText: v, clearError: true);
  void setRegion(String? v) =>
      state = v == null ? state.copyWith(clearRegion: true) : state.copyWith(region: v);

  /// Returns the updated [Campaign] on success, or null on failure (the error
  /// is on the state).
  Future<Campaign?> save() async {
    if (!state.isValid || state.isSaving) return null;

    state = state.copyWith(phase: EditorPhase.saving, clearError: true, fieldErrors: const {});
    try {
      final body = <String, dynamic>{
        'title': {
          'so': state.titleSo.trim(),
          if (state.titleEn.trim().isNotEmpty) 'en': state.titleEn.trim(),
        },
        'story': {
          'so': state.storySo.trim(),
          if (state.storyEn.trim().isNotEmpty) 'en': state.storyEn.trim(),
        },
        'category': state.category,
        'goalAmount': state.goalValue,
        if ((state.region ?? '').isNotEmpty) 'region': state.region,
      };
      final updated = await _repo.updateCampaign(_campaignId, body);
      state = state.copyWith(phase: EditorPhase.saved);
      return updated;
    } catch (e) {
      state = state.copyWith(
        phase: EditorPhase.error,
        error: e,
        fieldErrors: e is ApiException ? e.fieldErrors : const {},
      );
      return null;
    }
  }
}
