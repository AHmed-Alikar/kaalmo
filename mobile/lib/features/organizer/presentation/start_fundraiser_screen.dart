import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/buttons/secondary_button.dart';
import '../../campaigns/domain/campaign_categories.dart';
import '../application/campaign_editor_state.dart' show kTitleMax, kStoryMin, kTitleMin;
import '../application/create_campaign_controller.dart';
import '../application/organizer_access_controller.dart';

/// `/organizer/start` — "Start a fundraiser". One screen, two stages:
///  1. if the account is not an organizer yet → request + confirm the emailed
///     access code (reuses `POST /users/me/(request|confirm)-organizer-access`),
///  2. the create-campaign form → `POST /campaigns` → the campaign's manage
///     screen.
/// The web Create Campaign flow is untouched — this is the mobile equivalent
/// built on the same backend contract.
class StartFundraiserScreen extends ConsumerWidget {
  const StartFundraiserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOrganizer = ref.watch(authControllerProvider.select((s) => s.user?.isOrganizer ?? false));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.startFundraiserTitle)),
      body: SafeArea(
        child: isOrganizer ? const _CreateCampaignStep() : const _OrganizerAccessStep(),
      ),
    );
  }
}

// --- Stage 1: become an organizer -------------------------------------------

class _OrganizerAccessStep extends ConsumerStatefulWidget {
  const _OrganizerAccessStep();

  @override
  ConsumerState<_OrganizerAccessStep> createState() => _OrganizerAccessStepState();
}

class _OrganizerAccessStepState extends ConsumerState<_OrganizerAccessStep> {
  final _fullName = TextEditingController();
  final _purpose = TextEditingController();
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fullName.text = ref.read(organizerAccessControllerProvider).fullName;
  }

  @override
  void dispose() {
    _fullName.dispose();
    _purpose.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(organizerAccessControllerProvider);
    final controller = ref.read(organizerAccessControllerProvider.notifier);

    final onCodeStage = state.phase == OrganizerAccessPhase.codeSent ||
        state.phase == OrganizerAccessPhase.confirming;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Icon(Icons.campaign_outlined, size: 40, color: scheme.primary),
        const SizedBox(height: 12),
        Text(
          onCodeStage ? l10n.organizerAccessConfirmTitle : l10n.organizerAccessTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          onCodeStage ? l10n.organizerAccessConfirmBody : l10n.organizerAccessBody,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13.5),
        ),
        const SizedBox(height: 20),
        if (!onCodeStage) ...[
          Text(l10n.organizerAccessFullName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _fullName,
            textCapitalization: TextCapitalization.words,
            onChanged: controller.setFullName,
            decoration: const InputDecoration(),
          ),
          const SizedBox(height: 14),
          Text(l10n.organizerAccessPurpose,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: _purpose,
            minLines: 2,
            maxLines: 4,
            onChanged: controller.setPurpose,
            decoration: InputDecoration(hintText: l10n.organizerAccessPurposeHint),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            _ErrorText(presentError(state.error!, l10n)),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: l10n.organizerAccessSendCode,
            onPressed: state.canSend ? controller.sendCode : null,
            isLoading: state.phase == OrganizerAccessPhase.sending,
          ),
        ] else ...[
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(fontSize: 26, letterSpacing: 10, fontWeight: FontWeight.w700),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: controller.setCode,
            decoration: const InputDecoration(counterText: '', hintText: '000000'),
          ),
          if (state.resent) ...[
            const SizedBox(height: 4),
            Text(l10n.organizerAccessResent, style: TextStyle(color: scheme.tertiary, fontSize: 12.5)),
          ],
          if (state.error != null) ...[
            const SizedBox(height: 8),
            _ErrorText(presentError(state.error!, l10n)),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: l10n.organizerAccessConfirm,
            onPressed: state.canConfirm ? () => controller.confirm() : null,
            isLoading: state.phase == OrganizerAccessPhase.confirming,
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: l10n.organizerAccessResend,
            onPressed: state.isBusy ? null : controller.resendCode,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: state.isBusy ? null : controller.editRequest,
            child: Text(l10n.organizerAccessChangeDetails),
          ),
        ],
      ],
    );
  }
}

// --- Stage 2: create the campaign -----------------------------------------

class _CreateCampaignStep extends ConsumerStatefulWidget {
  const _CreateCampaignStep();

  @override
  ConsumerState<_CreateCampaignStep> createState() => _CreateCampaignStepState();
}

class _CreateCampaignStepState extends ConsumerState<_CreateCampaignStep> {
  final _titleSo = TextEditingController();
  final _titleEn = TextEditingController();
  final _storySo = TextEditingController();
  final _storyEn = TextEditingController();
  final _goal = TextEditingController();

