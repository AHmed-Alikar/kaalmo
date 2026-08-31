import 'package:flutter/foundation.dart';

/// One row of `GET /api/v1/notifications/mine` (`{ items, unreadCount }`).
/// The backend `Notification` model: `{ _id, type, title, body?, targetUrl?,
/// read, createdAt, updatedAt }`. `type` is a free string — see
/// [NotificationKind] for the presentation mapping.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.read,
    this.body,
    this.targetUrl,
    this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final bool read;
  final String? body;
  final String? targetUrl;
  final DateTime? createdAt;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        read: read ?? this.read,
        body: body,
        targetUrl: targetUrl,
        createdAt: createdAt,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: '${json['_id'] ?? json['id'] ?? ''}',
        type: '${json['type'] ?? ''}',
        title: '${json['title'] ?? ''}',
        read: json['read'] == true,
        body: (json['body'] as String?)?.trim().isNotEmpty == true ? json['body'] as String : null,
        targetUrl: (json['targetUrl'] as String?)?.trim().isNotEmpty == true
            ? json['targetUrl'] as String
            : null,
        createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      );
}

/// The full `/notifications/mine` response — a capped list (backend `.limit(50)`,
/// no pagination) plus the authoritative unread count.
@immutable
class NotificationFeed {
  const NotificationFeed({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;

  static const empty = NotificationFeed(items: [], unreadCount: 0);

  factory NotificationFeed.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => AppNotification.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <AppNotification>[];
    final count = json['unreadCount'];
    return NotificationFeed(
      items: items,
      unreadCount: count is int ? count : int.tryParse('$count') ?? 0,
    );
  }
}
