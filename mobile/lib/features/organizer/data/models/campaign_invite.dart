import 'package:flutter/foundation.dart';

/// A pending co-organizer invitation from `GET /api/v1/campaign-invites/mine`
/// (`CampaignMember` populated with `campaignId.title` and `invitedBy.fullName`).
@immutable
class CampaignInvite {
  const CampaignInvite({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    this.inviterName,
    this.createdAt,
  });

  final String id;
  final String campaignId;
  final Map<String, String> campaignTitle;
  final String? inviterName;
  final DateTime? createdAt;

  String titleFor(String lang) {
    final preferred = campaignTitle[lang];
    if (preferred != null && preferred.trim().isNotEmpty) return preferred;
    for (final v in campaignTitle.values) {
      if (v.trim().isNotEmpty) return v;
    }
    return '';
  }

  static Map<String, String> _title(dynamic raw) {
    if (raw is Map) {
      return {
        for (final e in raw.entries)
          if (e.value != null) '${e.key}': '${e.value}',
      };
    }
    return const {};
  }

  factory CampaignInvite.fromJson(Map<String, dynamic> json) {
    final campaign = json['campaignId'];
    final inviter = json['invitedBy'];
    return CampaignInvite(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      campaignId: campaign is Map ? '${campaign['_id'] ?? ''}' : '${campaign ?? ''}',
      campaignTitle: campaign is Map ? _title(campaign['title']) : const {},
      inviterName: inviter is Map && '${inviter['fullName'] ?? ''}'.isNotEmpty
          ? '${inviter['fullName']}'
          : null,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}
