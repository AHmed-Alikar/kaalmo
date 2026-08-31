import 'dart:async';

import 'package:dio/dio.dart';

import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/features/auth/data/auth_repository.dart';
import 'package:kaalmo_mobile/features/auth/data/models/auth_user.dart';
import 'package:kaalmo_mobile/features/campaigns/data/campaign_repository.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_comment.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_interactions.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_update.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/platform_stats.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/features/donations/data/donation_repository.dart';
import 'package:kaalmo_mobile/features/donations/data/models/donation_result.dart';
import 'package:kaalmo_mobile/features/donations/data/models/my_donation.dart';
import 'package:kaalmo_mobile/features/donations/data/models/payment_config.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/beneficiary_repository.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/models/beneficiary_profile.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/models/payout_account.dart';
import 'package:kaalmo_mobile/features/organizer/data/models/campaign_invite.dart';
import 'package:kaalmo_mobile/features/organizer/data/models/campaign_member_info.dart';
import 'package:kaalmo_mobile/features/organizer/data/organizer_repository.dart';
import 'package:kaalmo_mobile/core/push/push_message.dart';
import 'package:kaalmo_mobile/core/push/push_service.dart';
import 'package:kaalmo_mobile/features/notifications/data/device_api.dart';
import 'package:kaalmo_mobile/features/notifications/data/models/app_notification.dart';
import 'package:kaalmo_mobile/features/notifications/data/notification_repository.dart';
import 'package:kaalmo_mobile/features/support/data/models/support_ticket.dart';
import 'package:kaalmo_mobile/features/support/data/support_repository.dart';

AuthUser fakeUser({
  String id = 'u1',
  String email = 'amina@example.com',
  bool emailVerified = true,
  List<String> roles = const ['donor'],
}) =>
    AuthUser(
      id: id,
      fullName: 'Amina Ali',
      email: email,
      phone: '+252611234567',
      roles: roles,
      language: 'so',
      emailVerified: emailVerified,
      phoneVerified: false,
      identityVerified: false,
      status: 'active',
      pushEnabled: true,
    );

/// In-memory [AuthRepository] for widget/flow tests. Configure the outcomes;
/// nothing hits the network.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.startWithSession});

  AuthUser? startWithSession;

  AppException? loginError;
  AppException? registerError;
  AppException? forgotError;
  AppException? resetError;
  AppException? verifyError;
  AppException? resendError;

  bool refreshSucceeds = true;
  AuthUser afterRegister = fakeUser(emailVerified: false);
  AuthUser afterLogin = fakeUser();
  AuthUser afterVerify = fakeUser();

  final List<String> calls = [];

  @override
  Future<bool> hasTokens() async => startWithSession != null;

  @override
  Future<AuthUser?> restoreUser() async => startWithSession;

  @override
  Future<AuthUser> login({required String email, required String password}) async {
    calls.add('login');
    if (loginError != null) throw loginError!;
    return afterLogin;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? language,
  }) async {
    calls.add('register');
    if (registerError != null) throw registerError!;
    return afterRegister;
  }

  @override
  Future<void> forgotPassword(String email) async {
    calls.add('forgotPassword');
    if (forgotError != null) throw forgotError!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    calls.add('resetPassword');
    if (resetError != null) throw resetError!;
  }

  @override
  Future<void> resendVerificationEmail() async {
    calls.add('resendVerificationEmail');
    if (resendError != null) throw resendError!;
  }

  @override
  Future<AuthUser> verifyEmailOtp(String code) async {
    calls.add('verifyEmailOtp');
    if (verifyError != null) throw verifyError!;
    return afterVerify;
  }

  @override
  Future<AuthUser> refreshProfile() async {
    calls.add('refreshProfile');
    return startWithSession ?? afterLogin;
  }

  AuthUser? afterUpdate;
  Object? updateError;

  @override
  Future<AuthUser> updateProfile({String? fullName, String? language, bool? pushEnabled}) async {
    calls.add('updateProfile:${fullName ?? ''}:${language ?? ''}:${pushEnabled ?? ''}');
    if (updateError != null) throw updateError!;
    final base = startWithSession ?? afterLogin;
    final updated = afterUpdate ??
        AuthUser(
          id: base.id,
          fullName: fullName ?? base.fullName,
          email: base.email,
          phone: base.phone,
          roles: base.roles,
          language: language ?? base.language,
          emailVerified: base.emailVerified,
          phoneVerified: base.phoneVerified,
          identityVerified: base.identityVerified,
          status: base.status,
          pushEnabled: pushEnabled ?? base.pushEnabled,
        );
    startWithSession = updated;
    return updated;
  }

  @override
  Future<bool> refreshSession() async {
    calls.add('refreshSession');
    return refreshSucceeds;
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    startWithSession = null;
  }
}

