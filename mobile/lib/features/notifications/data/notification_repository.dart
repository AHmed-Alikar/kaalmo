import 'models/app_notification.dart';
import 'notification_api.dart';

/// Maps the notification API onto typed models. Read-state is owned by the
/// backend — this layer just relays.
class NotificationRepository {
  NotificationRepository(this._api);

  final NotificationApi _api;

  Future<NotificationFeed> list() async => NotificationFeed.fromJson(await _api.list());

  Future<void> markRead(String id) => _api.markRead(id);

  Future<void> markAllRead() => _api.markAllRead();
}
