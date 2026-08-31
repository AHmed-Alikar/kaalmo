import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_notification.dart';
import '../data/notification_repository.dart';

enum NotificationsStatus { loading, ready, error }

@immutable
class NotificationsState {
  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.items = const [],
    this.unreadCount = 0,
    this.error,
    this.mutationError,
  });

  final NotificationsStatus status;
  final List<AppNotification> items;

  /// Authoritative count from the backend (`unreadCount`), adjusted optimistically
  /// while a mark-read call is in flight and reverted if it fails.
  final int unreadCount;
  final Object? error;
  final Object? mutationError;

  bool get isLoading => status == NotificationsStatus.loading;
  bool get isError => status == NotificationsStatus.error;
  bool get isEmpty => status == NotificationsStatus.ready && items.isEmpty;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? items,
    int? unreadCount,
    Object? error,
    Object? mutationError,
    bool clearMutationError = false,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        items: items ?? this.items,
        unreadCount: unreadCount ?? this.unreadCount,
        error: error ?? this.error,
        mutationError: clearMutationError ? null : (mutationError ?? this.mutationError),
      );
}

/// Owns the notification feed. Read-state is the backend's — mark-read /
/// mark-all-read are applied optimistically and reverted on failure, never
/// left faked.
class NotificationsController extends StateNotifier<NotificationsState> {
  NotificationsController(this._repo, {bool autoLoad = true})
      : super(NotificationsState(
          status: autoLoad ? NotificationsStatus.loading : NotificationsStatus.ready,
        )) {
    if (autoLoad) load();
  }

  final NotificationRepository _repo;

  Future<void> load({bool silent = false}) async {
    if (!silent && state.items.isEmpty) {
      state = state.copyWith(status: NotificationsStatus.loading);
    }
    try {
      final feed = await _repo.list();
      state = NotificationsState(
        status: NotificationsStatus.ready,
        items: feed.items,
        unreadCount: feed.unreadCount,
      );
    } catch (e) {
      if (state.items.isEmpty) {
        state = NotificationsState(status: NotificationsStatus.error, error: e);
      } else {
        state = state.copyWith(mutationError: e);
      }
    }
  }

  Future<void> refresh() => load(silent: true);

  /// Pull the latest feed, then mark one notification read — used when a push
  /// for it is tapped and the row may not be loaded yet.
  Future<void> refreshThenMarkRead(String id) async {
    await load(silent: true);
    await markRead(id);
  }

  void clearMutationError() {
    if (state.mutationError != null) state = state.copyWith(clearMutationError: true);
  }

  Future<void> markRead(String id) async {
    final idx = state.items.indexWhere((n) => n.id == id);
    if (idx < 0 || state.items[idx].read) return;

    final before = state.items;
    final beforeCount = state.unreadCount;
    final optimistic = [...before]..[idx] = before[idx].copyWith(read: true);
    state = state.copyWith(
      items: optimistic,
      unreadCount: beforeCount > 0 ? beforeCount - 1 : 0,
      clearMutationError: true,
    );

    try {
      await _repo.markRead(id);
    } catch (e) {
      state = state.copyWith(items: before, unreadCount: beforeCount, mutationError: e);
    }
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0 && state.items.every((n) => n.read)) return;

    final before = state.items;
    final beforeCount = state.unreadCount;
    state = state.copyWith(
      items: [for (final n in before) n.read ? n : n.copyWith(read: true)],
      unreadCount: 0,
      clearMutationError: true,
    );

    try {
      await _repo.markAllRead();
    } catch (e) {
      state = state.copyWith(items: before, unreadCount: beforeCount, mutationError: e);
    }
  }
}
