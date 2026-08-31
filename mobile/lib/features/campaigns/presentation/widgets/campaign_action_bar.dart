import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../domain/campaign_status.dart';

/// Sticky bottom bar: Follow, Save, Share, and the Donate call to action.
///
/// Donate opens `/campaign/:id/donate` when the campaign is open for donations;
/// otherwise it renders disabled as "Donations closed".
class CampaignActionBar extends StatelessWidget {
  const CampaignActionBar({
    super.key,
    required this.status,
    required this.following,
    required this.saved,
    required this.followBusy,
    required this.saveBusy,
    required this.onFollow,
    required this.onSave,
    required this.onShare,
    required this.onDonateTap,
  });

  final CampaignStatusView status;
  final bool following;
  final bool saved;
  final bool followBusy;
  final bool saveBusy;
  final VoidCallback onFollow;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onDonateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final canDonate = status.isOpenForDonations;

    return Material(
      color: scheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              _IconAction(
                icon: saved ? Icons.bookmark : Icons.bookmark_border,
                tooltip: saved ? l10n.saved : l10n.save,
                active: saved,
                busy: saveBusy,
                onTap: onSave,
              ),
              const SizedBox(width: 4),
              _IconAction(
                icon: Icons.ios_share,
                tooltip: l10n.share,
                onTap: onShare,
              ),
              const SizedBox(width: 4),
              _FollowButton(
                following: following,
                busy: followBusy,
                onTap: onFollow,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: canDonate ? onDonateTap : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    disabledBackgroundColor: scheme.surfaceContainerHighest,
                    disabledForegroundColor: scheme.onSurfaceVariant,
                  ),
                  child: Text(
                    canDonate ? l10n.donateComingSoon : l10n.donationsClosed,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: busy ? null : onTap,
      tooltip: tooltip,
      icon: busy
          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2.2))
          : Icon(icon, color: active ? scheme.primary : scheme.onSurfaceVariant),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.busy, required this.onTap});

  final bool following;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final child = busy
        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2.2))
        : Text(following ? l10n.following : l10n.follow,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13));

    return OutlinedButton.icon(
      onPressed: busy ? null : onTap,
      icon: busy ? const SizedBox.shrink() : Icon(following ? Icons.check : Icons.add, size: 16),
      label: child,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
