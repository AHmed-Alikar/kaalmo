import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/money_input.dart';
import '../../../shared/auth/login_required_sheet.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/buttons/secondary_button.dart';
import '../../../shared/states/state_views.dart';
import '../../campaigns/data/models/campaign.dart';
import '../application/donate_controller.dart';
import '../application/donate_state.dart';
import '../domain/payment_method.dart';
import 'widgets/donate_campaign_header.dart';
import 'widgets/donation_receipt_card.dart';
import 'widgets/payment_method_selector.dart';

/// The full donation + payment flow for one campaign, on `/campaign/:id/donate`.
/// A single screen with an internal step machine (amount → review → processing
/// → success / pending / failed) so state survives "back / edit" without
/// plumbing it through the router.
class DonateFlowScreen extends ConsumerWidget {
  const DonateFlowScreen({super.key, required this.campaignId});

  final String campaignId;

  void _leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.campaign(campaignId));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.donateTitle)),
      body: SafeArea(
        child: !authed
            ? _LoginGate(campaignId: campaignId)
            : _CampaignGate(campaignId: campaignId, onLeave: () => _leave(context)),
      ),
    );
  }
}

/// Donation needs a signed-in donor (for the receipt, history and confirmation
/// notification). Reuses the app's login-return flow.
class _LoginGate extends StatelessWidget {
  const _LoginGate({required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyView(
      icon: Icons.lock_outline,
      title: l10n.donateLoginTitle,
      message: l10n.donateLoginBody,
      actionLabel: l10n.authLogIn,
      onAction: () => showLoginRequiredSheet(
        context,
        actionLabel: l10n.donateActionLabel,
        returnTo: '${AppRoutes.campaign(campaignId)}/donate',
      ),
    );
  }
}

class _CampaignGate extends ConsumerWidget {
  const _CampaignGate({required this.campaignId, required this.onLeave});

  final String campaignId;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final detail = ref.watch(campaignDetailControllerProvider(campaignId));
    final controller = ref.read(campaignDetailControllerProvider(campaignId).notifier);

    if (detail.isLoading) return const LoadingView();
    if (detail.isError || detail.campaign == null) {
      return ErrorView(
        title: l10n.campaignLoadErrorTitle,
        message: presentError(detail.error ?? l10n.errorUnexpected, l10n),
        onRetry: controller.refresh,
      );
    }
    return _Flow(campaign: detail.campaign!, campaignId: campaignId, onLeave: onLeave);
  }
}

class _Flow extends ConsumerStatefulWidget {
  const _Flow({required this.campaign, required this.campaignId, required this.onLeave});

  final Campaign campaign;
  final String campaignId;
  final VoidCallback onLeave;

  @override
  ConsumerState<_Flow> createState() => _FlowState();
}

class _FlowState extends ConsumerState<_Flow> {
  final _amountCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _messageCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  DonateController get _controller => ref.read(donateControllerProvider(widget.campaignId).notifier);

  void _handlePop(DonatePhase phase) {
    switch (phase) {
      case DonatePhase.review:
      case DonatePhase.failed:
      case DonatePhase.pending:
        _controller.editDonation();
      case DonatePhase.success:
        widget.onLeave();
      case DonatePhase.editing:
      case DonatePhase.processing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.campaignId;
    final state = ref.watch(donateControllerProvider(id));

    // Preset taps change the controller's amountText — mirror it into the field.
    if (_amountCtrl.text != state.amountText) {
      _amountCtrl.value = TextEditingValue(
        text: state.amountText,
        selection: TextSelection.collapsed(offset: state.amountText.length),
      );
    }

    // Once a donation is confirmed / pending, pull fresh campaign totals from
    // the backend — never fake them on the client.
    ref.listen(donateControllerProvider(id).select((s) => s.phase), (_, next) {
      if (next == DonatePhase.success || next == DonatePhase.pending) {
        ref.read(campaignDetailControllerProvider(id).notifier).refresh();
        ref.invalidate(campaignSupportersProvider(id));
      }
    });

    return PopScope(
      canPop: state.phase == DonatePhase.editing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handlePop(state.phase);
      },
      child: switch (state.phase) {
        DonatePhase.editing => _AmountStep(
            campaignId: id,
            campaign: widget.campaign,
            amountCtrl: _amountCtrl,
            messageCtrl: _messageCtrl,
          ),
        DonatePhase.review => _ReviewStep(
            campaignId: id,
            campaign: widget.campaign,
            phoneCtrl: _phoneCtrl,
          ),
        DonatePhase.processing => _StatusView(
            spinning: true,
            icon: Icons.hourglass_top,
            title: context.l10n.donateProcessingTitle,
            body: context.l10n.donateProcessingBody,
          ),
        DonatePhase.pending => _PendingView(onDone: widget.onLeave),
        DonatePhase.success => _SuccessView(
            campaign: widget.campaign,
            state: state,
            onDone: () {
              ref.invalidate(campaignDetailControllerProvider(id));
              widget.onLeave();
            },
          ),
        DonatePhase.failed => _FailedView(
            state: state,
            onRetry: _controller.retry,
            onEdit: _controller.editDonation,
            onCancel: widget.onLeave,
          ),
      },
    );
  }
}

