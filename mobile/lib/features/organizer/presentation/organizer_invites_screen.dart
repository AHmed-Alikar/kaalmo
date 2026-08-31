import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/states/state_views.dart';
import '../data/models/campaign_invite.dart';

/// `/organizer/invites` — pending co-organizer invitations. Accepting one grants
/// campaign-scoped access only (the backend never changes the global role).
class OrganizerInvitesScreen extends ConsumerWidget {
  const OrganizerInvitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final invites = ref.watch(campaignInvitesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.invitesTitle)),
      body: SafeArea(
        child: invites.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.invitesErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(campaignInvitesProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return _EmptyScrollable(
                onRefresh: () async => ref.invalidate(campaignInvitesProvider),
                child: EmptyView(
                  icon: Icons.mark_email_read_outlined,
                  title: l10n.invitesEmptyTitle,
                  message: l10n.invitesEmptyBody,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(campaignInvitesProvider),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _InviteCard(invite: list[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InviteCard extends ConsumerStatefulWidget {
  const _InviteCard({required this.invite});
  final CampaignInvite invite;

  @override
  ConsumerState<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends ConsumerState<_InviteCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final invite = widget.invite;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invite.titleFor(lang).isEmpty ? l10n.invitesUnknownCampaign : invite.titleFor(lang),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            invite.inviterName != null
                ? l10n.invitesFrom(invite.inviterName!)
                : l10n.invitesGeneric,
            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : _accept,
                  child: _busy
                      ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.2))
                      : Text(l10n.invitesAccept),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _accept() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(organizerRepositoryProvider).acceptInvite(widget.invite.id);
      ref.invalidate(campaignInvitesProvider);
      ref.invalidate(myCampaignsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.invitesAccepted)));
      if (widget.invite.campaignId.isNotEmpty) {
        context.push(AppRoutes.organizerCampaign(widget.invite.campaignId));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(presentError(e, l10n))));
      }
    }
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