// --- Campaigns ---

Map<String, dynamic> campaignJson({
  String id = 'c1',
  String titleSo = 'Caawimaad caafimaad',
  String? titleEn = 'Medical help',
  String category = 'Medical',
  num goal = 8000,
  num raised = 2500,
  String status = 'active',
  String? coverImageUrl = 'http://localhost:5000/uploads/x.jpg',
  List<String> verificationBadges = const [],
  String? region,
  String organizerId = 'org1',
}) =>
    {
      '_id': id,
      'title': {'so': titleSo, 'en': ?titleEn},
      'story': {'so': 'Sheeko dheer oo faahfaahsan halkan.'},
      'category': category,
      'goalAmount': goal,
      'raisedAmount': raised,
      'currency': 'USD',
      'status': status,
      'coverImageUrl': coverImageUrl,
      'verificationBadges': verificationBadges,
      'tags': <String>[],
      'mediaUrls': <String>[],
      'organizerId': organizerId,
      'region': region,
      'createdAt': '2026-08-01T00:00:00.000Z',
    };

Campaign fakeCampaign({
  String id = 'c1',
  num goal = 8000,
  num raised = 2500,
  bool verified = false,
  String category = 'Medical',
  String? coverImageUrl = 'http://localhost:5000/uploads/x.jpg',
  String status = 'active',
  String? access,
  String? beneficiaryId,
  String organizerId = 'org1',
}) {
  final json = campaignJson(
    id: id,
    goal: goal,
    raised: raised,
    category: category,
    status: status,
    coverImageUrl: coverImageUrl,
    verificationBadges: verified ? const ['beneficiary_verified'] : const [],
    organizerId: organizerId,
  );
  if (access != null) json['access'] = access;
  if (beneficiaryId != null) json['beneficiaryId'] = beneficiaryId;
  return Campaign.fromJson(json);
}

const _fakeStats = PlatformStats(totalRaised: 125000, campaignCount: 42, donorCount: 310);

/// In-memory [CampaignRepository] for widget / controller tests.
class FakeCampaignRepository implements CampaignRepository {
  FakeCampaignRepository({List<Campaign>? all, this.statsData = _fakeStats})
      : all = all ?? const [];

  /// The full "dataset" the fake pages through.
  List<Campaign> all;

  PlatformStats statsData;
  Object? listError;
  Object? statsError;
  Duration? delay;

  /// When true, [list] never resolves (no pending timer) — for loading-state
  /// tests.
  bool hang = false;

  int listCalls = 0;
  final List<Map<String, Object?>> listArgs = [];

