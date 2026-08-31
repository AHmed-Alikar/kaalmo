import '../../../core/router/app_routes.dart';
import '../data/models/app_notification.dart';

/// Resolves a backend notification (`type` + a **web** `targetUrl`) to a mobile
/// route, or null when there is no safe in-app destination. Never throws.
///
/// This is the single source of truth for notification navigation — both the
/// in-app notifications list and FCM push taps go through it, so a tapped push
/// lands exactly where the equivalent in-app row would.
///
/// Known backend targetUrls: `/campaigns/:id`, `/organizer`, `/verification`,
/// `/organizer/invites`, `/organizer/withdrawals`, `/support`.
String? resolveNotificationRoute(AppNotification n) =>
    resolveNotificationRouteFrom(type: n.type, targetUrl: n.targetUrl);

/// Same mapping as [resolveNotificationRoute] but from the raw fields carried in
/// an FCM data payload (`data['type']`, `data['targetUrl']`). Never throws.
String? resolveNotificationRouteFrom({String? type, String? targetUrl}) {
  final url = targetUrl?.trim();
  if (url == null || url.isEmpty) return null;

  // /campaigns/:id  → Campaign Details (or Updates for an update notification)
  final campaignMatch = RegExp(r'^/campaigns/([A-Za-z0-9_-]+)/?$').firstMatch(url);
  if (campaignMatch != null) {
    final id = campaignMatch.group(1)!;
    return switch ((type ?? '').toLowerCase()) {
      'campaign_update' => '${AppRoutes.campaign(id)}/updates',
      'campaign_comment' => '${AppRoutes.campaign(id)}/comments',
      _ => AppRoutes.campaign(id),
    };
  }

  return switch (url) {
    '/organizer' => AppRoutes.organizer,
    '/organizer/invites' => AppRoutes.organizerInvites,
    '/verification' => AppRoutes.beneficiary,
    '/support' => AppRoutes.support,
    // No mobile equivalent yet — the tap still marks the notification read, it
    // just falls back to the notifications list. (Withdrawal is deferred.)
    _ => null,
  };
}