// --- Step 1: amount / message / anonymous ----------------------------------

class _AmountStep extends ConsumerWidget {
  const _AmountStep({
    required this.campaignId,
    required this.campaign,
    required this.amountCtrl,
    required this.messageCtrl,
  });

  final String campaignId;
  final Campaign campaign;
  final TextEditingController amountCtrl;
  final TextEditingController messageCtrl;

  String? _amountError(DonateState state, AppL10n l10n) => switch (state.amountIssue) {
        AmountIssue.none || AmountIssue.empty => null,
        AmountIssue.notANumber => l10n.donateAmountInvalid,
        AmountIssue.belowMinimum =>
          l10n.donateAmountTooLow(formatAmount(state.minAmount, campaign.currency)),
        AmountIssue.aboveMaximum =>
          l10n.donateAmountTooHigh(formatAmount(kDonationMaxAmount, campaign.currency)),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(donateControllerProvider(campaignId));
    final controller = ref.read(donateControllerProvider(campaignId).notifier);

    return _StepScaffold(
      items: [
        DonateCampaignHeader(campaign: campaign),
        const SizedBox(height: 22),
        Text(l10n.donateAmountLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in kDonationPresets)
              _PresetChip(
                label: formatAmount(preset, campaign.currency),
                selected: state.amountValue == preset.toDouble(),
                onTap: () => controller.selectPreset(preset),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [DecimalAmountFormatter()],
          onChanged: controller.setAmount,
          decoration: InputDecoration(
            labelText: l10n.donateCustomAmount,
            prefixText: '${campaign.currency}  ',
            errorText: _amountError(state, l10n),
          ),
        ),
        const SizedBox(height: 22),
        Text(l10n.donateMessageLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: messageCtrl,
          minLines: 2,
          maxLines: 4,
          maxLength: kDonationMessageMax,
          onChanged: controller.setMessage,
          decoration: InputDecoration(
            hintText: l10n.donateMessageHint,
            errorText: state.messageTooLong ? l10n.donateMessageTooLong : null,
          ),
        ),
        const SizedBox(height: 4),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: state.isAnonymous,
          onChanged: controller.setAnonymous,
          title: Text(l10n.donateAnonymousTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(l10n.donateAnonymousSubtitle,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        if (state.configError != null) ...[
          const SizedBox(height: 8),
          _InlineError(
            message: presentError(state.configError!, l10n),
            onRetry: controller.retryLoadConfig,
          ),
        ],
      ],
      footer: PrimaryButton(
        label: l10n.donateContinue,
        onPressed: state.canContinue ? controller.goToReview : null,
        isLoading: state.configLoading,
      ),
    );
  }
}

// --- Step 2: review + payment method -------------------------------------

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({
    required this.campaignId,
    required this.campaign,
    required this.phoneCtrl,
  });

  final String campaignId;
  final Campaign campaign;
  final TextEditingController phoneCtrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(donateControllerProvider(campaignId));
    final controller = ref.read(donateControllerProvider(campaignId).notifier);
    // Only real payment methods — `manual` (offline recording) is not a donor
    // option, so the flow always drives an actual EVC Plus / WaafiPay charge.
    final providers = state.donorProviders;
    final amountText = formatAmount(state.amountValue ?? 0, campaign.currency);

    return _StepScaffold(
      items: [
        DonateCampaignHeader(campaign: campaign),
        const SizedBox(height: 20),
        Text(l10n.donateReviewTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        _ReviewRow(label: l10n.donateReviewAmount, value: amountText, emphasize: true),
        _ReviewRow(
          label: l10n.donateReviewMessage,
          value: state.message.trim().isEmpty ? l10n.donateReviewNoMessage : state.message.trim(),
        ),
        _ReviewRow(
          label: l10n.donateReviewAnonymous,
          value: state.isAnonymous ? l10n.donateAnonymousYes : l10n.donateAnonymousNo,
        ),
        const Divider(height: 28),
        Text(l10n.donatePaymentMethod,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        PaymentMethodSelector(
          providerIds: providers,
          selectedId: state.providerId,
          onSelected: controller.selectProvider,
        ),
        if (state.providerRequiresPhone) ...[
          const SizedBox(height: 6),
          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
            onChanged: controller.setPhone,
            decoration: InputDecoration(
              labelText: l10n.donatePhoneLabel,
              hintText: l10n.donatePhoneHint,
              errorText: state.phone.isNotEmpty && !state.phoneValid ? l10n.donatePhoneInvalid : null,
            ),
          ),
        ],
        const Divider(height: 28),
        _ReviewRow(label: l10n.donateFees, value: l10n.donateFeesNone),
        _ReviewRow(label: l10n.donateTotal, value: amountText, emphasize: true),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Expanded(
              child: Text(l10n.donateSecurityNote,
                  style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
        if (state.submitError != null) ...[
          const SizedBox(height: 10),
          _InlineError(message: presentError(state.submitError!, l10n)),
        ],
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: l10n.donateConfirm(amountText),
            onPressed: state.canSubmit ? controller.submit : null,
            isLoading: state.isProcessing,
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: l10n.donateEdit,
            onPressed: state.isProcessing ? null : controller.editDonation,
          ),
        ],
      ),
    );
  }
}

// --- Terminal states ----------------------------------------------------

class _StatusView extends StatelessWidget {
  const _StatusView({
    required this.icon,
    required this.title,
    required this.body,
    this.spinning = false,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool spinning;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (spinning)
              const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3))
            else
              Icon(icon, size: 52, color: color),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _PendingView extends StatelessWidget {
  const _PendingView({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _StepScaffold(
      items: [
        const SizedBox(height: 12),
        _StatusView(
          icon: Icons.schedule,
          iconColor: Theme.of(context).colorScheme.tertiary,
          title: l10n.donatePendingTitle,
          body: l10n.donatePendingBody,
        ),
      ],
      footer: PrimaryButton(label: l10n.donateBackToCampaign, onPressed: onDone),
    );
  }
}

class _FailedView extends StatelessWidget {
  const _FailedView({
    required this.state,
    required this.onRetry,
    required this.onEdit,
    required this.onCancel,
  });

  final DonateState state;
  final VoidCallback onRetry;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message =
        state.submitError != null ? presentError(state.submitError!, l10n) : l10n.donateFailedGeneric;

    return _StepScaffold(
      items: [
        const SizedBox(height: 12),
        _StatusView(
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          title: l10n.donateFailedTitle,
          body: message,
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: l10n.donateRetry, onPressed: onRetry),
          const SizedBox(height: 8),
          SecondaryButton(label: l10n.donateEdit, onPressed: onEdit),
          const SizedBox(height: 8),
          TextButton(onPressed: onCancel, child: Text(l10n.donateBackToCampaign)),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.campaign, required this.state, required this.onDone});

  final Campaign campaign;
  final DonateState state;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final result = state.result!;
    final lang = Localizations.localeOf(context).languageCode;

    return _StepScaffold(
      items: [
        const SizedBox(height: 8),
        Center(child: Icon(Icons.check_circle, size: 56, color: scheme.primary)),
        const SizedBox(height: 12),
        Center(
          child: Text(l10n.donateSuccessTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            l10n.donateSuccessBody(formatAmount(result.amount, result.currency)),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 20),
        DonationReceiptCard(
          campaignTitle: campaign.titleFor(lang),
          amount: result.amount,
          currency: result.currency,
          isAnonymous: result.isAnonymous,
          date: result.createdAt,
          methodLabel: (state.providerId ?? '').isEmpty
              ? null
              : PaymentMethod(state.providerId!).title(l10n),
          reference: result.donationId,
          message: result.message,
        ),
      ],
      footer: PrimaryButton(label: l10n.donateBackToCampaign, onPressed: onDone),
    );
  }
}

// --- Shared layout / small widgets ------------------------------------

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.items, required this.footer});

  final List<Widget> items;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: items,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(top: false, child: footer),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        color: selected ? scheme.onPrimary : scheme.onSurface,
      ),
      selectedColor: scheme.primary,
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value, this.emphasize = false});

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: emphasize ? 16 : 14,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color: emphasize ? scheme.primary : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 12.5, color: scheme.onErrorContainer)),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: Text(context.l10n.actionRetry)),
        ],
      ),
    );
  }
}