  @override
  Future<CampaignPage> list({
    String? category,
    String? region,
    String? query,
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    listCalls++;
    listArgs.add({'category': category, 'region': region, 'query': query, 'page': page});
    if (hang) return Completer<CampaignPage>().future;
    if (delay != null) await Future<void>.delayed(delay!);
    if (listError != null) throw listError!;

    var pool = all;
    if (category != null) pool = pool.where((c) => c.category == category).toList();
    if (query != null && query.isNotEmpty) {
      pool = pool.where((c) => c.titleFor('en').toLowerCase().contains(query.toLowerCase())).toList();
    }
    final start = (page - 1) * limit;
    final slice = start >= pool.length
        ? <Campaign>[]
        : pool.sublist(start, (start + limit).clamp(0, pool.length));
    return CampaignPage(items: slice, total: pool.length, page: page, limit: limit);
  }

  @override
  Future<PlatformStats> stats() async {
    if (statsError != null) throw statsError!;
    return statsData;
  }

  // --- Detail (configurable per test) ---

  Campaign? campaign;
  Object? campaignError;
  List<CampaignUpdate> updates = const [];
  Object? updatesError;
  List<CampaignComment> comments = const [];
  Object? commentsError;
  Object? postCommentError;
  SupporterList supporters = const SupporterList(items: [], supporterCount: 0);
  Object? supportersError;
  CampaignInteractions interactions = const CampaignInteractions();
  Object? interactionsError;
  Object? followError;
  Object? saveError;
  Object? reportError;

  final List<String> mutations = [];

  int getCampaignCalls = 0;
  int getSupportersCalls = 0;

  @override
  Future<Campaign> getCampaign(String id) async {
    getCampaignCalls++;
    if (campaignError != null) throw campaignError!;
    return campaign ?? fakeCampaign(id: id);
  }

  @override
  Future<List<CampaignUpdate>> getUpdates(String id) async {
    if (updatesError != null) throw updatesError!;
    return updates;
  }

  @override
  Future<List<CampaignComment>> getComments(String id) async {
    if (commentsError != null) throw commentsError!;
    return comments;
  }

  @override
  Future<CampaignComment> postComment(String id, String text) async {
    mutations.add('postComment:$text');
    if (postCommentError != null) throw postCommentError!;
    return CampaignComment(id: 'new', userId: 'u1', text: text, createdAt: DateTime.now());
  }

  @override
  Future<SupporterList> getSupporters(String id, {int limit = 30}) async {
    getSupportersCalls++;
    if (supportersError != null) throw supportersError!;
    return supporters;
  }

  @override
  Future<CampaignInteractions> getInteractions(String id) async {
    if (interactionsError != null) throw interactionsError!;
    return interactions;
  }

  @override
  Future<bool> setFollowing(String id, bool value) async {
    mutations.add('follow:$value');
    if (followError != null) throw followError!;
    interactions = interactions.copyWith(following: value);
    return value;
  }

  @override
  Future<bool> setSaved(String id, bool value) async {
    mutations.add('save:$value');
    if (saveError != null) throw saveError!;
    interactions = interactions.copyWith(saved: value);
    return value;
  }

  @override
  Future<void> reportCampaign(String id, String reason) async {
    mutations.add('report:$reason');
    if (reportError != null) throw reportError!;
  }
}

CampaignUpdate fakeUpdate({String id = 'u1', String text = 'We reached the halfway point today, thank you all.'}) =>
    CampaignUpdate(id: id, text: text, createdAt: DateTime(2026, 8, 10));

CampaignComment fakeComment({String id = 'c1', String userId = 'other', String text = 'Sending prayers.'}) =>
    CampaignComment(id: id, userId: userId, text: text, createdAt: DateTime(2026, 8, 12));

Supporter fakeSupporter({String id = 's1', String? name = 'Hodan A.', num amount = 50}) =>
    Supporter(id: id, amount: amount, currency: 'USD', donorName: name, createdAt: DateTime(2026, 8, 13));

// --- Donations ---

PaymentConfig fakePaymentConfig({
  List<String> providers = const ['manual', 'evc_plus'],
  String currency = 'USD',
  num minAmount = 1,
}) =>
    PaymentConfig(providers: providers, currency: currency, minAmount: minAmount);

DonationResult fakeDonationResult({
  String donationId = 'don1',
  num amount = 25,
  String currency = 'USD',
  bool isAnonymous = false,
  String donationStatus = 'confirmed',
  DonationPaymentStatus paymentStatus = DonationPaymentStatus.confirmed,
  num raisedAmount = 2525,
  String? message,
}) =>
    DonationResult(
      donationId: donationId,
      amount: amount,
      currency: currency,
      isAnonymous: isAnonymous,
      donationStatus: donationStatus,
      paymentStatus: paymentStatus,
      raisedAmount: raisedAmount,
      message: message,
      paymentId: 'pay1',
      createdAt: DateTime(2026, 8, 30, 10, 30),
    );

MyDonation fakeMyDonation({
  String id = 'md1',
  num amount = 25,
  String status = 'confirmed',
  bool isAnonymous = false,
  String? message,
  bool withCampaign = true,
  String campaignId = 'c1',
  String campaignTitle = 'Medical help',
}) =>
    MyDonation(
      id: id,
      amount: amount,
      currency: 'USD',
      status: status,
      isAnonymous: isAnonymous,
      message: message,
      createdAt: DateTime(2026, 8, 28, 9, 15),
      paymentId: 'pay-$id',
      campaign: withCampaign
          ? MyDonationCampaign(
              id: campaignId,
              title: {'en': campaignTitle, 'so': 'Caawimaad'},
              category: 'Medical',
              coverImageUrl: 'http://localhost:5000/uploads/c.jpg',
            )
          : null,
    );

/// In-memory [DonationRepository] for the donation flow + history tests. No
/// network, no real payment requests.
class FakeDonationRepository implements DonationRepository {
  FakeDonationRepository({PaymentConfig? config}) : config = config ?? fakePaymentConfig();

