import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/auth/login_required_sheet.dart';
import '../../../shared/states/state_views.dart';
import 'widgets/my_donation_tile.dart';

/// The signed-in donor's donation history, on `/profile/donations`.
class MyDonationsScreen extends ConsumerWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myDonationsTitle)),
      body: SafeArea(
        child: !authed ? const _LoginGate() : const _History(),
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
      title: l10n.myDonationsLoginTitle,
      message: l10n.myDonationsLoginBody,
      actionLabel: l10n.authLogIn,
      onAction: () => showLoginRequiredSheet(
        context,
        actionLabel: l10n.myDonationsActionLabel,
        returnTo: AppRoutes.myDonations,
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final donations = ref.watch(myDonationsProvider);

    return donations.when(
      loading: () => const LoadingView(),
      error: (err, _) => ErrorView(
        title: l10n.myDonationsErrorTitle,
        message: presentError(err, l10n),
        onRetry: () => ref.invalidate(myDonationsProvider),
      ),
      data: (list) {
        if (list.isEmpty) {
          return _EmptyScrollable(
            onRefresh: () async => ref.invalidate(myDonationsProvider),
            child: EmptyView(
              icon: Icons.favorite_border,
              title: l10n.myDonationsEmptyTitle,
              message: l10n.myDonationsEmptyBody,
              actionLabel: l10n.myDonationsExplore,
              onAction: () => context.go(AppRoutes.explore),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myDonationsProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final d = list[i];
              return MyDonationTile(
                donation: d,
                onTap: () => context.push('${AppRoutes.myDonations}/${d.id}'),
              );
            },
          ),
        );
      },
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
