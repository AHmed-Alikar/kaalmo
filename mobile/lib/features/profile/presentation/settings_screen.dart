import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/error_presenter.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/router/app_routes.dart';
import '../../../shared/buttons/primary_button.dart';

/// `/profile/settings` — account preferences and app info. Only actions the
/// backend supports are shown; account deletion routes to Support (no
/// self-service delete endpoint exists).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _SectionLabel(l10n.settingsPreferences),
            _LanguageTile(currentCode: Localizations.localeOf(context).languageCode),
            _PushTile(enabled: user?.pushEnabled ?? true),

            const SizedBox(height: 18),
            _SectionLabel(l10n.settingsAccount),
            _Tile(
              icon: Icons.badge_outlined,
              label: l10n.settingsEditName,
              subtitle: user?.fullName,
              onTap: () => _showEditName(context, ref, user?.fullName ?? ''),
            ),
            _Tile(
              icon: Icons.lock_reset_outlined,
              label: l10n.settingsChangePassword,
              onTap: () => _changePassword(context, ref),
            ),

            const SizedBox(height: 18),
            _SectionLabel(l10n.settingsApp),
            _Tile(
              icon: Icons.info_outline,
              label: l10n.aboutTitle,
              onTap: () => context.push(AppRoutes.about),
            ),
            _Tile(
              icon: Icons.support_agent_outlined,
              label: l10n.supportTitle,
              onTap: () => context.push(AppRoutes.support),
            ),
            _Tile(
              icon: Icons.no_accounts_outlined,
              label: l10n.settingsCloseAccount,
              onTap: () => context.push('${AppRoutes.supportNew}?subject=${Uri.encodeQueryComponent(l10n.settingsCloseAccountSubject)}'),
            ),

            const SizedBox(height: 24),
            _Tile(
              icon: Icons.logout,
              label: l10n.authLogOut,
              danger: true,
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditName(BuildContext context, WidgetRef ref, String current) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _EditNameSheet(initial: current),
      ),
    );
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(l10n.settingsChangePassword),
        content: Text(l10n.settingsChangePasswordBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dc).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dc).pop(true), child: Text(l10n.actionContinue)),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authControllerProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.forgotPassword);
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dc).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dc).pop(true), child: Text(l10n.authLogOut)),
        ],
      ),
    );
    if (ok == true) await ref.read(authControllerProvider.notifier).logout();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? scheme.error : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(label,
              style: TextStyle(fontWeight: FontWeight.w600, color: danger ? scheme.error : null)),
          subtitle: subtitle != null && subtitle!.isNotEmpty
              ? Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
          trailing: danger ? null : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.currentCode});
  final String currentCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(Icons.translate, color: scheme.primary),
          title: Text(l10n.settingsLanguage, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(currentCode == 'en' ? l10n.languageEnglish : l10n.languageSomali,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          trailing: SegmentedButton<String>(
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: 'so', label: Text('SO')),
              ButtonSegment(value: 'en', label: Text('EN')),
            ],
            selected: {currentCode == 'en' ? 'en' : 'so'},
            onSelectionChanged: (s) => _setLanguage(context, ref, s.first),
          ),
        ),
      ),
    );
  }

  Future<void> _setLanguage(BuildContext context, WidgetRef ref, String code) async {
    await ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
    // Best-effort backend sync — never blocks the UI.
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(language: code);
    } catch (_) {/* local choice already applied */}
  }
}

class _PushTile extends ConsumerStatefulWidget {
  const _PushTile({required this.enabled});
  final bool enabled;

  @override
  ConsumerState<_PushTile> createState() => _PushTileState();
}

class _PushTileState extends ConsumerState<_PushTile> {
  late bool _value = widget.enabled;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile.adaptive(
          secondary: Icon(Icons.notifications_active_outlined, color: scheme.primary),
          title: Text(l10n.settingsPushNotifications, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(l10n.settingsPushNotificationsNote,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          value: _value,
          onChanged: _busy ? null : _toggle,
        ),
      ),
    );
  }

  Future<void> _toggle(bool v) async {
    setState(() {
      _value = v;
      _busy = true;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(pushEnabled: v);
    } catch (e) {
      if (mounted) {
        setState(() => _value = !v);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(presentError(e, context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _EditNameSheet extends ConsumerStatefulWidget {
  const _EditNameSheet({required this.initial});
  final String initial;

  @override
  ConsumerState<_EditNameSheet> createState() => _EditNameSheetState();
}

class _EditNameSheetState extends ConsumerState<_EditNameSheet> {
  late final _ctrl = TextEditingController(text: widget.initial);
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _valid => _ctrl.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsEditName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(labelText: l10n.settingsFullName),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(presentError(_error!, l10n),
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: l10n.settingsSave,
              isLoading: _busy,
              onPressed: _valid && !_busy ? _save : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(fullName: _ctrl.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.settingsNameUpdated)));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
