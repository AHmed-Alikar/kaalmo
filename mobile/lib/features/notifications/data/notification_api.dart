import '../../../core/constants/api_routes.dart';
import '../../../core/network/api_client.dart';

/// Raw HTTP for in-app notifications. Existing backend contracts only.
class NotificationApi {
  NotificationApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/notifications/mine` → `{ items: [...], unreadCount }`.
  /// Capped at 50 rows by the backend; no pagination.
  Future<Map<String, dynamic>> list() =>
      _client.get<Map<String, dynamic>>(ApiRoutes.notifications);

  /// `PATCH /api/v1/notifications/:id/read` → the updated notification.
  Future<Map<String, dynamic>> markRead(String id) =>
      _client.patch<Map<String, dynamic>>(ApiRoutes.notificationRead(id));

  /// `PATCH /api/v1/notifications/read-all` → `{ updated: true }`.
  Future<Map<String, dynamic>> markAllRead() =>
      _client.patch<Map<String, dynamic>>(ApiRoutes.notificationsReadAll);
}
