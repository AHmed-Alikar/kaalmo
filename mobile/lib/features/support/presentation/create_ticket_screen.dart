import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/buttons/primary_button.dart';
import '../application/support_controllers.dart';

/// `/support/new` — open a support ticket. Optionally pre-filled (e.g. from
/// "close my account").
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key, this.initialSubject});

  final String? initialSubject;

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialSubject != null) {
      _subject.text = widget.initialSubject!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(newTicketControllerProvider.notifier).setSubject(widget.initialSubject!);
      });
    }
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(newTicketControllerProvider.notifier);
    final state = ref.watch(newTicketControllerProvider);

    ref.listen(newTicketControllerProvider.select((s) => s.phase), (_, phase) {
      if (phase == SubmitPhase.done) {
        ref.invalidate(myTicketsProvider);
        final id = ref.read(newTicketControllerProvider).created?.id;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.supportTicketCreated)));
        if (id != null && id.isNotEmpty) {
          context.pushReplacement(AppRoutes.supportTicket(id));
        } else if (context.canPop()) {
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportNewTicket)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  Text(l10n.supportNewSubtitle,
                      style: TextStyle(
                          fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subject,
                    maxLength: kTicketSubjectMax,
                    onChanged: controller.setSubject,
                    decoration: InputDecoration(
                      labelText: l10n.supportSubjectLabel,
                      counterText: '',
                      errorText: state.subject.isNotEmpty && !state.subjectValid
                          ? l10n.supportSubjectInvalid(kTicketSubjectMin)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _message,
                    minLines: 5,
                    maxLines: 12,
                    maxLength: kTicketMessageMax,
                    onChanged: controller.setMessage,
                    decoration: InputDecoration(
                      labelText: l10n.supportMessageLabel,
                      hintText: l10n.supportMessageHint,
                      alignLabelWithHint: true,
                      errorText: state.message.isNotEmpty && !state.messageValid
                          ? l10n.supportMessageInvalid(kTicketMessageMin)
                          : null,
                    ),
                  ),
                  if (state.phase == SubmitPhase.error && state.error != null) ...[
                    const SizedBox(height: 12),
                    Text(presentError(state.error!, l10n),
                        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
                  ],
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SafeArea(
                top: false,
                child: PrimaryButton(
                  label: l10n.supportSend,
                  isLoading: state.submitting,
                  onPressed: state.canSubmit ? () => controller.submit() : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
