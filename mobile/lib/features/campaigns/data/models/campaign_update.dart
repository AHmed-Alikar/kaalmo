import 'package:flutter/foundation.dart';

/// One item from `GET /api/v1/campaigns/:id/updates`.
///
/// The backend stores only `text` (min 10) + optional `imageUrl` — there is
/// no separate title field, and `authorId` is not populated (updates are
/// always posted by a campaign contributor).
@immutable
class CampaignUpdate {
  const CampaignUpdate({
    required this.id,
    required this.text,
    this.imageUrl,
    this.createdAt,
  });

  final String id;
  final String text;
  final String? imageUrl;
  final DateTime? createdAt;

  factory CampaignUpdate.fromJson(
    Map<String, dynamic> json, {
    String Function(String url)? mediaUrlResolver,
  }) {
    final rawImage = json['imageUrl'];
    final image = rawImage is String && rawImage.trim().isNotEmpty ? rawImage.trim() : null;
    return CampaignUpdate(
      id: '${json['_id'] ?? json['id'] ?? ''}',
      text: '${json['text'] ?? ''}',
      imageUrl: image == null ? null : (mediaUrlResolver?.call(image) ?? image),
      createdAt: json['createdAt'] is String ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }
}
