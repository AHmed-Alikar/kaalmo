import 'package:flutter/foundation.dart';

/// One item from `GET /api/v1/campaigns/:id/comments`.
///
/// The backend does not populate the author — only `userId` (an id string) is
/// available, so we can at most tell whether a comment belongs to the current
/// user.
@immutable
class CampaignComment {
  const CampaignComment({
    required this.id,
    required this.userId,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String text;
  final DateTime? createdAt;

  bool isMine(String? currentUserId) => currentUserId != null && currentUserId == userId;

  factory CampaignComment.fromJson(Map<String, dynamic> json) => CampaignComment(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        userId: '${json['userId'] ?? ''}',
        text: '${json['text'] ?? ''}',
        createdAt:
            json['createdAt'] is String ? DateTime.tryParse(json['createdAt'] as String) : null,
      );
}
