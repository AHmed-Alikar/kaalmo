import '../../campaigns/data/models/campaign.dart';

/// Which management actions are valid for a campaign, mirroring the backend
/// exactly (server/src/services/campaignService.js). The UI only ever offers
/// an action this permits — the backend still enforces it independently.
class CampaignActionSet {
  const CampaignActionSet({
    required this.canEdit,
    required this.canSubmit,
    required this.canCancel,
    required this.canDelete,
    required this.canPostUpdate,
    required this.canViewPublic,
    required this.editReturnsToReview,
  });

  final bool canEdit;
  final bool canSubmit;
  final bool canCancel;
  final bool canDelete;
  final bool canPostUpdate;
  final bool canViewPublic;

  /// True when saving an edit will send the campaign back to `under_review`
  /// (`EDIT_RETURNS_TO_REVIEW_STATUSES`).
  final bool editReturnsToReview;

  bool get hasAnyOwnerAction => canSubmit || canCancel || canDelete;

  /// Backend `NOT_EDITABLE_STATUSES`.
  static const _notEditable = {'suspended', 'frozen', 'cancelled', 'expired', 'completed'};

  /// Backend `EDIT_RETURNS_TO_REVIEW_STATUSES`.
  static const _editReturnsToReview = {
    'submitted', 'under_review', 'approved', 'published', 'active', 'goal_reached', 'withdrawal',
  };

  /// Backend `PUBLIC_STATUSES`.
  static const _public = {'published', 'active', 'goal_reached', 'withdrawal', 'completed'};

  factory CampaignActionSet.forCampaign(Campaign c, {required bool isOwner}) {
    final s = c.status;
    return CampaignActionSet(
      // Co-organizers can edit content; owner-only actions stay owner-only.
      canEdit: !_notEditable.contains(s),
      canSubmit: isOwner && s == 'draft',
      canCancel: isOwner && (s == 'draft' || s == 'submitted'),
      canDelete: isOwner && s == 'draft',
      // The controller only checks contributor status — anyone who reached the
      // manage screen for their own / co-organized campaign qualifies.
      canPostUpdate: true,
      canViewPublic: _public.contains(s),
      editReturnsToReview: _editReturnsToReview.contains(s),
    );
  }
}
