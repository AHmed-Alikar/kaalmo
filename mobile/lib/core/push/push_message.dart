import 'package:flutter/foundation.dart';

import '../../features/notifications/domain/notification_target.dart';

/// A push message reduced to just what the app acts on. Built from an FCM
/// `RemoteMessage` (see [FcmPushService]) or, in tests, directly.
///
/// The backend puts navigation metadata in the **data** map — `type`,
/// `targetUrl` and (when available) `notificationId` — never in the visible
/// text. Navigation is derived from those structured fields, not by parsing the
/// title/body.
@immutable
class PushMessage {
  const PushMessage({required this.data, this.title, this.body});

  final Map<String, String> data;
  final String? title;
  final String? body;

  String? get type {
    final t = data['type'];
    return (t != null && t.isNotEmpty) ? t : null;
  }

  String? get targetUrl {
    final u = data['targetUrl'];
    return (u != null && u.isNotEmpty) ? u : null;
  }

  /// The backend `Notification._id` this push was created from, when the backend
  /// includes it — lets the app mark exactly that notification read on tap.
  String? get notificationId {
    final id = data['notificationId'];
    return (id != null && id.isNotEmpty) ? id : null;
  }

  /// The in-app route to open, or null to fall back to the notifications list.
  /// Uses the same resolver as the in-app notification rows.
  String? get route => resolveNotificationRouteFrom(type: type, targetUrl: targetUrl);

  factory PushMessage.fromData(
    Map<String, dynamic>? data, {
    String? title,
    String? body,
  }) {
    final out = <String, String>{};
    (data ?? const {}).forEach((k, v) {
      if (v == null) return;
      out[k] = v is String ? v : '$v';
    });
    return PushMessage(data: out, title: title, body: body);
  }
}
