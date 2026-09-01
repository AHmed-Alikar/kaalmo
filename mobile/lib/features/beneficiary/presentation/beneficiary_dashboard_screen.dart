import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/states/state_views.dart';
import '../../auth/data/models/auth_user.dart';
import '../data/models/beneficiary_profile.dart';
import 'widgets/beneficiary_forms.dart';
import 'widgets/verification_checklist.dart';

/// `/beneficiary` — the beneficiary's own space, deliberately separate from the
/// organizer dashboard. It only covers the beneficiary lifecycle: accept a
/// campaign invitation, submit verification, and see the admin's decision.
/// Payout accounts are linked by the Kaalmo team and are not shown here.
class BeneficiaryDashboardScreen extends ConsumerWidget {
  const BeneficiaryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final profile = ref.watch(beneficiaryProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.beneficiaryDashboardTitle)),
      body: SafeArea(
        child: profile.when(
          loading: () => const LoadingView(),
          error: (err, _) => ErrorView(
            title: l10n.beneficiaryLoadErrorTitle,
            message: presentError(err, l10n),
            onRetry: () => ref.invalidate(beneficiaryProfileProvider),
          ),
          data: (p) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(beneficiaryProfileProvider),
            child: _Body(user: user, profile: p),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.user, required this.profile});

  final AuthUser? user;
  final BeneficiaryProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final beneficiaryVerified = profile?.isVerified ?? false;
    final beneficiaryPending = profile?.isPending ?? false;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const _RoleBanner(),
        const SizedBox(height: 16),
        const _InvitesCard(),
        _IdentityCard(profile: profile, fallbackName: user?.fullName ?? ''),
        const SizedBox(height: 16),
        VerificationChecklist(items: [
          VerificationItem(label: l10n.beneficiaryCheckEmail, done: user?.emailVerified ?? false),
          VerificationItem(label: l10n.beneficiaryCheckPhone, done: user?.phoneVerified ?? false),
          VerificationItem(label: l10n.beneficiaryCheckIdentity, done: user?.identityVerified ?? false),
          VerificationItem(
            label: l10n.beneficiaryCheckBeneficiary,
            done: beneficiaryVerified,
            pending: beneficiaryPending,
          ),
        ]),
        const SizedBox(height: 20),
        _NextStep(profile: profile),
      ],
    );
  }
}

/// Makes it unmistakable which account the user is looking at — a beneficiary
/// is not an organizer and never sees the organizer dashboard here.
class _RoleBanner extends StatelessWidget {
  const _RoleBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.volunteer_activism_outlined, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.beneficiaryAccountBanner,
              style: TextStyle(fontSize: 12, color: scheme.primary, height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile, required this.fallbackName});

  final BeneficiaryProfile? profile;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final status = profile?.statusView ?? BeneficiaryStatusView.none;
    final name = (profile?.fullName.trim().isNotEmpty ?? false) ? profile!.fullName : fallbackName;
    final lang = Localizations.localeOf(context).languageCode;
    final campaign = profile?.campaignTitle;
    final campaignName = campaign != null
        ? '${campaign[lang] ?? campaign['so'] ?? campaign['en'] ?? ''}'
        : '';

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.icon, color: status.color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? l10n.beneficiaryNoName : name,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(status.label(l10n),
                        style: TextStyle(fontSize: 12.5, color: status.color, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          if (campaignName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('${l10n.beneficiaryForCampaignLabel}: $campaignName',
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          ],
          if ((profile?.isRejected ?? false) || (profile?.needsMoreInfo ?? false)) ...[
            const SizedBox(height: 10),
            Text(
              profile?.reviewNote ??
                  (profile!.needsMoreInfo ? l10n.beneficiaryNeedsInfoNote : l10n.beneficiaryRejectedNote),
              style: TextStyle(
                fontSize: 12.5,
                color: profile!.needsMoreInfo ? AppColors.warning : scheme.error,
              ),
            ),
          ],
          if (profile?.isPending ?? false) ...[
            const SizedBox(height: 10),
            Text(l10n.beneficiaryPendingNote,
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          ],
          if ((profile == null || profile!.canSubmit) && !(profile?.isVerified ?? false)) ...[
            const SizedBox(height: 14),
            PrimaryButton(
              label: (status == BeneficiaryStatusView.none)
                  ? l10n.beneficiaryStartVerification
                  : l10n.beneficiaryUpdateIdentity,
              onPressed: () => showBeneficiaryIdentitySheet(context, initialName: name),
            ),
          ],
        ],
      ),
    );
  }
}

/// A single, non-payout "what happens next" line driven straight off the
/// backend status — never contradicts the status shown above.
class _NextStep extends StatelessWidget {
  const _NextStep({required this.profile});

  final BeneficiaryProfile? profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final status = profile?.statusView ?? BeneficiaryStatusView.none;
    final (String text, Color color, IconData icon) = switch (status) {
      BeneficiaryStatusView.verified => (l10n.beneficiaryNextVerified, AppColors.success, Icons.verified),
      BeneficiaryStatusView.pending => (l10n.beneficiaryNextPending, AppColors.warning, Icons.hourglass_bottom),
      BeneficiaryStatusView.accepted => (l10n.beneficiaryNextAccepted, AppColors.info, Icons.assignment_outlined),
      BeneficiaryStatusView.invited => (l10n.beneficiaryNextInvited, AppColors.info, Icons.mark_email_unread_outlined),
      BeneficiaryStatusView.rejected => (l10n.beneficiaryNextRejected, AppColors.error, Icons.replay_outlined),
      BeneficiaryStatusView.needsMoreInfo => (l10n.beneficiaryNextRejected, AppColors.warning, Icons.replay_outlined),
      BeneficiaryStatusView.none => (l10n.beneficiaryNextNone, AppColors.textSecondary, Icons.info_outline),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.5, color: color, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

/// Pending beneficiary invitations — an organizer named this user as the
/// beneficiary for a campaign. Accepting only records consent; verification is
/// still required and reviewed by an admin.
class _InvitesCard extends ConsumerWidget {
  const _InvitesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final invites = ref.watch(beneficiaryInvitesProvider).valueOrNull ?? const [];
    if (invites.isEmpty) return const SizedBox.shrink();

    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.beneficiaryInvitesTitle,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          for (final inv in invites) ...[
            const SizedBox(height: 10),
            Text(
              inv.campaignTitle != null
                  ? '${inv.campaignTitle![lang] ?? inv.campaignTitle!['so'] ?? inv.campaignTitle!['en']}'
                  : l10n.beneficiaryInviteGeneric,
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: l10n.beneficiaryInviteAccept,
              onPressed: () async {
                try {
                  await ref.read(beneficiaryRepositoryProvider).acceptInvite(inv.id);
                  ref.invalidate(beneficiaryInvitesProvider);
                  ref.invalidate(beneficiaryProfileProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.beneficiaryInviteAccepted)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(presentError(e, l10n))));
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