  PaymentConfig config;
  Object? configError;

  List<MyDonation> myDonations = const [];
  Object? myDonationsError;
  int myDonationsCalls = 0;

  /// The result returned by [donate]. Defaults to a confirmed donation.
  DonationResult? result;
  Object? donateError;

  /// Recorded donate calls, newest last. Each entry captures the args including
  /// the idempotency key, so tests can assert single-charge / retry behaviour.
  final List<Map<String, Object?>> donateCalls = [];

  int configCalls = 0;

  @override
  Future<PaymentConfig> getPaymentConfig() async {
    configCalls++;
    if (configError != null) throw configError!;
    return config;
  }

  @override
  Future<DonationResult> donate({
    required String campaignId,
    required num amount,
    required String provider,
    String? phone,
    String? message,
    required bool isAnonymous,
    required String idempotencyKey,
  }) async {
    donateCalls.add({
      'campaignId': campaignId,
      'amount': amount,
      'provider': provider,
      'phone': phone,
      'message': message,
      'isAnonymous': isAnonymous,
      'idempotencyKey': idempotencyKey,
    });
    if (donateError != null) throw donateError!;
    return result ??
        fakeDonationResult(amount: amount, isAnonymous: isAnonymous, message: message);
  }

  @override
  Future<List<MyDonation>> getMyDonations() async {
    myDonationsCalls++;
    if (myDonationsError != null) throw myDonationsError!;
    return myDonations;
  }
}

// --- Organizer ---

CampaignUpdate fakeUpdateModel({String id = 'u1', String text = 'We reached the halfway point.'}) =>
    CampaignUpdate(id: id, text: text, createdAt: DateTime(2026, 8, 20));

/// In-memory [OrganizerRepository] for organizer tests. No network.
class FakeOrganizerRepository implements OrganizerRepository {
  List<Campaign> campaigns = const [];
  Object? campaignsError;
  int campaignsCalls = 0;

  Campaign? updateResult;
  Object? updateError;
  Campaign? submitResult;
  Object? submitError;
  Campaign? cancelResult;
  Object? cancelError;
  Object? deleteError;
  CampaignUpdate? postUpdateResult;
  Object? postUpdateError;
  List<CampaignMemberInfo> members = const [];
  Object? membersError;

  final List<String> calls = [];

  @override
  Future<List<Campaign>> myCampaigns() async {
    campaignsCalls++;
    if (campaignsError != null) throw campaignsError!;
    return campaigns;
  }

  @override
  Future<Campaign> updateCampaign(String id, Map<String, dynamic> body) async {
    calls.add('update:$id');
    if (updateError != null) throw updateError!;
    return updateResult ?? fakeCampaign(id: id, status: 'under_review');
  }

  @override
  Future<Campaign> submitCampaign(String id) async {
    calls.add('submit:$id');
    if (submitError != null) throw submitError!;
    return submitResult ?? fakeCampaign(id: id, status: 'submitted');
  }

  @override
  Future<Campaign> cancelCampaign(String id) async {
    calls.add('cancel:$id');
    if (cancelError != null) throw cancelError!;
    return cancelResult ?? fakeCampaign(id: id, status: 'cancelled');
  }

