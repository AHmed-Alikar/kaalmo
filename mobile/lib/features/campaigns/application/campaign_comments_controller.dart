import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/campaign_repository.dart';
import '../data/models/campaign_comment.dart';

enum CommentsStatus { loading, ready, error }

class CommentsState {
  const CommentsState({
    this.status = CommentsStatus.loading,
    this.comments = const [],
    this.error,
    this.submitting = false,
  });

  final CommentsStatus status;
  final List<CampaignComment> comments;
  final Object? error;
  final bool submitting;

  bool get isEmpty => status == CommentsStatus.ready && comments.isEmpty;

  CommentsState copyWith({
    CommentsStatus? status,
    List<CampaignComment>? comments,
    Object? error,
    bool? submitting,
  }) =>
      CommentsState(
        status: status ?? this.status,
        comments: comments ?? this.comments,
        error: error ?? this.error,
        submitting: submitting ?? this.submitting,
      );
}

/// Backend comment rules (mirrored, never contradicted): `text` 1–1000 chars.
const kCommentMaxLength = 1000;

/// The comments endpoint is not paginated — it returns every comment
/// newest-first, so we load once and prepend on submit.
class CampaignCommentsController extends StateNotifier<CommentsState> {
  CampaignCommentsController(this._repository, this._campaignId) : super(const CommentsState());

  final CampaignRepository _repository;
  final String _campaignId;

  Future<void> load() async {
    state = state.copyWith(status: CommentsStatus.loading);
    try {
      final comments = await _repository.getComments(_campaignId);
      state = CommentsState(status: CommentsStatus.ready, comments: comments);
    } catch (e) {
      state = CommentsState(status: CommentsStatus.error, error: e);
    }
  }

  Future<void> refresh() => load();

  /// Returns null on success, or an error to present. Guards against empty /
  /// over-long / double submission.
  Future<Object?> submit(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || text.length > kCommentMaxLength || state.submitting) return null;

    state = state.copyWith(submitting: true);
    try {
      final created = await _repository.postComment(_campaignId, text);
      state = state.copyWith(
        submitting: false,
        status: CommentsStatus.ready,
        comments: [created, ...state.comments],
      );
      return null;
    } catch (e) {
      state = state.copyWith(submitting: false);
      return e;
    }
  }
}
