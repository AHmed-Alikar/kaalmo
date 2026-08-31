import 'package:flutter/foundation.dart';

/// `GET /api/v1/campaigns/:id/interactions` — the current user's relationship
/// with a campaign. Only meaningful for an authenticated user.
@immutable
class CampaignInteractions {
  const CampaignInteractions({this.following = false, this.saved = false});

  final bool following;
  final bool saved;

  CampaignInteractions copyWith({bool? following, bool? saved}) =>
      CampaignInteractions(following: following ?? this.following, saved: saved ?? this.saved);

  factory CampaignInteractions.fromJson(Map<String, dynamic> json) => CampaignInteractions(
        following: json['following'] == true,
        saved: json['saved'] == true,
      );
}
