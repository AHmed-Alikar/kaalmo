import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/buttons/primary_button.dart';
import '../../../shared/buttons/secondary_button.dart';
import '../../../shared/states/state_views.dart';
import '../../auth/data/models/auth_user.dart';
import '../data/models/beneficiary_profile.dart';
import '../data/models/payout_account.dart';
import 'widgets/beneficiary_forms.dart';
import 'widgets/verification_checklist.dart';

/// `/beneficiary` — the beneficiary's home: identity + verification state and
/// payout readiness. Any authenticated user can start a beneficiary profile
/// (the backend gates on `requireAuth`, not a role).
class BeneficiaryDashboardScreen extends ConsumerWidget {
  const BeneficiaryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final profile = ref.watch(beneficiaryProfileProvider);
    final accounts = ref.watch(payoutAccountsProvider);

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
            onRefresh: () async {
              ref.invalidate(beneficiaryProfileProvider);
              ref.invalidate(payoutAccountsProvider);
            },
            child: _Body(
              user: user,
              profile: p,
              accounts: accounts.valueOrNull ?? const [],
              accountsLoading: accounts.isLoading,
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.user,
    required this.profile,
    required this.accounts,
    required this.accountsLoading,
  });

  final AuthUser? user;
  final BeneficiaryProfile? profile;
  final List<PayoutAccount> accounts;
  final bool accountsLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final beneficiaryVerified = profile?.isVerified ?? false;
    final beneficiaryPending = profile?.isPending ?? false;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
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
        _PayoutSection(accounts: accounts, loading: accountsLoading),
        const SizedBox(height: 20),
        _ReadinessBanner(profile: profile, hasAnyAccount: accounts.isNotEmpty),
        const SizedBox(height: 16),
        const _LinkageNote(),
      ],
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
          if (profile?.isRejected ?? false) ...[
            const SizedBox(height: 10),
            Text(l10n.beneficiaryRejectedNote,
                style: TextStyle(fontSize: 12.5, color: scheme.error)),
          ],
          if (profile?.isPending ?? false) ...[
            const SizedBox(height: 10),
            Text(l10n.beneficiaryPendingNote,
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          ],
          if (!(profile?.isVerified ?? false)) ...[
            const SizedBox(height: 14),
            PrimaryButton(
              label: status == BeneficiaryStatusView.none
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

class _PayoutSection extends StatelessWidget {
  const _PayoutSection({required this.accounts, required this.loading});

  final List<PayoutAccount> accounts;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.beneficiaryPayoutTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))),
          )
        else if (accounts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(l10n.beneficiaryNoPayoutAccount,
                style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
          )
        else
          for (final a in accounts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(a.type == 'bank' ? Icons.account_balance_outlined : Icons.smartphone_outlined,
                        size: 18, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${a.providerName} · ${a.accountNumberMasked}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(
                            a.verified ? l10n.beneficiaryPayoutVerified : l10n.beneficiaryPayoutUnverified,
                            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 8),
        SecondaryButton(
          label: l10n.beneficiaryAddPayoutButton,
          onPressed: () => showPayoutAccountSheet(context),
        ),
      ],
    );
  }
}

class _ReadinessBanner extends StatelessWidget {
  const _ReadinessBanner({required this.profile, required this.hasAnyAccount});

  final BeneficiaryProfile? profile;
  final bool hasAnyAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ready = profile?.payoutReady ?? false;
    final color = ready ? AppColors.success : AppColors.warning;
    final message = ready
        ? l10n.beneficiaryReadyBody
        : (profile?.isVerified ?? false)
            ? l10n.beneficiaryNotReadyLinkage
            : l10n.beneficiaryNotReadyVerify;

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
          Icon(ready ? Icons.verified : Icons.pending_actions, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ready ? l10n.beneficiaryReadyTitle : l10n.beneficiaryNotReadyTitle,
                    style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
                const SizedBox(height: 2),
                Text(message, style: TextStyle(fontSize: 12, color: color, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkageNote extends StatelessWidget {
  const _LinkageNote();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Text(
      l10n.beneficiaryCampaignLinkNote,
      style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant, height: 1.4),
    );
  }
}
