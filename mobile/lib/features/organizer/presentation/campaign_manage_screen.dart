import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/states/state_views.dart';
import '../../../shared/widgets/app_progress_bar.dart';
import '../../../shared/widgets/network_image_box.dart';
import '../../campaigns/data/models/campaign.dart';
import '../../campaigns/domain/campaign_status.dart';
import '../../campaigns/presentation/widgets/campaign_status_pill.dart';
import '../domain/campaign_lifecycle.dart';

/// `/organizer/campaign/:id` — manage one campaign: edit, submit, cancel,
/// delete, post an update, view the public page. Only actions the backend
/// lifecycle permits for the current status are shown.
class CampaignManageScreen extends ConsumerWidget {
  const CampaignManageScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final campaign = ref.watch(organizerCampaignProvider(campaignId));
    final myId = ref.watch(authControllerProvider.select((s) => s.user?.id));

    ref.listen(campaignManageControllerProvider(campaignId).select((s) => s.error), (_, err) {
      if (err != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(presentError(err, l10n))));
        ref.read(campaignManageControllerProvider(campaignId).notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.organizerManageTitle)),
      body: SafeArea(
        child: campaign.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.campaignLoadErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(organizerCampaignProvider(campaignId)),
          ),
          data: (c) => _Content(campaign: c, isOwner: c.organizerId != null && c.organizerId == myId),
        ),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.campaign, required this.isOwner});

  final Campaign campaign;
  final bool isOwner;

  Future<bool> _confirm(BuildContext context, {required String title, required String body, required String confirmLabel, bool destructive = false}) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.of(dc).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(
            style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(dc).colorScheme.error) : null,
            onPressed: () => Navigator.of(dc).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final id = campaign.id;
    final status = CampaignStatusView.from(campaign.status);
    final actions = CampaignActionSet.forCampaign(campaign, isOwner: isOwner);
    final manage = ref.watch(campaignManageControllerProvider(id));
    final controller = ref.read(campaignManageControllerProvider(id).notifier);

    Future<void> refresh() async {
      ref.invalidate(organizerCampaignProvider(id));
      ref.invalidate(myCampaignsProvider);
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: NetworkImageBox(url: campaign.coverImageUrl, cacheWidth: 200),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.titleFor(lang),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    CampaignStatusPill(status: status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AppProgressBar(
            raised: campaign.raisedAmount,
            goal: campaign.goalAmount,
            currency: campaign.currency,
          ),
          const SizedBox(height: 18),

          if (status == CampaignStatusView.rejected)
            _Note(
              icon: Icons.info_outline,
              tone: scheme.error,
              text: l10n.organizerRejectedNote,
            ),
          if (actions.canEdit && actions.editReturnsToReview)
            _Note(
              icon: Icons.rate_review_outlined,
              tone: AppColors.warning,
              text: l10n.organizerEditReturnsToReview,
            ),

          const SizedBox(height: 8),
          Text(l10n.organizerActions,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          if (actions.canEdit)
            _ActionButton(
              icon: Icons.edit_outlined,
              label: l10n.organizerActionEdit,
              onTap: () => context.push(AppRoutes.organizerCampaignEdit(id)),
            ),
          if (actions.canPostUpdate)
            _ActionButton(
              icon: Icons.post_add_outlined,
              label: l10n.organizerActionPostUpdate,
              onTap: () => context.push(AppRoutes.organizerCampaignUpdate(id)),
            ),
          if (actions.canViewPublic)
            _ActionButton(
              icon: Icons.open_in_new,
              label: l10n.organizerActionViewPublic,
              onTap: () => context.push(AppRoutes.campaign(id)),
            ),
          if (actions.canSubmit)
            _ActionButton(
              icon: Icons.send_outlined,
              label: l10n.organizerActionSubmit,
              busy: manage.busy,
              primary: true,
              onTap: () async {
                final ok = await _confirm(context,
                    title: l10n.organizerSubmitConfirmTitle,
                    body: l10n.organizerSubmitConfirmBody,
                    confirmLabel: l10n.organizerActionSubmit);
                if (!ok) return;
                if (await controller.submit()) {
                  await refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.organizerSubmitSuccess)));
                  }
                }
              },
            ),
          if (actions.canCancel)
            _ActionButton(
              icon: Icons.block_outlined,
              label: l10n.organizerActionCancel,
              destructive: true,
              busy: manage.busy,
              onTap: () async {
                final ok = await _confirm(context,
                    title: l10n.organizerCancelConfirmTitle,
                    body: l10n.organizerCancelConfirmBody,
                    confirmLabel: l10n.organizerActionCancel,
                    destructive: true);
                if (!ok) return;
                if (await controller.cancel()) {
                  await refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(l10n.organizerCancelSuccess)));
                  }
                }
              },
            ),
          if (actions.canDelete)
            _ActionButton(
              icon: Icons.delete_outline,
              label: l10n.organizerActionDelete,
              destructive: true,
              busy: manage.busy,
              onTap: () async {
                final ok = await _confirm(context,
                    title: l10n.organizerDeleteConfirmTitle,
                    body: l10n.organizerDeleteConfirmBody,
                    confirmLabel: l10n.organizerActionDelete,
                    destructive: true);
                if (!ok) return;
                if (await controller.deleteDraft()) {
                  ref.invalidate(myCampaignsProvider);
                  if (context.mounted) context.pop();
                }
              },
            ),

          const SizedBox(height: 24),
          _BeneficiarySection(hasBeneficiary: (campaign.beneficiaryId ?? '').isNotEmpty),
          if (isOwner) ...[
            const SizedBox(height: 20),
            _TeamSection(campaignId: id),
          ],
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.tone, required this.text});

  final IconData icon;
  final Color tone;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tone.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: tone, height: 1.35))),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
    this.primary = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool busy;
  final bool primary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : (primary ? scheme.primary : scheme.onSurface);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: primary ? scheme.primary.withValues(alpha: 0.08) : scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: primary ? scheme.primary.withValues(alpha: 0.3) : scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: busy
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
              : Icon(icon, color: color),
          title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          trailing: const Icon(Icons.chevron_right),
          onTap: busy ? null : onTap,
        ),
      ),
    );
  }
}

class _BeneficiarySection extends StatelessWidget {
  const _BeneficiarySection({required this.hasBeneficiary});

  final bool hasBeneficiary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.organizerBeneficiary,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(hasBeneficiary ? Icons.verified_user_outlined : Icons.person_off_outlined,
                  size: 18, color: hasBeneficiary ? scheme.primary : scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasBeneficiary ? l10n.organizerBeneficiaryLinked : l10n.organizerBeneficiaryNone,
                  style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamSection extends ConsumerWidget {
  const _TeamSection({required this.campaignId});

  final String campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final members = ref.watch(campaignMembersProvider(campaignId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.organizerTeam,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        members.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          error: (_, _) => Text(l10n.organizerTeamLoadError,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          data: (list) {
            if (list.isEmpty) {
              return Text(l10n.organizerTeamEmpty,
                  style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant));
            }
            return Column(
              children: [
                for (final m in list)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
                    title: Text(m.inviteEmail, style: const TextStyle(fontSize: 13)),
                    trailing: Text(
                      m.isAccepted ? l10n.organizerTeamAccepted : l10n.organizerTeamPending,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
