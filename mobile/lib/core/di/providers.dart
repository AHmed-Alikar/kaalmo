import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/application/auth_state.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/campaigns/application/campaign_comments_controller.dart';
import '../../features/campaigns/application/campaign_detail_controller.dart';
import '../../features/campaigns/application/campaign_detail_state.dart';
import '../../features/campaigns/application/explore_controller.dart';
import '../../features/campaigns/application/explore_state.dart';
import '../../features/campaigns/data/campaign_api.dart';
import '../../features/campaigns/data/campaign_repository.dart';
import '../../features/campaigns/data/models/campaign_update.dart';
import '../../features/campaigns/data/models/platform_stats.dart';
import '../../features/campaigns/data/models/supporter.dart';
import '../../features/donations/application/donate_controller.dart';
import '../../features/donations/application/donate_state.dart';
import '../../features/donations/data/donation_api.dart';
import '../../features/donations/data/donation_repository.dart';
import '../../features/donations/data/models/my_donation.dart';
import '../../features/donations/data/models/payment_config.dart';
import '../../features/beneficiary/application/beneficiary_controllers.dart';
import '../../features/beneficiary/data/beneficiary_api.dart';
import '../../features/beneficiary/data/beneficiary_repository.dart';
import '../../features/beneficiary/data/models/beneficiary_profile.dart';
import '../../features/beneficiary/data/models/payout_account.dart';
import '../../features/organizer/application/campaign_editor_controller.dart';
import '../../features/organizer/application/campaign_editor_state.dart';
import '../../features/organizer/application/campaign_manage_controller.dart';
import '../../features/organizer/application/post_update_controller.dart';
import '../../features/organizer/data/models/campaign_invite.dart';
import '../../features/organizer/data/models/campaign_member_info.dart';
import '../../features/organizer/data/organizer_api.dart';
import '../../features/organizer/data/organizer_repository.dart';
import '../../features/support/application/support_controllers.dart';
import '../../features/support/data/models/support_ticket.dart';
import '../../features/support/data/support_api.dart';
import '../../features/support/data/support_repository.dart';
import '../../features/campaigns/data/models/campaign.dart';
import '../../features/home/application/home_feed.dart';
import '../../features/notifications/application/device_registrar.dart';
import '../../features/notifications/application/notifications_controller.dart';
import '../../features/notifications/data/device_api.dart';
import '../../features/notifications/data/notification_api.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../config/app_config.dart';
import '../localization/locale_controller.dart';
import '../network/api_client.dart';
import '../network/auth_events.dart';
import '../network/auth_interceptor.dart';
import '../network/token_refresher.dart';
import '../push/fcm_push_service.dart';
import '../push/push_notification_service.dart';
import '../push/push_service.dart';
import '../share/share_service.dart';
import '../storage/secure_token_store.dart';

/// Overridden in `main()` with the resolved config.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw StateError('appConfigProvider must be overridden in main()');
});

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) => SecureTokenStore());

/// Session-lifecycle event bus. Decouples the network layer (emits
/// "session expired") from [AuthController] (reacts) so there is no provider
/// cycle.
final authEventsProvider = Provider<AuthEvents>((ref) {
  final events = AuthEvents();
  ref.onDispose(events.dispose);
  return events;
});

final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => TokenRefresher(ref.watch(secureTokenStoreProvider), ref.watch(appConfigProvider)),
);

/// The Dio-backed API client, wired with the auth interceptor.
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(appConfigProvider);
  final store = ref.watch(secureTokenStoreProvider);
  final refresher = ref.watch(tokenRefresherProvider);
  final events = ref.watch(authEventsProvider);

  return ApiClient.create(
    config: config,
    buildAuthInterceptor: (self) => AuthInterceptor(
      store,
      refresher.refresh,
      events.notifySessionExpired,
      self,
    ),
  );
});

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(authApiProvider), ref.watch(secureTokenStoreProvider)),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(ref.watch(authRepositoryProvider));
  final sub = ref
      .watch(authEventsProvider)
      .onSessionExpired
      .listen((_) => controller.markSessionExpired());
  ref.onDispose(sub.cancel);
  return controller;
});

final localeControllerProvider = StateNotifierProvider<LocaleController, Locale?>(
  (ref) => LocaleController(ref.watch(secureTokenStoreProvider)),
);

/// Firebase Cloud Messaging. Falls back to a no-op at runtime when Firebase is
/// not configured on the device (no `google-services.json`).
final pushServiceProvider = Provider<PushService>((ref) => FcmPushService());

final deviceApiProvider = Provider<DeviceApi>((ref) => DeviceApi(ref.watch(apiClientProvider)));

/// Owns the push lifecycle — SDK init, token registration across the session,
/// permission prompt, and notification-tap routing. Started once in `KaalmoApp`.
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final service = PushNotificationService(ref);
  ref.onDispose(service.dispose);
  return service;
});

// --- In-app notifications ---

