import 'package:flutter/foundation.dart';

/// A row from `GET /api/v1/campaigns/:id/members` (raw `CampaignMember`, not
/// populated — so only the invite email and status are available, never a name).
@immutable
class CampaignMemberInfo {
  const CampaignMemberInfo({
    required this.id,
    required this.inviteEmail,
    required this.status,
    this.acceptedAt,
  });

  final String id;
  final String inviteEmail;

  /// `'pending'` | `'accepted'`.
  final String status;
  final DateTime? acceptedAt;

  bool get isAccepted => status == 'accepted';

  factory CampaignMemberInfo.fromJson(Map<String, dynamic> json) => CampaignMemberInfo(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        inviteEmail: '${json['inviteEmail'] ?? ''}',
        status: '${json['status'] ?? 'pending'}',
        acceptedAt: DateTime.tryParse('${json['acceptedAt'] ?? ''}'),
      );
}
