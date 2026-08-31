import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/relative_time.dart';
import '../../../shared/states/state_views.dart';
import '../data/models/support_ticket.dart';

/// `/support` — the signed-in user's support tickets.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tickets = ref.watch(myTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.supportNew),
        icon: const Icon(Icons.add),
        label: Text(l10n.supportNewTicket),
      ),
      body: SafeArea(
        child: tickets.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.supportErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(myTicketsProvider),
          ),
          data: (list) {
            if (list.isEmpty) {
              return _EmptyScrollable(
                onRefresh: () async => ref.invalidate(myTicketsProvider),
                child: EmptyView(
                  icon: Icons.support_agent_outlined,
                  title: l10n.supportEmptyTitle,
                  message: l10n.supportEmptyBody,
                  actionLabel: l10n.supportNewTicket,
                  onAction: () => context.push(AppRoutes.supportNew),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myTicketsProvider),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _TicketTile(
                  ticket: list[i],
                  onTap: () => context.push(AppRoutes.supportTicket(list[i].id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  const _TicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final status = ticket.statusView;

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(ticket.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                ticket.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(formatRelative(ticket.updatedAt ?? ticket.createdAt, l10n),
                      style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                  const Spacer(),
                  if (ticket.replies.isNotEmpty)
                    Text(l10n.supportReplyCount(ticket.replies.length),
                        style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final TicketStatusView status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
      child: Text(status.label(context.l10n),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
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