final notificationApiProvider =
    Provider<NotificationApi>((ref) => NotificationApi(ref.watch(apiClientProvider)));

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(ref.watch(notificationApiProvider)),
);

/// Session-scoped (not autoDispose) so the Home bell badge and the
/// notifications screen share one feed and one initial fetch. Reset when the
/// session ends.
final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  final authed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
  return NotificationsController(ref.watch(notificationRepositoryProvider), autoLoad: authed);
});

// --- Support tickets ---

final supportApiProvider = Provider<SupportApi>((ref) => SupportApi(ref.watch(apiClientProvider)));

final supportRepositoryProvider =
    Provider<SupportRepository>((ref) => SupportRepository(ref.watch(supportApiProvider)));

final myTicketsProvider = FutureProvider.autoDispose<List<SupportTicket>>(
  (ref) => ref.watch(supportRepositoryProvider).myTickets(),
);

final supportTicketProvider = FutureProvider.autoDispose.family<SupportTicket, String>(
  (ref, id) => ref.watch(supportRepositoryProvider).getTicket(id),
);

final newTicketControllerProvider =
    StateNotifierProvider.autoDispose<NewTicketController, NewTicketState>(
  (ref) => NewTicketController(ref.watch(supportRepositoryProvider)),
);

final ticketReplyControllerProvider = StateNotifierProvider.autoDispose
    .family<TicketReplyController, TicketReplyState, String>(
  (ref, id) => TicketReplyController(ref.watch(supportRepositoryProvider), id),
);

// --- Co-organizer invitations ---

final campaignInvitesProvider = FutureProvider.autoDispose<List<CampaignInvite>>(
  (ref) => ref.watch(organizerRepositoryProvider).myInvites(),
);

// --- Campaign discovery (Home + Explore) ---

final campaignApiProvider = Provider<CampaignApi>((ref) => CampaignApi(ref.watch(apiClientProvider)));

final campaignRepositoryProvider = Provider<CampaignRepository>(
  (ref) => CampaignRepository(ref.watch(campaignApiProvider), ref.watch(appConfigProvider)),
);

/// One fetch: newest public campaigns (for Featured + Recent) plus platform
/// stats. Pull-to-refresh invalidates this. A stats failure is non-fatal —
/// the campaign list still renders.
final homeFeedProvider = FutureProvider<HomeFeed>((ref) async {
  final repo = ref.watch(campaignRepositoryProvider);
  final pageFuture = repo.list(page: 1, limit: 15);
  final statsFuture = repo.stats().then<PlatformStats?>((s) => s).catchError((_) => null);
  final page = await pageFuture;
  final stats = await statsFuture;
  return HomeFeed(campaigns: page.items, stats: stats);
});

final exploreControllerProvider =
    StateNotifierProvider<ExploreController, ExploreState>(
  (ref) => ExploreController(ref.watch(campaignRepositoryProvider)),
);

// --- Campaign detail experience ---

/// One controller per campaign id, auth-aware (rebuilds if the auth boolean
/// flips, e.g. after login-required → login → back).
final campaignDetailControllerProvider = StateNotifierProvider.autoDispose
    .family<CampaignDetailController, CampaignDetailState, String>((ref, id) {
  final isAuthed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
  final controller = CampaignDetailController(ref.watch(campaignRepositoryProvider), id, isAuthed);
  controller.load();
  return controller;
});

/// Read-only updates list — shared by the detail preview (take a few) and the
/// full updates screen, so it's fetched once.
final campaignUpdatesProvider =
    FutureProvider.autoDispose.family<List<CampaignUpdate>, String>((ref, id) {
  return ref.watch(campaignRepositoryProvider).getUpdates(id);
});

/// Read-only recent supporters + total count — shared by the detail block and
/// the supporters screen.
final campaignSupportersProvider =
    FutureProvider.autoDispose.family<SupporterList, String>((ref, id) {
  return ref.watch(campaignRepositoryProvider).getSupporters(id);
});

final campaignCommentsControllerProvider = StateNotifierProvider.autoDispose
    .family<CampaignCommentsController, CommentsState, String>((ref, id) {
  final controller = CampaignCommentsController(ref.watch(campaignRepositoryProvider), id);
  controller.load();
  return controller;
});

final shareServiceProvider = Provider<ShareService>((ref) => const SharePlusService());

// --- Donation + payment ---

final donationApiProvider = Provider<DonationApi>((ref) => DonationApi(ref.watch(apiClientProvider)));

final donationRepositoryProvider = Provider<DonationRepository>(
  (ref) => DonationRepository(ref.watch(donationApiProvider), ref.watch(appConfigProvider)),
);

/// The signed-in donor's history. autoDispose so it re-fetches on re-entry;
/// pull-to-refresh invalidates it.
final myDonationsProvider = FutureProvider.autoDispose<List<MyDonation>>(
  (ref) => ref.watch(donationRepositoryProvider).getMyDonations(),
);