  @override
  Future<void> deleteCampaign(String id) async {
    calls.add('delete:$id');
    if (deleteError != null) throw deleteError!;
  }

  @override
  Future<CampaignUpdate> postUpdate(String id, {required String text, String? imageUrl}) async {
    calls.add('postUpdate:$id:$text');
    if (postUpdateError != null) throw postUpdateError!;
    return postUpdateResult ?? fakeUpdateModel(text: text);
  }

  @override
  Future<List<CampaignMemberInfo>> campaignMembers(String id) async {
    if (membersError != null) throw membersError!;
    return members;
  }

  List<CampaignInvite> invites = const [];
  Object? invitesError;
  Object? acceptInviteError;

  @override
  Future<List<CampaignInvite>> myInvites() async {
    if (invitesError != null) throw invitesError!;
    return invites;
  }

  @override
  Future<void> acceptInvite(String memberId) async {
    calls.add('acceptInvite:$memberId');
    if (acceptInviteError != null) throw acceptInviteError!;
  }
}

CampaignInvite fakeInvite({
  String id = 'inv1',
  String campaignId = 'c1',
  String campaignTitle = 'Medical help',
  String? inviter = 'Yusuf M.',
}) =>
    CampaignInvite(
      id: id,
      campaignId: campaignId,
      campaignTitle: {'en': campaignTitle, 'so': 'Caawimaad'},
      inviterName: inviter,
      createdAt: DateTime(2026, 8, 27),
    );

// --- Support ---

SupportTicket fakeTicket({
  String id = 't1',
  String subject = 'Payment did not go through',
  String message = 'I tried to donate but it failed.',
  String status = 'open',
  List<TicketReply> replies = const [],
}) =>
    SupportTicket(
      id: id,
      subject: subject,
      message: message,
      status: status,
      replies: replies,
      createdAt: DateTime(2026, 8, 26, 9, 0),
      updatedAt: DateTime(2026, 8, 26, 12, 0),
    );

class FakeSupportRepository implements SupportRepository {
  List<SupportTicket> tickets = const [];
  Object? ticketsError;
  SupportTicket? ticket;
  Object? ticketError;
  SupportTicket? createResult;
  Object? createError;
  SupportTicket? replyResult;
  Object? replyError;

  final List<String> calls = [];
  int listCalls = 0;

  @override
  Future<List<SupportTicket>> myTickets() async {
    listCalls++;
    if (ticketsError != null) throw ticketsError!;
    return tickets;
  }

  @override
  Future<SupportTicket> getTicket(String id) async {
    if (ticketError != null) throw ticketError!;
    return ticket ?? fakeTicket(id: id);
  }

  @override
  Future<SupportTicket> createTicket({required String subject, required String message}) async {
    calls.add('create:$subject');
    if (createError != null) throw createError!;
    return createResult ?? fakeTicket(subject: subject, message: message);
  }

  @override
  Future<SupportTicket> reply(String id, String message) async {
    calls.add('reply:$id:$message');
    if (replyError != null) throw replyError!;
    return replyResult ??
        fakeTicket(id: id, replies: [TicketReply(authorRole: 'user', message: message, createdAt: DateTime(2026, 8, 27))]);
  }
}

// --- Beneficiary ---

BeneficiaryProfile fakeBeneficiaryProfile({
  String id = 'b1',
  String fullName = 'Amina Ali',
  String status = 'pending',
  String? payoutAccountId,
}) =>
    BeneficiaryProfile(
      id: id,
      fullName: fullName,
      verificationStatus: status,
      verifiedAt: status == 'verified' ? DateTime(2026, 8, 25) : null,
      payoutAccountId: payoutAccountId,
    );

PayoutAccount fakePayoutAccount({
  String id = 'pa1',
  String type = 'mobile_money',
  String providerName = 'EVC Plus',
  bool verified = false,
}) =>
    PayoutAccount(
      id: id,
      type: type,
      accountNumberMasked: '***1234',
      providerName: providerName,
      verified: verified,
    );

/// In-memory [BeneficiaryRepository] for beneficiary tests. No network.
class FakeBeneficiaryRepository implements BeneficiaryRepository {
  BeneficiaryProfile? profile;
  Object? profileError;
  BeneficiaryProfile? submitResult;
  Object? submitError;
  List<PayoutAccount> payoutAccounts = const [];
  Object? payoutError;
  PayoutAccount? createResult;
  Object? createError;

