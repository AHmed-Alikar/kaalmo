// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kaalmo';

  @override
  String get splashTagline => 'Community fundraising, done right';

  @override
  String get navHome => 'Home';

  @override
  String get navExplore => 'Explore';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navProfile => 'Profile';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionSave => 'Save';

  @override
  String get actionClose => 'Close';

  @override
  String get authLogIn => 'Log in';

  @override
  String get authRegister => 'Create account';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authResetPassword => 'Reset password';

  @override
  String get authLogOut => 'Log out';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateEmptyTitle => 'Nothing here yet';

  @override
  String get stateEmptyBody =>
      'When there is something to show, it will appear here.';

  @override
  String get stateErrorTitle => 'Something went wrong';

  @override
  String get stateErrorGeneric => 'Please check your connection and try again.';

  @override
  String get stateSuccessTitle => 'Done';

  @override
  String get errorNetwork =>
      'Can\'t reach Kaalmo right now. Check your connection.';

  @override
  String get errorTimeout => 'The request took too long. Please try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorSessionExpired =>
      'Your session has ended. Please log in again.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSomali => 'Soomaali';

  @override
  String get languageEnglish => 'English';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authLoginSubtitle => 'Log in to keep supporting your community.';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authRegisterSubtitle =>
      'Join Kaalmo to raise funds and give with confidence.';

  @override
  String get fieldEmail => 'Email address';

  @override
  String get fieldEmailHint => 'you@example.com';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordHint => 'At least 8 characters';

  @override
  String get fieldConfirmPassword => 'Confirm password';

  @override
  String get fieldFullName => 'Full name';

  @override
  String get fieldFullNameHint => 'Your name as it should appear';

  @override
  String get fieldPhone => 'Phone number';

  @override
  String get fieldPhoneHint => 'e.g. +252 61 234 5678';

  @override
  String get fieldResetCode => 'Reset code';

  @override
  String get fieldVerificationCode => 'Verification code';

  @override
  String get fieldNewPassword => 'New password';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmailInvalid => 'Enter a valid email address';

  @override
  String get validationPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get validationPasswordTooLong =>
      'Password must be 72 characters or fewer';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String get validationNameTooShort => 'Enter your full name';

  @override
  String get validationPhoneInvalid => 'Enter a valid phone number';

  @override
  String get validationCodeLength => 'Enter the 6-digit code';

  @override
  String get validationTermsRequired => 'Please accept the terms to continue';

  @override
  String get authNoAccountPrompt => 'New to Kaalmo?';

  @override
  String get authHaveAccountPrompt => 'Already have an account?';

  @override
  String get authAcceptTerms =>
      'I agree to Kaalmo\'s Terms of Service and Privacy Policy.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String verifyEmailSubtitle(Object email) {
    return 'We sent a 6-digit code to $email. Enter it below to confirm your email.';
  }

  @override
  String get verifyEmailAction => 'Verify email';

  @override
  String get verifyEmailResend => 'Resend code';

  @override
  String verifyEmailResendIn(Object seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get verifyEmailResent => 'A new code is on its way.';

  @override
  String get verifyEmailSuccess => 'Email verified. Welcome to Kaalmo!';

  @override
  String get verifyEmailAlreadyVerified => 'This email is already verified.';

  @override
  String get verifyEmailInvalidCode =>
      'That code is incorrect or has expired. Request a new one.';

  @override
  String get verifyEmailLater => 'I\'ll do this later';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter the email for your account and we\'ll send a reset code.';

  @override
  String get forgotPasswordAction => 'Send reset code';

  @override
  String get forgotPasswordSentTitle => 'Check your email';

  @override
  String get forgotPasswordSentBody =>
      'If an account exists for that address, a 6-digit reset code has been sent. It expires in 15 minutes.';

  @override
  String get forgotPasswordEnterCode => 'Enter reset code';

  @override
  String get resetPasswordTitle => 'Choose a new password';

  @override
  String get resetPasswordSubtitle =>
      'Enter the code from your email and a new password.';

  @override
  String get resetPasswordAction => 'Reset password';

  @override
  String get resetPasswordInvalidCode =>
      'This reset code is invalid or has expired. Request a new one.';

  @override
  String get resetPasswordSuccessTitle => 'Password updated';

  @override
  String get resetPasswordSuccessBody =>
      'Your password has been changed. Please log in with your new password.';

  @override
  String get resetPasswordBackToLogin => 'Back to log in';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmBody => 'You\'ll need to log in again to continue.';

  @override
  String get errorInvalidCredentials => 'Email or password is incorrect.';

  @override
  String get errorAccountDisabled =>
      'This account is suspended. Contact support if you think this is a mistake.';

  @override
  String get errorAccountExists =>
      'An account with this email or phone already exists.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Please wait a little and try again.';

  @override
  String get errorEmailSendFailed =>
      'We couldn\'t send the email. Please try again shortly.';

  @override
  String homeGreeting(Object name) {
    return 'Hello, $name';
  }

  @override
  String get homeGreetingGeneric => 'Welcome';

  @override
  String get homeGreetingSubtitle => 'Find a cause worth supporting test.';

  @override
  String get homeSearchHint => 'Search campaigns';

  @override
  String get homeFeatured => 'Featured';

  @override
  String get homeCategories => 'Categories';

  @override
  String get homeRecent => 'Recent campaigns';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeEmptyTitle => 'No campaigns yet';

  @override
  String get homeEmptyBody =>
      'Verified campaigns will appear here as soon as they\'re published.';

  @override
  String get statsRaised => 'Total raised';

  @override
  String get statsCampaigns => 'Campaigns';

  @override
  String get statsDonors => 'Donors';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreSearchHint => 'Search by title or story';

  @override
  String get exploreNoResultsTitle => 'No matching campaigns';

  @override
  String get exploreNoResultsBody =>
      'Try a different search or clear your filters.';

  @override
  String get exploreEndOfList => 'You\'ve reached the end';

  @override
  String get campaignCompleted => 'Completed';

  @override
  String get regionAll => 'All regions';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryMedical => 'Medical';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categoryEmergency => 'Emergency';

  @override
  String get categoryFamily => 'Family';

  @override
  String get categoryFuneral => 'Funeral';

  @override
  String get categoryCommunity => 'Community';

  @override
  String get categoryMosque => 'Mosque';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryOrphanSupport => 'Orphan support';

  @override
  String get categoryDisasterRelief => 'Disaster relief';

  @override
  String get categoryBusiness => 'Business';

  @override
  String get categoryNgo => 'NGO';

  @override
  String get categoryPublicProjects => 'Public projects';

  @override
  String get categoryOther => 'Other';

  @override
  String get campaignLoadErrorTitle => 'Couldn\'t load this campaign';

  @override
  String get campaignStory => 'Story';

  @override
  String get campaignStoryUnavailable =>
      'The organizer hasn\'t added a story yet.';

  @override
  String get readMore => 'Read more';

  @override
  String get showLess => 'Show less';

  @override
  String campaignRaisedAmount(Object amount) {
    return '$amount raised';
  }

  @override
  String campaignOfGoal(Object goal) {
    return 'of $goal goal';
  }

  @override
  String campaignFundedPercent(Object percent) {
    return '$percent% funded';
  }

  @override
  String campaignSupportersLine(int count, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supporters',
      one: '1 supporter',
    );
    return '$_temp0 · $percent% funded';
  }

  @override
  String get campaignEnded => 'This campaign has ended';

  @override
  String get campaignEndsToday => 'Ends today';

  @override
  String campaignDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get trustSectionTitle => 'Verification';

  @override
  String get badgeIdentityVerified => 'Identity verified';

  @override
  String get badgeBeneficiaryVerified => 'Beneficiary verified';

  @override
  String get badgeOrganizationVerified => 'Organization verified';

  @override
  String get badgePaymentVerified => 'Payment verified';

  @override
  String galleryCounter(int current, int total) {
    return '$current of $total';
  }

  @override
  String galleryMoreCount(int count) {
    return '+$count photos';
  }

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under review';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusActive => 'Active';

  @override
  String get statusGoalReached => 'Goal reached';

  @override
  String get statusWithdrawal => 'Funds being withdrawn';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusFrozen => 'Frozen';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusExpired => 'Ended';

  @override
  String get statusRejected => 'Not approved';

  @override
  String get statusUnavailable => 'Status unavailable';

  @override
  String get statusBannerCompleted =>
      'This campaign is complete. You can still read its story and updates.';

  @override
  String get statusBannerGoalReached =>
      'This campaign has reached its goal. Thank you to everyone who gave.';

  @override
  String get statusBannerSuspended =>
      'This campaign is under review and is not accepting support right now.';

  @override
  String get statusBannerFrozen =>
      'This campaign is temporarily frozen while it is reviewed.';

  @override
  String get statusBannerCancelled =>
      'This campaign was cancelled by the organizer.';

  @override
  String get statusBannerExpired =>
      'This campaign has ended and is no longer active.';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get share => 'Share';

  @override
  String get reportAction => 'Report campaign';

  @override
  String get donateComingSoon => 'Donate';

  @override
  String get donationsClosed => 'Donations closed';

  @override
  String get campaignUpdates => 'Updates';

  @override
  String get updateFromOrganizer => 'Update from the organizer';

  @override
  String get updatesEmpty => 'The organizer hasn\'t posted any updates yet.';

  @override
  String get updatesEmptyTitle => 'No updates yet';

  @override
  String get updatesLoadError => 'Couldn\'t load updates.';

  @override
  String seeAllUpdates(int count) {
    return 'See all $count updates';
  }

  @override
  String get comments => 'Comments';

  @override
  String get commentsEmpty => 'Be the first to leave a message of support.';

  @override
  String get commentsEmptyTitle => 'No comments yet';

  @override
  String get commentAuthorYou => 'You';

  @override
  String get commentAuthorSupporter => 'Supporter';

  @override
  String get commentHint => 'Write a message of support…';

  @override
  String get commentSend => 'Send';

  @override
  String get commentSignInPrompt => 'Log in to add a comment';

  @override
  String get supporters => 'Supporters';

  @override
  String get supporterAnonymous => 'Anonymous';

  @override
  String get supportersEmpty => 'No confirmed donations yet.';

  @override
  String get supportersEmptyTitle => 'No supporters yet';

  @override
  String get supportersLoadError => 'Couldn\'t load supporters.';

  @override
  String supportersCountHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supporters',
      one: '1 supporter',
    );
    return '$_temp0';
  }

  @override
  String get supportersRecentOnly => 'Showing the most recent supporters.';

  @override
  String seeAllSupporters(int count) {
    return 'See all $count supporters';
  }

  @override
  String get reportTitle => 'Report this campaign';

  @override
  String get reportSubtitle =>
      'Your report goes to the Kaalmo team for review. It stays private.';

  @override
  String get reportReasonScam => 'Scam or fraud';

  @override
  String get reportReasonFalseInfo => 'False or misleading information';

  @override
  String get reportReasonMisuse => 'Misuse of funds';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonDuplicate => 'Duplicate campaign';

  @override
  String get reportReasonOther => 'Something else';

  @override
  String get reportExplanationLabel => 'Add details (optional)';

  @override
  String get reportExplanationHint => 'Tell us what you noticed';

  @override
  String get reportSubmit => 'Submit report';

  @override
  String get reportSuccessTitle => 'Report received';

  @override
  String get reportSuccessBody =>
      'Thank you. The Kaalmo team will review this campaign.';

  @override
  String get loginRequiredTitle => 'Log in to continue';

  @override
  String loginRequiredBody(Object action) {
    return 'You need an account to $action this campaign.';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get donateTitle => 'Donate';

  @override
  String get donateActionLabel => 'donate to';

  @override
  String get donateLoginTitle => 'Log in to donate';

  @override
  String get donateLoginBody =>
      'You need a Kaalmo account so we can send your receipt and confirm your donation.';

  @override
  String get donateAmountLabel => 'Choose an amount';

  @override
  String get donateCustomAmount => 'Other amount';

  @override
  String get donateAmountInvalid => 'Enter a valid amount.';

  @override
  String donateAmountTooLow(Object amount) {
    return 'The minimum donation is $amount.';
  }

  @override
  String donateAmountTooHigh(Object amount) {
    return 'That is above the maximum of $amount.';
  }

  @override
  String get donateMessageLabel => 'Message (optional)';

  @override
  String get donateMessageHint => 'Add a word of encouragement…';

  @override
  String get donateMessageTooLong => 'Your message is a little too long.';

  @override
  String get donateAnonymousTitle => 'Donate anonymously';

  @override
  String get donateAnonymousSubtitle =>
      'Your name won\'t be shown publicly on this campaign.';

  @override
  String get donateAnonymousYes => 'Anonymous';

  @override
  String get donateAnonymousNo => 'Name shown';

  @override
  String get donateContinue => 'Continue';

  @override
  String get donateReviewTitle => 'Review your donation';

  @override
  String get donateReviewAmount => 'Amount';

  @override
  String get donateReviewMessage => 'Message';

  @override
  String get donateReviewNoMessage => 'No message';

  @override
  String get donateReviewAnonymous => 'Visibility';

  @override
  String get donatePaymentMethod => 'Payment method';

  @override
  String get donatePhoneLabel => 'Mobile money number';

  @override
  String get donatePhoneHint => 'e.g. 0612345678';

  @override
  String get donatePhoneInvalid => 'Enter a valid mobile number.';

  @override
  String get donateFees => 'Fees';

  @override
  String get donateFeesNone => 'No fees';

  @override
  String get donateTotal => 'Total';

  @override
  String get donateSecurityNote =>
      'Kaalmo confirms every payment with the provider before your donation counts.';

  @override
  String donateConfirm(Object amount) {
    return 'Donate $amount';
  }

  @override
  String get donateEdit => 'Edit donation';

  @override
  String get donateProcessingTitle => 'Processing your donation';

  @override
  String get donateProcessingBody =>
      'Please wait — we\'re confirming your payment with the provider.';

  @override
  String get donatePendingTitle => 'Your payment is being processed';

  @override
  String get donatePendingBody =>
      'This can take a little while. We\'ll update the campaign as soon as it is confirmed — you don\'t need to pay again.';

  @override
  String get donateFailedTitle => 'Donation not completed';

  @override
  String get donateFailedGeneric =>
      'Your payment could not be completed. You have not been charged.';

  @override
  String get donateRetry => 'Try again';

  @override
  String get donateSuccessTitle => 'Thank you for your support';

  @override
  String donateSuccessBody(Object amount) {
    return 'Your donation of $amount is confirmed.';
  }

  @override
  String get donateBackToCampaign => 'Back to campaign';

  @override
  String get payMethodEvcPlusTitle => 'EVC Plus';

  @override
  String get payMethodEvcPlusSubtitle => 'Mobile money — pay from your phone';

  @override
  String get payMethodManualTitle => 'Cash / offline';

  @override
  String get payMethodManualSubtitle =>
      'Recorded now and confirmed by the Kaalmo team';

  @override
  String get payMethodBankTitle => 'Bank transfer';

  @override
  String get payMethodBankSubtitle => 'Pay from your bank account';

  @override
  String get payMethodCardTitle => 'Card';

  @override
  String get payMethodCardSubtitle => 'Debit or credit card';

  @override
  String get payMethodGenericSubtitle => 'Supported payment method';

  @override
  String get payNoMethods =>
      'No payment methods are available right now. Please try again later.';

  @override
  String get receiptTitle => 'Donation receipt';

  @override
  String get receiptCampaign => 'Campaign';

  @override
  String get receiptAmount => 'Amount';

  @override
  String get receiptDate => 'Date';

  @override
  String get receiptMethod => 'Method';

  @override
  String get receiptVisibility => 'Visibility';

  @override
  String get receiptReference => 'Reference';

  @override
  String get receiptMessage => 'Your message';

  @override
  String get errorCampaignNotOpen =>
      'This campaign is not currently open for donations.';

  @override
  String get myDonationsTitle => 'My donations';

  @override
  String get myDonationsActionLabel => 'see your donations';

  @override
  String get myDonationsLoginTitle => 'Log in to see your donations';

  @override
  String get myDonationsLoginBody =>
      'Your donation history is linked to your Kaalmo account.';

  @override
  String get myDonationsErrorTitle => 'Couldn\'t load your donations';

  @override
  String get myDonationsEmptyTitle => 'No donations yet';

  @override
  String get myDonationsEmptyBody =>
      'When you support a campaign, it will show up here.';

  @override
  String get myDonationsExplore => 'Explore campaigns';

  @override
  String get donationDetailTitle => 'Donation';

  @override
  String get donationCampaignUnavailable => 'Campaign unavailable';

  @override
  String get donationCampaignRemoved => 'This campaign is no longer available.';

  @override
  String get donationViewCampaign => 'View campaign';

  @override
  String get donationNotFoundTitle => 'Donation not found';

  @override
  String get donationNotFoundBody =>
      'We couldn\'t find this donation in your history.';

  @override
  String get donationBackToList => 'Back to my donations';

  @override
  String get donationStatusPending => 'Pending';

  @override
  String get donationStatusConfirmed => 'Confirmed';

  @override
  String get donationStatusFailed => 'Failed';

  @override
  String get donationStatusRefunded => 'Refunded';

  @override
  String get donationStatusUnknown => 'Unknown';

  @override
  String get receiptStatus => 'Status';

  @override
  String get organizerDashboardTitle => 'Organizer';

  @override
  String get organizerNotAvailableTitle => 'Not an organizer yet';

  @override
  String get organizerNotAvailableBody =>
      'Once your organizer access is approved you can manage campaigns here.';

  @override
  String get organizerLoadErrorTitle => 'Couldn\'t load your campaigns';

  @override
  String get organizerDashboardHeadline => 'Your campaigns at a glance';

  @override
  String get organizerTotalRaised => 'Total raised across your campaigns';

  @override
  String get organizerTotalRaisedNote =>
      'Confirmed donations only — the backend is the source of truth.';

  @override
  String get organizerStatTotal => 'Campaigns';

  @override
  String get organizerStatLive => 'Live';

  @override
  String get organizerStatInReview => 'In review';

  @override
  String get organizerStatDrafts => 'Drafts';

  @override
  String get organizerStatCompleted => 'Completed';

  @override
  String get organizerStatRejected => 'Not approved';

  @override
  String get organizerRecentCampaigns => 'Recent campaigns';

  @override
  String get organizerViewAll => 'View all';

  @override
  String get organizerNoCampaignsYet =>
      'You haven\'t created any campaigns yet.';

  @override
  String get organizerMyCampaignsTitle => 'My campaigns';

  @override
  String get organizerNoCampaignsTitle => 'No campaigns yet';

  @override
  String get organizerNoCampaignsBody =>
      'Campaigns you create or co-organize will appear here.';

  @override
  String get organizerRoleCoOrganizer => 'Co-organizer';

  @override
  String get organizerManageTitle => 'Manage campaign';

  @override
  String get organizerRejectedNote =>
      'This campaign was not approved. Contact support if you\'d like to try again.';

  @override
  String get organizerEditReturnsToReview =>
      'Saving changes will send this campaign back for review before donors see the update.';

  @override
  String get organizerActions => 'Actions';

  @override
  String get organizerActionEdit => 'Edit campaign';

  @override
  String get organizerActionPostUpdate => 'Post an update';

  @override
  String get organizerActionViewPublic => 'View public page';

  @override
  String get organizerActionSubmit => 'Submit for review';

  @override
  String get organizerActionCancel => 'Cancel campaign';

  @override
  String get organizerActionDelete => 'Delete draft';

  @override
  String get organizerSubmitConfirmTitle => 'Submit for review?';

  @override
  String get organizerSubmitConfirmBody =>
      'The Kaalmo team will review your campaign before it goes live.';

  @override
  String get organizerSubmitSuccess => 'Campaign submitted for review.';

  @override
  String get organizerCancelConfirmTitle => 'Cancel this campaign?';

  @override
  String get organizerCancelConfirmBody =>
      'This cannot be undone. The campaign will be closed.';

  @override
  String get organizerCancelSuccess => 'Campaign cancelled.';

  @override
  String get organizerDeleteConfirmTitle => 'Delete this draft?';

  @override
  String get organizerDeleteConfirmBody =>
      'The draft will be permanently removed.';

  @override
  String get organizerBeneficiary => 'Beneficiary';

  @override
  String get organizerBeneficiaryLinked =>
      'A beneficiary is linked to this campaign.';

  @override
  String get organizerBeneficiaryNone =>
      'No beneficiary is linked to this campaign yet.';

  @override
  String get organizerBeneficiaryEmailLabel => 'Beneficiary\'s email';

  @override
  String get organizerBeneficiarySend => 'Send invitation';

  @override
  String get organizerBeneficiarySent =>
      'Invitation sent. They\'ll accept and complete verification.';

  @override
  String get organizerTeam => 'Team';

  @override
  String get organizerTeamLoadError => 'Couldn\'t load the team list.';

  @override
  String get organizerTeamEmpty => 'No co-organizers on this campaign.';

  @override
  String get organizerTeamAccepted => 'Accepted';

  @override
  String get organizerTeamPending => 'Pending';

  @override
  String get organizerEditTitle => 'Edit campaign';

  @override
  String get organizerFieldTitleSo => 'Title (Somali)';

  @override
  String get organizerFieldTitleEn => 'Title (English, optional)';

  @override
  String get organizerFieldCategory => 'Category';

  @override
  String get organizerFieldRegion => 'Region (optional)';

  @override
  String get organizerFieldGoal => 'Goal amount';

  @override
  String get organizerFieldStorySo => 'Story (Somali)';

  @override
  String get organizerFieldStoryEn => 'Story (English, optional)';

  @override
  String organizerFieldTitleTooShort(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String organizerFieldTitleTooLong(int max) {
    return 'Keep it under $max characters.';
  }

  @override
  String organizerFieldStoryTooShort(int min) {
    return 'Tell the story in at least $min characters.';
  }

  @override
  String get organizerFieldGoalInvalid =>
      'Enter a goal amount greater than zero.';

  @override
  String get organizerRegionNone => 'No region';

  @override
  String get organizerEditSuccess => 'Campaign updated.';

  @override
  String get organizerEditMediaNote =>
      'Cover photo and gallery images can\'t be changed from the app yet.';

  @override
  String get organizerSaveChanges => 'Save changes';

  @override
  String get organizerPostUpdateTitle => 'Post an update';

  @override
  String get organizerPostUpdateSubtitle =>
      'Everyone following this campaign will be notified.';

  @override
  String get organizerUpdateHint =>
      'Share progress, a thank-you, or what the funds achieved…';

  @override
  String organizerUpdateTooShort(int min) {
    return 'Write at least $min characters.';
  }

  @override
  String get organizerUpdatePosted => 'Update posted.';

  @override
  String get organizerPublishUpdate => 'Publish update';

  @override
  String get startFundraiserTitle => 'Start a fundraiser';

  @override
  String get organizerAccessTitle => 'Become an organizer';

  @override
  String get organizerAccessBody =>
      'Organizers create and manage fundraising campaigns. We\'ll email you a 6-digit code to confirm — this is a one-time step and doesn\'t change how you donate.';

  @override
  String get organizerAccessConfirmTitle => 'Confirm by email';

  @override
  String get organizerAccessConfirmBody =>
      'Enter the 6-digit code we sent to your email address.';

  @override
  String get organizerAccessFullName => 'Your full name';

  @override
  String get organizerAccessPurpose =>
      'What will you raise funds for? (optional)';

  @override
  String get organizerAccessPurposeHint =>
      'e.g. Medical treatment for my brother';

  @override
  String get organizerAccessSendCode => 'Send code';

  @override
  String get organizerAccessConfirm => 'Confirm & continue';

  @override
  String get organizerAccessResend => 'Resend code';

  @override
  String get organizerAccessResent => 'A new code is on its way.';

  @override
  String get organizerAccessChangeDetails => 'Change details';

  @override
  String get createCampaignTitle => 'Campaign details';

  @override
  String get createCampaignSubtitle =>
      'Your campaign is saved as a draft. You can review it and submit it for approval afterwards.';

  @override
  String get createCampaignTitleHint => 'e.g. Help rebuild the Xamar clinic';

  @override
  String get createCampaignStoryHint =>
      'Explain who this is for, what the funds will do, and why it matters.';

  @override
  String get createCampaignFieldEndDate => 'End date (optional)';

  @override
  String get createCampaignEndDatePick => 'Pick a date';

  @override
  String get createCampaignCoverNote =>
      'You can add a cover photo later from the campaign page on the web.';

  @override
  String get createCampaignSubmit => 'Create campaign';

  @override
  String get createCampaignSuccess => 'Campaign created — saved as a draft.';

  @override
  String get coOrgBanner =>
      'You\'re a co-organizer on this campaign. You can edit its content and post updates; the owner manages the team, beneficiary and withdrawals.';

  @override
  String get beneficiaryDashboardTitle => 'Beneficiary';

  @override
  String get beneficiaryLoadErrorTitle =>
      'Couldn\'t load your beneficiary profile';

  @override
  String get beneficiaryAccountBanner =>
      'This is your beneficiary account — separate from organizing campaigns. Here you accept invitations and complete verification.';

  @override
  String get beneficiaryForCampaignLabel => 'For campaign';

  @override
  String get beneficiaryNextNone =>
      'You have no beneficiary invitation yet. An organizer invites you by email.';

  @override
  String get beneficiaryNextInvited =>
      'Accept the invitation above to begin. Accepting does not verify you.';

  @override
  String get beneficiaryNextAccepted =>
      'Submit your verification details. An admin then reviews them.';

  @override
  String get beneficiaryNextPending =>
      'Your verification was submitted and is waiting for admin review.';

  @override
  String get beneficiaryNextVerified =>
      'You\'re a verified beneficiary. Payout setup is handled by the Kaalmo team.';

  @override
  String get beneficiaryNextRejected =>
      'Update your details and resubmit for another review.';

  @override
  String get beneficiaryStatusNone => 'Not started';

  @override
  String get beneficiaryStatusInvited => 'Invited';

  @override
  String get beneficiaryStatusAccepted => 'Accepted — verification needed';

  @override
  String get beneficiaryStatusPending => 'Under review';

  @override
  String get beneficiaryStatusVerified => 'Verified';

  @override
  String get beneficiaryStatusRejected => 'Not approved';

  @override
  String get beneficiaryStatusNeedsInfo => 'More information needed';

  @override
  String get beneficiaryNeedsInfoNote =>
      'The review team asked for more information. Update your details and resubmit.';

  @override
  String get beneficiaryInvitesTitle => 'Beneficiary invitations';

  @override
  String get beneficiaryInviteGeneric =>
      'You\'ve been named the beneficiary for a campaign.';

  @override
  String get beneficiaryInviteAccept => 'Accept invitation';

  @override
  String get beneficiaryInviteAccepted =>
      'Invitation accepted. Now complete your verification.';

  @override
  String get beneficiaryVerificationTitle => 'Verification';

  @override
  String get beneficiaryCheckEmail => 'Email verified';

  @override
  String get beneficiaryCheckPhone => 'Phone verified';

  @override
  String get beneficiaryCheckIdentity => 'Identity verified';

  @override
  String get beneficiaryCheckBeneficiary => 'Beneficiary verified';

  @override
  String get beneficiaryNoName => 'Beneficiary profile';

  @override
  String get beneficiaryRejectedNote =>
      'Your beneficiary details were not approved. You can update and resubmit them.';

  @override
  String get beneficiaryPendingNote =>
      'Your details have been submitted and are waiting for review by the Kaalmo team.';

  @override
  String get beneficiaryStartVerification => 'Start beneficiary verification';

  @override
  String get beneficiaryUpdateIdentity => 'Update my details';

  @override
  String get beneficiaryPayoutTitle => 'Payout account';

  @override
  String get beneficiaryNoPayoutAccount =>
      'You haven\'t added a payout account yet.';

  @override
  String get beneficiaryPayoutVerified => 'Verified';

  @override
  String get beneficiaryPayoutUnverified => 'Awaiting verification';

  @override
  String get beneficiaryAddPayoutButton => 'Add payout account';

  @override
  String get beneficiaryReadyTitle => 'Ready for withdrawal';

  @override
  String get beneficiaryReadyBody =>
      'Your identity and payout account are verified. Withdrawal requests are handled in a later release.';

  @override
  String get beneficiaryNotReadyTitle => 'Not ready for payout yet';

  @override
  String get beneficiaryNotReadyVerify =>
      'Complete beneficiary verification first.';

  @override
  String get beneficiaryNotReadyLinkage =>
      'Your identity is verified. An admin still needs to link your payout account to your beneficiary profile.';

  @override
  String get beneficiaryCampaignLinkNote =>
      'Linking a beneficiary to a specific campaign is done by the Kaalmo team — there is no self-service option in the app yet.';

  @override
  String get beneficiaryIdentityTitle => 'Beneficiary details';

  @override
  String get beneficiaryIdentitySubtitle =>
      'Provide your legal name as it appears on your ID. The Kaalmo team verifies it.';

  @override
  String get beneficiaryFullNameLabel => 'Full legal name';

  @override
  String get beneficiaryFullNameInvalid =>
      'Enter your full name (2–100 characters).';

  @override
  String get beneficiarySubmitIdentity => 'Submit for verification';

  @override
  String get beneficiaryIdentitySubmitted =>
      'Details submitted for verification.';

  @override
  String get beneficiaryAddPayoutTitle => 'Add payout account';

  @override
  String get payoutTypeMobileMoney => 'Mobile money';

  @override
  String get payoutTypeBank => 'Bank';

  @override
  String get beneficiaryProviderLabel => 'Provider name';

  @override
  String get beneficiaryProviderHint => 'e.g. EVC Plus, Salaam Bank';

  @override
  String get beneficiaryProviderInvalid =>
      'Enter the provider name (2–60 characters).';

  @override
  String get beneficiaryAccountNumberLabel => 'Account number';

  @override
  String get beneficiaryAccountNumberHelper =>
      'Only the last 4 digits are stored.';

  @override
  String get beneficiaryAccountNumberInvalid =>
      'Enter a valid account number (4–30 digits).';

  @override
  String get beneficiaryPayoutAdded => 'Payout account added.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsActionLabel => 'see your notifications';

  @override
  String get notificationsLoginTitle => 'Log in to see your notifications';

  @override
  String get notificationsLoginBody =>
      'Notifications are tied to your Kaalmo account.';

  @override
  String get notificationsErrorTitle => 'Couldn\'t load your notifications';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'Updates about your donations, campaigns and account will appear here.';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notifKindDonation => 'Donation';

  @override
  String get notifKindCampaignUpdate => 'Campaign update';

  @override
  String get notifKindCampaignStatus => 'Campaign status';

  @override
  String get notifKindBeneficiary => 'Beneficiary';

  @override
  String get notifKindWithdrawal => 'Withdrawal';

  @override
  String get notifKindTeam => 'Team';

  @override
  String get notifKindSupport => 'Support';

  @override
  String get notifKindSecurity => 'Account & security';

  @override
  String get notifKindSystem => 'Notification';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundBody => 'The page you\'re looking for isn\'t here.';

  @override
  String get notFoundGoHome => 'Go to Home';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsEditName => 'Edit name';

  @override
  String get settingsFullName => 'Full name';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsNameUpdated => 'Your name has been updated.';

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsChangePasswordBody =>
      'For your security, you\'ll be signed out and sent a reset code by email.';

  @override
  String get settingsPushNotifications => 'Push notifications';

  @override
  String get settingsPushNotificationsNote =>
      'Get alerts on your device when push notifications are enabled for your account.';

  @override
  String get settingsCloseAccount => 'Close my account';

  @override
  String get settingsCloseAccountSubject => 'Please close my Kaalmo account';

  @override
  String get aboutTitle => 'About Kaalmo';

  @override
  String get aboutTagline => 'Community fundraising for Somalia, done right.';

  @override
  String get aboutBody =>
      'Kaalmo helps people raise and give funds transparently — for medical bills, emergencies, education, mosques, community projects and more. Every campaign is reviewed, and verified beneficiaries receive the funds.';

  @override
  String get aboutLegalHeading => 'Legal & contact';

  @override
  String get aboutTerms => 'Terms of Service';

  @override
  String get aboutPrivacy => 'Privacy Policy';

  @override
  String get aboutContact => 'Contact';

  @override
  String get supportTitle => 'Help & Support';

  @override
  String get supportNewTicket => 'New request';

  @override
  String get supportErrorTitle => 'Couldn\'t load your support requests';

  @override
  String get supportEmptyTitle => 'No support requests';

  @override
  String get supportEmptyBody =>
      'Have a question or a problem? Send us a message and the Kaalmo team will help.';

  @override
  String supportReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusInProgress => 'In progress';

  @override
  String get supportStatusResolved => 'Resolved';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get supportNewSubtitle =>
      'Describe your question or problem. Include the campaign name if it\'s about a specific campaign.';

  @override
  String get supportSubjectLabel => 'Subject';

  @override
  String supportSubjectInvalid(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get supportMessageLabel => 'Message';

  @override
  String get supportMessageHint => 'Tell us what\'s going on…';

  @override
  String supportMessageInvalid(int min) {
    return 'Use at least $min characters.';
  }

  @override
  String get supportSend => 'Send';

  @override
  String get supportTicketCreated => 'Your request has been sent.';

  @override
  String get supportTicketTitle => 'Support request';

  @override
  String get supportTicketClosed =>
      'This request is closed. Start a new one if you still need help.';

  @override
  String get supportAuthorYou => 'You';

  @override
  String get supportAuthorSupport => 'Kaalmo support';

  @override
  String get supportReplyHint => 'Write a reply…';

  @override
  String get invitesTitle => 'Campaign invitations';

  @override
  String get invitesErrorTitle => 'Couldn\'t load your invitations';

  @override
  String get invitesEmptyTitle => 'No invitations';

  @override
  String get invitesEmptyBody =>
      'When an organizer invites you to help manage a campaign, it will show up here.';

  @override
  String get invitesUnknownCampaign => 'A campaign';

  @override
  String invitesFrom(Object name) {
    return '$name invited you to co-organize this campaign.';
  }

  @override
  String get invitesGeneric =>
      'You\'ve been invited to co-organize this campaign.';

  @override
  String get invitesAccept => 'Accept invitation';

  @override
  String get invitesAccepted => 'Invitation accepted.';

  @override
  String get pushOpenAction => 'Open';
}
