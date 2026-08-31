import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../shared/auth/auth_error_banner.dart';
import '../../../../shared/buttons/primary_button.dart';
import '../../../../shared/states/state_views.dart';
import '../../domain/report_reasons.dart';

/// Report flow: pick a reason → optional explanation → submit → confirmation.
/// Backend contract: `POST /reports { targetType:'campaign', targetId, reason }`
/// where `reason` is free text 5–500 chars (no enum) — see [ReportReason].
Future<void> showReportSheet(
  BuildContext context, {
  required String campaignId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _ReportSheet(campaignId: campaignId),
    ),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  final _explanation = TextEditingController();
  ReportReason? _reason;
  bool _submitting = false;
  bool _done = false;
  String? _error;

  @override
  void dispose() {
    _explanation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_reason == null || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref
          .read(campaignRepositoryProvider)
          .reportCampaign(
            widget.campaignId,
            _reason!.compose(_explanation.text),
          );
      if (mounted) setState(() => _done = true);
    } catch (e) {
      if (mounted) setState(() => _error = presentError(e, l10n));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: _done
            ? _Confirmation(onClose: () => Navigator.of(context).pop())
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.reportTitle,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.reportSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AuthErrorBanner(_error),
                    RadioGroup<ReportReason>(
                      groupValue: _reason,
                      onChanged: (v) {
                        if (!_submitting) setState(() => _reason = v);
                      },
                      child: Column(
                        children: [
                          for (final reason in ReportReason.values)
                            RadioListTile<ReportReason>(
                              value: reason,
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(reason.label(l10n)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _explanation,
                      enabled: !_submitting,
                      maxLength: 400,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.reportExplanationLabel,
                        hintText: l10n.reportExplanationHint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PrimaryButton(
                      label: l10n.reportSubmit,
                      isLoading: _submitting,
                      onPressed: _reason == null ? null : _submit,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Confirmation extends StatelessWidget {
  const _Confirmation({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SuccessView(
        title: l10n.reportSuccessTitle,
        message: l10n.reportSuccessBody,
        actionLabel: l10n.actionClose,
        onAction: onClose,
      ),
    );
  }
}
