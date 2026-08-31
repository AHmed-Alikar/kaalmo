import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/auth/logout_action.dart';

/// The Profile tab. Minimal for now — an identity header and the entry point
/// to My Donations. Other sections arrive in later phases.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProfile),
        actions: const [LogoutAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: scheme.primary.withValues(alpha: 0.12),
                      child: Text(
                        _initials(user.fullName),
                        style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName.trim().isEmpty ? user.email : user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            _ProfileTile(
              icon: Icons.favorite_outline,
              label: l10n.myDonationsTitle,
              onTap: () => context.push(AppRoutes.myDonations),
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.notifications_none,
              label: l10n.notificationsTitle,
              onTap: () => context.push(AppRoutes.notifications),
            ),
            const SizedBox(height: 10),
            if (user?.isOrganizer ?? false) ...[
              _ProfileTile(
                icon: Icons.campaign_outlined,
                label: l10n.organizerDashboardTitle,
                onTap: () => context.push(AppRoutes.organizer),
              ),
              const SizedBox(height: 10),
            ],
            _ProfileTile(
              icon: Icons.verified_user_outlined,
              label: l10n.beneficiaryDashboardTitle,
              onTap: () => context.push(AppRoutes.beneficiary),
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.mark_email_read_outlined,
              label: l10n.invitesTitle,
              onTap: () => context.push(AppRoutes.organizerInvites),
            ),
            const SizedBox(height: 10),
            _ProfileTile(
              icon: Icons.settings_outlined,
              label: l10n.settingsTitle,
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
