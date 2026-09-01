/// Canonical route paths. Screens are added feature-by-feature in later
/// phases; only `/splash` has real behaviour today.
class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const verifyEmail = '/verify-email';

  static const home = '/home';
  static const explore = '/explore';
  static const campaignDetail = '/campaign/:id';
  static const organizer = '/organizer';
  static const organizerCampaigns = '/organizer/campaigns';
  static const organizerInvites = '/organizer/invites';
  static const startFundraiser = '/organizer/start';
  static const beneficiary = '/beneficiary';
  static const notifications = '/notifications';
  static const profile = '/profile';
  static const myDonations = '/profile/donations';
  static const settings = '/profile/settings';
  static const about = '/profile/settings/about';
  static const support = '/support';
  static const supportNew = '/support/new';

  static String campaign(String id) => '/campaign/$id';
  static String myDonation(String id) => '/profile/donations/$id';
  static String organizerCampaign(String id) => '/organizer/campaign/$id';
  static String organizerCampaignEdit(String id) => '/organizer/campaign/$id/edit';
  static String organizerCampaignUpdate(String id) => '/organizer/campaign/$id/update';
  static String supportTicket(String id) => '/support/$id';

  /// Reachable without a session.
  static const publicPaths = <String>{
    splash,
    login,
    register,
    forgotPassword,
    resetPassword,
    explore,
    // `/campaign/:id` handled by prefix check.
  };

  /// Routes an authenticated (and email-verified) user should be bounced away
  /// from.
  static const authOnlyGuestPaths = <String>{
    login,
    register,
    forgotPassword,
    resetPassword,
    verifyEmail,
  };
}
