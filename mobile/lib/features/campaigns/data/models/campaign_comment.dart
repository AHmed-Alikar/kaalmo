import 'package:flutter/foundation.dart';

/// One item from `GET /api/v1/campaigns/:id/comments`. The backend populates
/// `userId` with the author's `fullName`; older/unpopulated responses may
/// carry just the id string — both are handled.
@immutable
class CampaignComment {
  const CampaignComment({
    required this.id,
    required this.userId,
    required this.text,
    this.authorName,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String text;
  final String? authorName;
  final DateTime? createdAt;

  bool isMine(String? currentUserId) => currentUserId != null && currentUserId == userId;

  factory CampaignComment.fromJson(Map<String, dynamic> json) {
    final rawUser = json['userId'];
    String userId = '';
    String? authorName;
    if (rawUser is Map) {
      userId = '${rawUser['_id'] ?? rawUser['id'] ?? ''}';
      final n = rawUser['fullName'];
      if (n is String && n.trim().isNotEmpty) authorName = n;
    } else {
      userId = '${rawUser ?? ''}';
    }
    return CampaignComment(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      userId: userId,
      text: '${json['text'] ?? ''}',
      authorName: authorName,
      createdAt:
          json['createdAt'] is String ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}