/// Looks one donation up in the already-loaded history — the backend has no
/// per-donation endpoint, so the detail screen reads from the list.
final myDonationByIdProvider = Provider.autoDispose.family<MyDonation?, String>((ref, id) {
  final list = ref.watch(myDonationsProvider).valueOrNull;
  if (list == null) return null;
  for (final d in list) {
    if (d.id == id) return d;
  }
  return null;
});

/// Cached payment-method configuration (`GET /payments/config`). Kept alive so
/// the picker is instant on re-entry; invalidate to re-check.
final paymentConfigProvider = FutureProvider<PaymentConfig>(
  (ref) => ref.watch(donationRepositoryProvider).getPaymentConfig(),
);

/// One donation flow per campaign id, auth-aware.
final donateControllerProvider = StateNotifierProvider.autoDispose
    .family<DonateController, DonateState, String>((ref, id) {
  final isAuthed = ref.watch(authControllerProvider.select((s) => s.isAuthenticated));
  return DonateController(ref.watch(donationRepositoryProvider), id, isAuthed);
});

final deviceRegistrarProvider = Provider<DeviceRegistrar>((ref) {
  final registrar = DeviceRegistrar(
    ref.watch(pushServiceProvider),
    ref.watch(deviceApiProvider),
  );
  ref.onDispose(registrar.dispose);
  return registrar;
});

// --- Organizer ---

final organizerApiProvider = Provider<OrganizerApi>((ref) => OrganizerApi(ref.watch(apiClientProvider)));

final organizerRepositoryProvider = Provider<OrganizerRepository>(
  (ref) => OrganizerRepository(ref.watch(organizerApiProvider), ref.watch(appConfigProvider)),
);

/// The organizer's campaigns (owned + accepted co-organized), newest-first, no
/// pagination. autoDispose + pull-to-refresh invalidates.
final myCampaignsProvider = FutureProvider.autoDispose<List<Campaign>>(
  (ref) => ref.watch(organizerRepositoryProvider).myCampaigns(),
);

/// A single campaign for the manage screen. `GET /campaigns/:id` returns the
/// full doc to the owner / co-organizer even while it is not public.
final organizerCampaignProvider = FutureProvider.autoDispose.family<Campaign, String>(
  (ref, id) => ref.watch(campaignRepositoryProvider).getCampaign(id),
);

/// Team list for a campaign (organizer-only on the backend).
final campaignMembersProvider = FutureProvider.autoDispose.family<List<CampaignMemberInfo>, String>(
  (ref, id) => ref.watch(organizerRepositoryProvider).campaignMembers(id),
);

final campaignManageControllerProvider = StateNotifierProvider.autoDispose
    .family<CampaignManageController, CampaignManageState, String>(
  (ref, id) => CampaignManageController(ref.watch(organizerRepositoryProvider), id),
);

final campaignEditorControllerProvider = StateNotifierProvider.autoDispose
    .family<CampaignEditorController, CampaignEditorState, String>((ref, id) {
  final controller = CampaignEditorController(ref.watch(organizerRepositoryProvider), id);
  // The editor screen only mounts after `organizerCampaignProvider(id)` has
  // data, so seed the form from it here (outside any widget build).
  final campaign = ref.read(organizerCampaignProvider(id)).valueOrNull;
  if (campaign != null) controller.hydrate(campaign);
  return controller;
});

final postUpdateControllerProvider = StateNotifierProvider.autoDispose
    .family<PostUpdateController, PostUpdateState, String>(
  (ref, id) => PostUpdateController(ref.watch(organizerRepositoryProvider), id),
);

// --- Beneficiary + payout ---

final beneficiaryApiProvider = Provider<BeneficiaryApi>((ref) => BeneficiaryApi(ref.watch(apiClientProvider)));

final beneficiaryRepositoryProvider =
    Provider<BeneficiaryRepository>((ref) => BeneficiaryRepository(ref.watch(beneficiaryApiProvider)));

/// The caller's beneficiary profile, or `null` when never submitted (404).
final beneficiaryProfileProvider = FutureProvider.autoDispose<BeneficiaryProfile?>(
  (ref) => ref.watch(beneficiaryRepositoryProvider).getMyProfile(),
);

final payoutAccountsProvider = FutureProvider.autoDispose<List<PayoutAccount>>(
  (ref) => ref.watch(beneficiaryRepositoryProvider).myPayoutAccounts(),
);

final beneficiaryIdentityControllerProvider = StateNotifierProvider.autoDispose
    .family<BeneficiaryIdentityController, BeneficiaryIdentityState, String>(
  (ref, initialName) =>
      BeneficiaryIdentityController(ref.watch(beneficiaryRepositoryProvider), initialName: initialName),
);

final payoutAccountFormControllerProvider =
    StateNotifierProvider.autoDispose<PayoutAccountFormController, PayoutAccountFormState>(
  (ref) => PayoutAccountFormController(ref.watch(beneficiaryRepositoryProvider)),
);
