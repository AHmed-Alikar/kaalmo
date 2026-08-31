import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/auth/login_required_sheet.dart';
import '../../../shared/states/state_views.dart';
import '../application/campaign_comments_controller.dart';
import 'widgets/comment_composer.dart';
import 'widgets/comment_tile.dart';

class CampaignCommentsScreen extends ConsumerWidget {
  const CampaignCommentsScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(campaignCommentsControllerProvider(campaignId));
    final controller = ref.read(campaignCommentsControllerProvider(campaignId).notifier);
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.comments)),
      body: Column(
        children: [
          Expanded(child: _list(context, ref, state, controller)),
          if (auth.isAuthenticated)
            CommentComposer(
              submitting: state.submitting,
              onSubmit: (text) async {
                final err = await controller.submit(text);
                if (err != null && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(presentError(err, l10n))));
                  return false;
                }
                return true;
              },
            )
          else
            _SignInToComment(campaignId: campaignId),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    WidgetRef ref,
    CommentsState state,
    CampaignCommentsController controller,
  ) {
    final l10n = context.l10n;
    switch (state.status) {
      case CommentsStatus.loading:
        return const LoadingView();
      case CommentsStatus.error:
        return ErrorView(
          title: l10n.stateErrorTitle,
          message: presentError(state.error ?? l10n.errorUnexpected, l10n),
          onRetry: controller.refresh,
        );
      case CommentsStatus.ready:
        if (state.comments.isEmpty) {
          return _EmptyScrollable(
            child: EmptyView(
              title: l10n.commentsEmptyTitle,
              message: l10n.commentsEmpty,
              icon: Icons.forum_outlined,
            ),
          );
        }
        final currentUserId = ref.watch(authControllerProvider).user?.id;
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: state.comments.length,
            separatorBuilder: (_, _) => const Divider(height: 26),
            itemBuilder: (context, i) =>
                CommentTile(comment: state.comments[i], currentUserId: currentUserId),
          ),
        );
    }
  }
}

class _SignInToComment extends StatelessWidget {
  const _SignInToComment({required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.lock_outline, size: 18),
            label: Text(l10n.commentSignInPrompt),
            onPressed: () => showLoginRequiredSheet(
              context,
              actionLabel: l10n.comments.toLowerCase(),
              returnTo: '${AppRoutes.campaign(campaignId)}/comments',
            ),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
          ),
        ),
      ),
    );
  }
}

class _EmptyScrollable extends StatelessWidget {
  const _EmptyScrollable({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      );
}
