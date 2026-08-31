import 'package:flutter/foundation.dart';

import '../../campaigns/data/models/campaign.dart';

/// Client-side mirrors of the backend validators
/// (server/src/validators/campaignValidators.js).
const kTitleMin = 5;
const kTitleMax = 150;
const kStoryMin = 20;

enum EditorPhase { editing, saving, saved, error }

@immutable
class CampaignEditorState {
  const CampaignEditorState({
    this.phase = EditorPhase.editing,
    this.titleSo = '',
    this.titleEn = '',
    this.storySo = '',
    this.storyEn = '',
    this.category = 'Other',
    this.goalText = '',
    this.region,
    this.error,
    this.fieldErrors = const {},
  });

  final EditorPhase phase;
  final String titleSo;
  final String titleEn;
  final String storySo;
  final String storyEn;
  final String category;
  final String goalText;
  final String? region;
  final Object? error;
  final Map<String, String> fieldErrors;

  factory CampaignEditorState.fromCampaign(Campaign c) => CampaignEditorState(
        titleSo: c.title['so'] ?? '',
        titleEn: c.title['en'] ?? '',
        storySo: c.story['so'] ?? '',
        storyEn: c.story['en'] ?? '',
        category: c.category.isEmpty ? 'Other' : c.category,
        goalText: c.goalAmount > 0 ? _trimAmount(c.goalAmount) : '',
        region: c.region,
      );

  static String _trimAmount(num v) {
    final r = v.toDouble();
    return r == r.roundToDouble() ? r.round().toString() : r.toString();
  }

  double? get goalValue {
    final v = double.tryParse(goalText.trim());
    if (v == null || !v.isFinite || v <= 0) return null;
    return v;
  }

  String? get titleSoError {
    final t = titleSo.trim();
    if (t.length < kTitleMin) return 'min';
    if (t.length > kTitleMax) return 'max';
    return null;
  }

  String? get storySoError => storySo.trim().length < kStoryMin ? 'min' : null;

  String? get goalError => goalValue == null ? 'invalid' : null;

  bool get isValid => titleSoError == null && storySoError == null && goalError == null;

  bool get isSaving => phase == EditorPhase.saving;

  CampaignEditorState copyWith({
    EditorPhase? phase,
    String? titleSo,
    String? titleEn,
    String? storySo,
    String? storyEn,
    String? category,
    String? goalText,
    String? region,
    Object? error,
    Map<String, String>? fieldErrors,
    bool clearError = false,
    bool clearRegion = false,
  }) =>
      CampaignEditorState(
        phase: phase ?? this.phase,
        titleSo: titleSo ?? this.titleSo,
        titleEn: titleEn ?? this.titleEn,
        storySo: storySo ?? this.storySo,
        storyEn: storyEn ?? this.storyEn,
        category: category ?? this.category,
        goalText: goalText ?? this.goalText,
        region: clearRegion ? null : (region ?? this.region),
        error: clearError ? null : (error ?? this.error),
        fieldErrors: fieldErrors ?? this.fieldErrors,
      );
}
