import 'package:flutter/material.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/utils/relative_time.dart';
import '../../data/models/app_notification.dart';
import '../../domain/notification_kind.dart';
import '../../domain/notification_target.dart';

/// One notification row. Unread rows carry a subtle brand-tinted background and
/// a dot; read rows are plain. Colour use is minimal, per the design system.
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final kind = NotificationKind.fromType(notification.type);
    final unread = !notification.read;
    final hasTarget = resolveNotificationRoute(notification) != null;

    return Material(
      color: unread ? kind.accent.withValues(alpha: 0.06) : scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kind.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(kind.icon, size: 19, color: kind.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: kind.accent, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    if (notification.body != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        notification.body!,
                        style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.35),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          formatRelative(notification.createdAt, l10n),
                          style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                        ),
                        if (hasTarget) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right, size: 14, color: scheme.onSurfaceVariant),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
