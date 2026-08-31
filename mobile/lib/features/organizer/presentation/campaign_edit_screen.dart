import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/states/state_views.dart';
import '../../campaigns/data/models/campaign.dart';
import '../../campaigns/domain/campaign_categories.dart';
import '../application/campaign_editor_state.dart';

/// `/organizer/campaign/:id/edit` — edit the fields the backend
/// `updateCampaignSchema` accepts (title, story, category, goal, region).
/// Media and beneficiary linkage are not editable via this endpoint.
class CampaignEditScreen extends ConsumerWidget {
  const CampaignEditScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final campaign = ref.watch(organizerCampaignProvider(campaignId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizerEditTitle)),
      body: SafeArea(
        child: campaign.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.campaignLoadErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(organizerCampaignProvider(campaignId)),
          ),
          data: (c) => _Form(campaignId: campaignId, campaign: c),
        ),
      ),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({required this.campaignId, required this.campaign});

  final String campaignId;
  final Campaign campaign;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  final _titleSo = TextEditingController();
  final _titleEn = TextEditingController();
  final _storySo = TextEditingController();
  final _storyEn = TextEditingController();
  final _goal = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The provider seeds itself from the already-loaded campaign — just mirror
    // that into the text controllers.
    final s = ref.read(campaignEditorControllerProvider(widget.campaignId));
    _titleSo.text = s.titleSo;
    _titleEn.text = s.titleEn;
    _storySo.text = s.storySo;
    _storyEn.text = s.storyEn;
    _goal.text = s.goalText;
  }

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
    final id = widget.campaignId;
    final controller = ref.read(campaignEditorControllerProvider(id).notifier);
    final state = ref.watch(campaignEditorControllerProvider(id));

    ref.listen(campaignEditorControllerProvider(id).select((s) => s.phase), (_, phase) {
      if (phase == EditorPhase.saved) {
        ref.invalidate(organizerCampaignProvider(id));
        ref.invalidate(myCampaignsProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.organizerEditSuccess)));
        if (context.canPop()) context.pop();
      }
    });

    final regions = <String?>[null, ...kCampaignRegions];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              _Label(l10n.organizerFieldTitleSo),
              TextField(
                controller: _titleSo,
                maxLength: kTitleMax,
                onChanged: controller.setTitleSo,
                decoration: InputDecoration(
                  errorText: switch (state.titleSoError) {
                    'min' => l10n.organizerFieldTitleTooShort(kTitleMin),
                    'max' => l10n.organizerFieldTitleTooLong(kTitleMax),
                    _ => null,
                  },
                ),
              ),
              const SizedBox(height: 12),
              _Label(l10n.organizerFieldTitleEn),
              TextField(
                controller: _titleEn,
                maxLength: kTitleMax,
                onChanged: controller.setTitleEn,
                decoration: const InputDecoration(counterText: ''),
              ),
              const SizedBox(height: 12),
              _Label(l10n.organizerFieldCategory),
              DropdownButtonFormField<String>(
                initialValue: state.category,
                items: [
                  for (final c in kCampaignCategories)
                    DropdownMenuItem(value: c.value, child: Text(c.label(l10n))),
                ],
                onChanged: (v) => v != null ? controller.setCategory(v) : null,
              ),
              const SizedBox(height: 16),
              _Label(l10n.organizerFieldRegion),
              DropdownButtonFormField<String?>(
                initialValue: regions.contains(state.region) ? state.region : null,
                items: [
                  for (final r in regions)
                    DropdownMenuItem(value: r, child: Text(r ?? l10n.organizerRegionNone)),
                ],
                onChanged: controller.setRegion,
              ),
              const SizedBox(height: 16),
              _Label(l10n.organizerFieldGoal),
              TextField(
                controller: _goal,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                onChanged: controller.setGoal,
                decoration: InputDecoration(
                  prefixText: '${widget.campaign.currency}  ',
                  errorText: state.goalError != null ? l10n.organizerFieldGoalInvalid : null,
                ),
              ),
              const SizedBox(height: 16),
              _Label(l10n.organizerFieldStorySo),
              TextField(
                controller: _storySo,
                minLines: 4,
                maxLines: 10,
                onChanged: controller.setStorySo,
                decoration: InputDecoration(
                  errorText: state.storySoError != null
                      ? l10n.organizerFieldStoryTooShort(kStoryMin)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              _Label(l10n.organizerFieldStoryEn),
              TextField(
                controller: _storyEn,
                minLines: 3,
                maxLines: 8,
                onChanged: controller.setStoryEn,
              ),
              if (state.phase == EditorPhase.error && state.error != null) ...[
                const SizedBox(height: 14),
                Text(presentError(state.error!, l10n),
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
              ],
              const SizedBox(height: 8),
              Text(l10n.organizerEditMediaNote,
                  style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
              label: l10n.organizerSaveChanges,
              isLoading: state.isSaving,
              onPressed: state.isValid ? () => controller.save() : null,
            ),
          ),
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
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}