  final List<String> calls = [];

  @override
  Future<BeneficiaryProfile?> getMyProfile() async {
    if (profileError != null) throw profileError!;
    return profile;
  }

  @override
  Future<BeneficiaryProfile> submitProfile({required String fullName, String? idDocumentUrl}) async {
    calls.add('submitProfile:$fullName');
    if (submitError != null) throw submitError!;
    return submitResult ?? fakeBeneficiaryProfile(fullName: fullName, status: 'pending');
  }

  @override
  Future<List<PayoutAccount>> myPayoutAccounts() async {
    if (payoutError != null) throw payoutError!;
    return payoutAccounts;
  }

  @override
  Future<PayoutAccount> createPayoutAccount({
    required String type,
    required String accountNumber,
    required String providerName,
  }) async {
    calls.add('createPayout:$type:$providerName');
    if (createError != null) throw createError!;
    return createResult ?? fakePayoutAccount(type: type, providerName: providerName);
  }
}

// --- Notifications ---

AppNotification fakeNotification({
  String id = 'n1',
  String type = 'donation_confirmed',
  String title = 'Donation confirmed',
  String? body = 'Your donation of \$25 has been confirmed.',
  bool read = false,
  String? targetUrl = '/campaigns/c1',
  DateTime? createdAt,
}) =>
    AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      read: read,
      targetUrl: targetUrl,
      createdAt: createdAt ?? DateTime(2026, 8, 29, 10, 0),
    );

/// In-memory [NotificationRepository] for notification tests. No network.
class FakeNotificationRepository implements NotificationRepository {
  NotificationFeed feed = NotificationFeed.empty;
  Object? listError;
  Object? markReadError;
  Object? markAllError;
  bool hang = false;

  final List<String> calls = [];
  int listCalls = 0;

  @override
  Future<NotificationFeed> list() async {
    listCalls++;
    if (hang) return Completer<NotificationFeed>().future;
    if (listError != null) throw listError!;
    return feed;
  }

  @override
  Future<void> markRead(String id) async {
    calls.add('markRead:$id');
    if (markReadError != null) throw markReadError!;
  }

  @override
  Future<void> markAllRead() async {
    calls.add('markAllRead');
    if (markAllError != null) throw markAllError!;
  }
}

/// Scriptable [PushService] — drive messages through the controllers.
class FakePushService implements PushService {
  FakePushService({
    this.token = 'fcm-fake-token-123',
    this.permission = PushPermission.granted,
    this.initial,
  });

  String? token;
  PushPermission permission;
  PushMessage? initial;

  final List<String> calls = [];
  final refreshController = StreamController<String>.broadcast();
  final openedController = StreamController<PushMessage>.broadcast();
  final foregroundController = StreamController<PushMessage>.broadcast();

  @override
  Future<void> init() async => calls.add('init');

  @override
  Future<PushPermission> requestPermission() async {
    calls.add('requestPermission');
    return permission;
  }

  @override
  Future<PushPermission> permissionStatus() async => permission;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => refreshController.stream;

  @override
  Stream<PushMessage> get onMessageOpened => openedController.stream;

  @override
  Stream<PushMessage> get onForegroundMessage => foregroundController.stream;

  @override
  Future<PushMessage?> initialMessage() async => initial;

  @override
  Future<void> deleteToken() async {
    calls.add('deleteToken');
    token = null;
  }

  void dispose() {
    refreshController.close();
    openedController.close();
    foregroundController.close();
  }
}

/// In-memory [DeviceApi] — records register/remove calls.
class FakeDeviceApi implements DeviceApi {
  final List<String> calls = [];
  Object? registerError;

  @override
  Future<void> register({required String token, String? platform}) async {
    calls.add('register:$token:$platform');
    if (registerError != null) throw registerError!;
  }

  @override
  Future<void> remove(String token) async => calls.add('remove:$token');

  @override
  Future<List<Map<String, dynamic>>> list() async => const [];
}
