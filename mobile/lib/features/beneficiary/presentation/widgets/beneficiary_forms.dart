import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/errors/error_presenter.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../shared/buttons/primary_button.dart';
import '../../application/beneficiary_controllers.dart';

/// Bottom sheet: submit / update the beneficiary identity (`fullName`).
Future<void> showBeneficiaryIdentitySheet(BuildContext context, {String initialName = ''}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _IdentitySheet(initialName: initialName),
    ),
  );
}

class _IdentitySheet extends ConsumerStatefulWidget {
  const _IdentitySheet({required this.initialName});
  final String initialName;

  @override
  ConsumerState<_IdentitySheet> createState() => _IdentitySheetState();
}

class _IdentitySheetState extends ConsumerState<_IdentitySheet> {
  late final TextEditingController _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(beneficiaryIdentityControllerProvider(widget.initialName).notifier);
    final state = ref.watch(beneficiaryIdentityControllerProvider(widget.initialName));

    ref.listen(
      beneficiaryIdentityControllerProvider(widget.initialName).select((s) => s.phase),
      (_, phase) {
        if (phase == FormPhase.done) {
          ref.invalidate(beneficiaryProfileProvider);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(l10n.beneficiaryIdentitySubmitted)));
        }
      },
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.beneficiaryIdentityTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(l10n.beneficiaryIdentitySubtitle,
                style: TextStyle(fontSize: 12.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: true,
              maxLength: kBeneficiaryNameMax,
              onChanged: controller.setName,
              decoration: InputDecoration(
                labelText: l10n.beneficiaryFullNameLabel,
                counterText: '',
                errorText: state.fullName.isNotEmpty && !state.nameValid
                    ? l10n.beneficiaryFullNameInvalid
                    : null,
              ),
            ),
            if (state.phase == FormPhase.error && state.error != null) ...[
              const SizedBox(height: 10),
              Text(presentError(state.error!, l10n),
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: l10n.beneficiarySubmitIdentity,
              isLoading: state.submitting,
              onPressed: state.canSubmit ? () => controller.submit() : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet: add a payout account.
Future<void> showPayoutAccountSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: const _PayoutSheet(),
    ),
  );
}

class _PayoutSheet extends ConsumerStatefulWidget {
  const _PayoutSheet();

  @override
  ConsumerState<_PayoutSheet> createState() => _PayoutSheetState();
}

class _PayoutSheetState extends ConsumerState<_PayoutSheet> {
  final _account = TextEditingController();
  final _provider = TextEditingController();

  @override
  void dispose() {
    _account.dispose();
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = ref.read(payoutAccountFormControllerProvider.notifier);
    final state = ref.watch(payoutAccountFormControllerProvider);

    ref.listen(payoutAccountFormControllerProvider.select((s) => s.phase), (_, phase) {
      if (phase == FormPhase.done) {
        ref.invalidate(payoutAccountsProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.beneficiaryPayoutAdded)));
      }
    });

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.beneficiaryAddPayoutTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'mobile_money', label: Text(l10n.payoutTypeMobileMoney)),
                  ButtonSegment(value: 'bank', label: Text(l10n.payoutTypeBank)),
                ],
                selected: {state.type},
                onSelectionChanged: (s) => controller.setType(s.first),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _provider,
                onChanged: controller.setProviderName,
                decoration: InputDecoration(
                  labelText: l10n.beneficiaryProviderLabel,
                  hintText: l10n.beneficiaryProviderHint,
                  errorText: state.providerName.isNotEmpty && !state.providerValid
                      ? l10n.beneficiaryProviderInvalid
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _account,
                keyboardType: TextInputType.number,
                onChanged: controller.setAccountNumber,
                decoration: InputDecoration(
                  labelText: l10n.beneficiaryAccountNumberLabel,
                  helperText: l10n.beneficiaryAccountNumberHelper,
                  errorText: state.accountNumber.isNotEmpty && !state.accountValid
                      ? l10n.beneficiaryAccountNumberInvalid
                      : null,
                ),
              ),
              if (state.phase == FormPhase.error && state.error != null) ...[
                const SizedBox(height: 10),
                Text(presentError(state.error!, l10n),
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 14),
              PrimaryButton(
                label: l10n.beneficiaryAddPayoutButton,
                isLoading: state.submitting,
                onPressed: state.canSubmit ? () => controller.submit() : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