  @override
  void dispose() {
    _titleSo.dispose();
    _titleEn.dispose();
    _storySo.dispose();
    _storyEn.dispose();
    _goal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(createCampaignControllerProvider);
    final controller = ref.read(createCampaignControllerProvider.notifier);

    ref.listen(createCampaignControllerProvider.select((s) => s.phase), (_, phase) {
      if (phase == CreatePhase.done) {
        final id = ref.read(createCampaignControllerProvider).created?.id;
        ref.invalidate(myCampaignsProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.createCampaignSuccess)));
        if (id != null && id.isNotEmpty) {
          context.pushReplacement(AppRoutes.organizerCampaign(id));
        } else if (context.canPop()) {
          context.pop();
        }
      }
    });

    final regions = <String?>[null, ...kCampaignRegions];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              Text(l10n.createCampaignTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(l10n.createCampaignSubtitle,
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12.5)),
              const SizedBox(height: 18),

              _Label(l10n.organizerFieldTitleSo),
              TextField(
                key: const Key('cc_titleSo'),
                controller: _titleSo,
                maxLength: kTitleMax,
                textCapitalization: TextCapitalization.sentences,
                onChanged: controller.setTitleSo,
                decoration: InputDecoration(
                  hintText: l10n.createCampaignTitleHint,
                  errorText: switch (state.titleSoError) {
                    'min' => l10n.organizerFieldTitleTooShort(kTitleMin),
                    'max' => l10n.organizerFieldTitleTooLong(kTitleMax),
                    _ => null,
                  },
                ),
              ),
              const SizedBox(height: 10),

              _Label(l10n.organizerFieldTitleEn),
              TextField(
                controller: _titleEn,
                maxLength: kTitleMax,
                textCapitalization: TextCapitalization.sentences,
                onChanged: controller.setTitleEn,
                decoration: const InputDecoration(counterText: ''),
              ),
              const SizedBox(height: 14),

              _Label(l10n.organizerFieldCategory),
              DropdownButtonFormField<String>(
                initialValue: state.category,
                items: [
                  for (final c in kCampaignCategories)
                    DropdownMenuItem(value: c.value, child: Text(c.label(l10n))),
                ],
                onChanged: (v) => v == null ? null : controller.setCategory(v),
              ),
              const SizedBox(height: 14),

              _Label(l10n.organizerFieldGoal),
              TextField(
                key: const Key('cc_goal'),
                controller: _goal,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                onChanged: controller.setGoal,
                decoration: InputDecoration(
                  prefixText: 'USD  ',
                  errorText: state.goalError == 'invalid' ? l10n.organizerFieldGoalInvalid : null,
                ),
              ),
              const SizedBox(height: 14),

              _Label(l10n.organizerFieldRegion),
              DropdownButtonFormField<String?>(
                initialValue: state.region,
                items: [
                  for (final r in regions)
                    DropdownMenuItem(value: r, child: Text(r ?? l10n.organizerRegionNone)),
                ],
                onChanged: controller.setRegion,
              ),
              const SizedBox(height: 14),

              _Label(l10n.createCampaignFieldEndDate),
              _EndDateField(
                value: state.endDate,
                onPick: controller.setEndDate,
              ),
              const SizedBox(height: 16),

              _Label(l10n.organizerFieldStorySo),
              TextField(
                key: const Key('cc_storySo'),
                controller: _storySo,
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                onChanged: controller.setStorySo,
                decoration: InputDecoration(
                  hintText: l10n.createCampaignStoryHint,
                  errorText:
                      state.storySoError == 'min' ? l10n.organizerFieldStoryTooShort(kStoryMin) : null,
                ),
              ),
              const SizedBox(height: 12),

              _Label(l10n.organizerFieldStoryEn),
              TextField(
                controller: _storyEn,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                onChanged: controller.setStoryEn,
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(Icons.info_outline, size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l10n.createCampaignCoverNote,
                        style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                  ),
                ],
              ),

              if (state.error != null) ...[
                const SizedBox(height: 12),
                _ErrorText(presentError(state.error!, l10n)),
              ],
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(
            top: false,
            child: PrimaryButton(
              label: l10n.createCampaignSubmit,
              onPressed: state.canSubmit ? () => controller.submit() : null,
              isLoading: state.isSubmitting,
            ),
          ),
        ),
      ],
    );
  }
}

class _EndDateField extends StatelessWidget {
  const _EndDateField({required this.value, required this.onPick});

  final DateTime? value;
  final ValueChanged<DateTime?> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined, size: 18),
            label: Text(
              value == null
                  ? l10n.createCampaignEndDatePick
                  : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? now.add(const Duration(days: 30)),
                firstDate: now.add(const Duration(days: 1)),
                lastDate: now.add(const Duration(days: 365 * 2)),
              );
              if (picked != null) onPick(picked);
            },
          ),
        ),
        if (value != null)
          IconButton(
            tooltip: l10n.actionClose,
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => onPick(null),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;

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
        ],
      ),
    );
  }
}
