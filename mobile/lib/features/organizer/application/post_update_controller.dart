import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../campaigns/data/models/campaign_update.dart';
import '../data/organizer_repository.dart';

/// Backend rule: `text` min 10 chars (`createUpdateSchema`).
const kUpdateMinLength = 10;

enum PostUpdatePhase { editing, posting, posted, error }

@immutable
class PostUpdateState {
  const PostUpdateState({this.text = '', this.phase = PostUpdatePhase.editing, this.error});

  final String text;
  final PostUpdatePhase phase;
  final Object? error;

  bool get tooShort => text.trim().length < kUpdateMinLength;
  bool get canSubmit => !tooShort && phase != PostUpdatePhase.posting;
  bool get isPosting => phase == PostUpdatePhase.posting;

  PostUpdateState copyWith({String? text, PostUpdatePhase? phase, Object? error, bool clearError = false}) =>
      PostUpdateState(
        text: text ?? this.text,
        phase: phase ?? this.phase,
        error: clearError ? null : (error ?? this.error),
      );
}

class PostUpdateController extends StateNotifier<PostUpdateState> {
  PostUpdateController(this._repo, this._campaignId) : super(const PostUpdateState());

  final OrganizerRepository _repo;
  final String _campaignId;

  void setText(String v) => state = state.copyWith(text: v, clearError: true);

  /// Returns the created update on success, or null on failure.
  Future<CampaignUpdate?> submit() async {
    if (!state.canSubmit) return null;
    state = state.copyWith(phase: PostUpdatePhase.posting, clearError: true);
    try {
      final created = await _repo.postUpdate(_campaignId, text: state.text.trim());
      state = state.copyWith(phase: PostUpdatePhase.posted);
      return created;
    } catch (e) {
      state = state.copyWith(phase: PostUpdatePhase.error, error: e);
      return null;
    }
  }
}
