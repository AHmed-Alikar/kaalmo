/// Relative paths for the existing Kaalmo backend. Joined onto
/// [AppConfig.apiBaseUrl], which already carries the `/api/v1` prefix.
class ApiRoutes {
  const ApiRoutes._();

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const refresh = '/auth/refresh';
  static const verifyEmailOtp = '/auth/verify-email-otp';
  static const resendVerificationEmail = '/auth/resend-verification-email';
  static const verifyPhoneOtp = '/auth/verify-otp';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  // Current user
  static const me = '/users/me';

  // Devices (push)
  static const devices = '/devices';

  // Campaigns
  static const campaigns = '/campaigns';
  static const campaignsStats = '/campaigns/stats';
  static const campaignsMine = '/campaigns/mine';
  static String campaign(String id) => '/campaigns/$id';
  static String campaignSubmit(String id) => '/campaigns/$id/submit';
  static String campaignCancel(String id) => '/campaigns/$id/cancel';
  static String campaignMembers(String id) => '/campaigns/$id/members';
  static String campaignUpdates(String id) => '/campaigns/$id/updates';
  static String campaignComments(String id) => '/campaigns/$id/comments';
  static String campaignDonations(String id) => '/campaigns/$id/donations';
  static String campaignInteractions(String id) => '/campaigns/$id/interactions';
  static String campaignFollow(String id) => '/campaigns/$id/follow';
  static String campaignSave(String id) => '/campaigns/$id/save';
  static String campaignDonate(String id) => '/campaigns/$id/donate';

  // Trust & safety
  static const reports = '/reports';

  // Donations & payments
  static const paymentConfig = '/payments/config';
  static const donationsMine = '/donations/mine';

  // Beneficiary & payout
  static const beneficiaryMe = '/beneficiaries/me';
  static const payoutAccountsMine = '/payout-accounts/mine';
  static const payoutAccounts = '/payout-accounts';

  // Uploads
  static const uploadImage = '/uploads/image';

  // Notifications
  static const notifications = '/notifications/mine';
  static const notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // Support tickets
  static const supportTickets = '/support-tickets';
  static const supportTicketsMine = '/support-tickets/mine';
  static String supportTicket(String id) => '/support-tickets/mine/$id';
  static String supportTicketReplies(String id) => '/support-tickets/mine/$id/replies';

  // Co-organizer invites
  static const campaignInvitesMine = '/campaign-invites/mine';
  static String campaignInviteAccept(String memberId) => '/campaign-invites/$memberId/accept';
}
