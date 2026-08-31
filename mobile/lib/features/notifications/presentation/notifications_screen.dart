import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/auth/login_required_sheet.dart';
import '../../../shared/states/state_views.dart';
import '../application/notifications_controller.dart';
import '../domain/notification_target.dart';
import 'widgets/notification_tile.dart';

/// `/notifications` — the signed-in user's in-app notifications.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Re-check for anything that arrived while the app was elsewhere.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(authControllerProvider).isAuthenticated) {
        ref.read(notificationsControllerProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    ref.listen(notificationsControllerProvider.select((s) => s.mutationError), (_, err) {
      if (err != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(presentError(err, l10n))));
        controller.clearMutationError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          if (authed && state.unreadCount > 0)
            TextButton(
              onPressed: controller.markAllRead,
              child: Text(l10n.notificationsMarkAllRead),
            ),
        ],
      ),
      body: SafeArea(
        child: !authed ? const _LoginGate() : _Body(state: state, controller: controller),
      ),
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyView(
      icon: Icons.lock_outline,
      title: l10n.notificationsLoginTitle,
      message: l10n.notificationsLoginBody,
      actionLabel: l10n.authLogIn,
      onAction: () => showLoginRequiredSheet(
        context,
        actionLabel: l10n.notificationsActionLabel,
        returnTo: AppRoutes.notifications,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.controller});

  final NotificationsState state;
  final NotificationsController controller;

  void _open(BuildContext context, String id) {
    final n = state.items.firstWhere((x) => x.id == id);
    controller.markRead(n.id);
    final route = resolveNotificationRoute(n);
    if (route != null) context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.isLoading) return const LoadingView();
    if (state.isError) {
      return ErrorView(
        title: l10n.notificationsErrorTitle,
        message: presentError(state.error ?? l10n.errorUnexpected, l10n),
        onRetry: controller.refresh,
      );
    }
    if (state.isEmpty) {
      return _EmptyScrollable(
        onRefresh: controller.refresh,
        child: EmptyView(
          icon: Icons.notifications_none,
          title: l10n.notificationsEmptyTitle,
          message: l10n.notificationsEmptyBody,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: state.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final n = state.items[i];
          return NotificationTile(
            notification: n,
            onTap: () => _open(context, n.id),
          );
        },
      ),
    );
  }
}

class _EmptyScrollable extends StatelessWidget {
  const _EmptyScrollable({required this.child, required this.onRefresh});

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: child,
            ),
          ),
        ),
      );
}
