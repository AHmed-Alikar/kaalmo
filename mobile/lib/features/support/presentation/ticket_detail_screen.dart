import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/relative_time.dart';
import '../../../shared/states/state_views.dart';
import '../application/support_controllers.dart';
import '../data/models/support_ticket.dart';

/// `/support/:id` — a support ticket, its thread, and a reply box.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = widget.ticketId;
    final ticketAsync = ref.watch(supportTicketProvider(id));
    final replyController = ref.read(ticketReplyControllerProvider(id).notifier);
    final replyState = ref.watch(ticketReplyControllerProvider(id));

    ref.listen(ticketReplyControllerProvider(id).select((s) => s.phase), (_, phase) {
      if (phase == SubmitPhase.done) {
        _reply.clear();
        ref.invalidate(supportTicketProvider(id));
        ref.invalidate(myTicketsProvider);
      } else if (phase == SubmitPhase.error) {
        final err = ref.read(ticketReplyControllerProvider(id)).error;
        if (err != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(presentError(err, l10n))));
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTicketTitle)),
      body: SafeArea(
        child: ticketAsync.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.supportErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(supportTicketProvider(id)),
          ),
          data: (ticket) {
            final canReply = ticket.statusView != TicketStatusView.closed;
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(supportTicketProvider(id)),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        _Header(ticket: ticket),
                        const SizedBox(height: 14),
                        _Bubble(mine: true, message: ticket.message, at: ticket.createdAt),
                        for (final r in ticket.replies) ...[
                          const SizedBox(height: 10),
                          _Bubble(mine: r.isMine, message: r.message, at: r.createdAt),
                        ],
                      ],
                    ),
                  ),
                ),
                if (canReply)
                  _ReplyBar(
                    controller: _reply,
                    onChanged: replyController.setText,
                    submitting: replyState.submitting,
                    canSubmit: replyState.canSubmit,
                    onSubmit: replyController.submit,
                  )
                else
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.all(14),
                    child: SafeArea(
                      top: false,
                      child: Text(l10n.supportTicketClosed,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.ticket});
  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = ticket.statusView;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ticket.subject,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
          child: Text(status.label(l10n),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: status.color)),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.mine, required this.message, this.at});

  final bool mine;
  final String message;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? scheme.primary.withValues(alpha: 0.10) : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(mine ? l10n.supportAuthorYou : l10n.supportAuthorSupport,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 3),
              Text(message, style: const TextStyle(fontSize: 13.5, height: 1.4)),
              const SizedBox(height: 3),
              Text(formatRelative(at, l10n),
                  style: TextStyle(fontSize: 10.5, color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({
    required this.controller,
    required this.onChanged,
    required this.submitting,
    required this.canSubmit,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool submitting;
  final bool canSubmit;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                maxLength: kTicketReplyMax,
                onChanged: onChanged,
                decoration: InputDecoration(hintText: l10n.supportReplyHint, isDense: true, counterText: ''),
              ),
            ),
            const SizedBox(width: 4),
            submitting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4)),
                  )
                : IconButton.filled(
                    onPressed: canSubmit ? () => onSubmit() : null,
                    icon: const Icon(Icons.send, size: 18),
                    tooltip: l10n.supportSend,
                  ),
          ],
        ),
      ),
    );
  }
}
