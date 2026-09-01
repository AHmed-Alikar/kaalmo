import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaigns/data/models/campaign.dart';
import '../data/organizer_repository.dart';
import 'campaign_editor_state.dart' show kTitleMin, kTitleMax, kStoryMin;

/// Client mirror of `createCampaignSchema`
/// (server/src/validators/campaignValidators.js): `title.so` 5–150, `story.so`
/// ≥20, `category` enum, `goalAmount` > 0, optional `title.en` / `story.en` /
/// `region` / `endDate`. Cover-image upload is not available on mobile yet
/// (no image picker) — `coverImageUrl` is optional and simply omitted.
enum CreatePhase { editing, submitting, done, error }

@immutable
class CreateCampaignState {
  const CreateCampaignState({
    this.phase = CreatePhase.editing,
    this.titleSo = '',
    this.titleEn = '',
    this.storySo = '',
    this.storyEn = '',
    this.category = 'Medical',
    this.goalText = '',
    this.region,
    this.endDate,
    this.error,
    this.created,
  });

  final CreatePhase phase;
  final String titleSo;
  final String titleEn;
  final String storySo;
  final String storyEn;
  final String category;
  final String goalText;
  final String? region;
  final DateTime? endDate;
  final Object? error;
  final Campaign? created;

  double? get goalValue {
    final v = double.tryParse(goalText.trim());
    if (v == null || !v.isFinite || v <= 0) return null;
    return v;
  }

  String? get titleSoError {
    final t = titleSo.trim();
    if (t.isEmpty) return null; // don't shout before they type
    if (t.length < kTitleMin) return 'min';
    if (t.length > kTitleMax) return 'max';
    return null;
  }

  String? get titleEnError =>
      titleEn.trim().length > kTitleMax ? 'max' : null;

  String? get storySoError {
    final t = storySo.trim();
    if (t.isEmpty) return null;
    return t.length < kStoryMin ? 'min' : null;
  }

  String? get goalError {
    if (goalText.trim().isEmpty) return null;
    return goalValue == null ? 'invalid' : null;
  }

  bool get isValid =>
      titleSo.trim().length >= kTitleMin &&
      titleSo.trim().length <= kTitleMax &&
      titleEnError == null &&
      storySo.trim().length >= kStoryMin &&
      goalValue != null;

  bool get canSubmit => isValid && phase != CreatePhase.submitting;
  bool get isSubmitting => phase == CreatePhase.submitting;

  CreateCampaignState copyWith({
    CreatePhase? phase,
    String? titleSo,
    String? titleEn,
    String? storySo,
    String? storyEn,
    String? category,
    String? goalText,
    String? region,
    DateTime? endDate,
    Object? error,
    Campaign? created,
    bool clearError = false,
    bool clearRegion = false,
    bool clearEndDate = false,
  }) =>
      CreateCampaignState(
        phase: phase ?? this.phase,
        titleSo: titleSo ?? this.titleSo,
        titleEn: titleEn ?? this.titleEn,
        storySo: storySo ?? this.storySo,
        storyEn: storyEn ?? this.storyEn,
        category: category ?? this.category,
        goalText: goalText ?? this.goalText,
        region: clearRegion ? null : (region ?? this.region),
        endDate: clearEndDate ? null : (endDate ?? this.endDate),
        error: clearError ? null : (error ?? this.error),
        created: created ?? this.created,
      );
}

class CreateCampaignController extends StateNotifier<CreateCampaignState> {
  CreateCampaignController(this._repo) : super(const CreateCampaignState());

  final OrganizerRepository _repo;

  void setTitleSo(String v) => state = state.copyWith(titleSo: v, clearError: true);
  void setTitleEn(String v) => state = state.copyWith(titleEn: v, clearError: true);
  void setStorySo(String v) => state = state.copyWith(storySo: v, clearError: true);
  void setStoryEn(String v) => state = state.copyWith(storyEn: v, clearError: true);
  void setCategory(String v) => state = state.copyWith(category: v, clearError: true);
  void setGoal(String v) => state = state.copyWith(goalText: v, clearError: true);
  void setRegion(String? v) =>
      v == null ? state = state.copyWith(clearRegion: true) : state = state.copyWith(region: v);
  void setEndDate(DateTime? v) =>
      v == null ? state = state.copyWith(clearEndDate: true) : state = state.copyWith(endDate: v);

  Future<Campaign?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: CreatePhase.submitting, clearError: true);

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
      if (state.region != null && state.region!.isNotEmpty) 'region': state.region,
      if (state.endDate != null) 'endDate': state.endDate!.toUtc().toIso8601String(),
    };

    try {
      final campaign = await _repo.createCampaign(body);
      state = state.copyWith(phase: CreatePhase.done, created: campaign);
      return campaign;
    } catch (e) {
      state = state.copyWith(phase: CreatePhase.error, error: e);
      return null;
    }
  }

  void backToEditing() => state = state.copyWith(phase: CreatePhase.editing, clearError: true);
}
