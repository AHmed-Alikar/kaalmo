import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('so'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Kaalmo'**
  String get appName;

  /// Shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Community fundraising, done right'**
  String get splashTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @authLogIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLogIn;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegister;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPassword;

  /// No description provided for @authLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get authLogOut;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// No description provided for @stateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get stateEmptyTitle;

  /// No description provided for @stateEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When there is something to show, it will appear here.'**
  String get stateEmptyBody;

  /// No description provided for @stateErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get stateErrorTitle;

  /// No description provided for @stateErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get stateErrorGeneric;

  /// No description provided for @stateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stateSuccessTitle;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach Kaalmo right now. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get errorTimeout;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has ended. Please log in again.'**
  String get errorSessionExpired;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSomali.
  ///
  /// In en, this message translates to:
  /// **'Soomaali'**
  String get languageSomali;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to keep supporting your community.'**
  String get authLoginSubtitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Kaalmo to raise funds and give with confidence.'**
  String get authRegisterSubtitle;

  /// No description provided for @fieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get fieldEmail;

  /// No description provided for @fieldEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get fieldEmailHint;

  /// No description provided for @fieldPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get fieldPassword;

  /// No description provided for @fieldPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get fieldPasswordHint;

  /// No description provided for @fieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get fieldConfirmPassword;

  /// No description provided for @fieldFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fieldFullName;

  /// No description provided for @fieldFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name as it should appear'**
  String get fieldFullNameHint;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldPhone;

  /// No description provided for @fieldPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. +252 61 234 5678'**
  String get fieldPhoneHint;

  /// No description provided for @fieldResetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset code'**
  String get fieldResetCode;

  /// No description provided for @fieldVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get fieldVerificationCode;

  /// No description provided for @fieldNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get fieldNewPassword;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationPasswordTooLong.
  ///
  /// In en, this message translates to:
  /// **'Password must be 72 characters or fewer'**
  String get validationPasswordTooLong;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validationPasswordMismatch;

  /// No description provided for @validationNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get validationNameTooShort;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validationPhoneInvalid;

  /// No description provided for @validationCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get validationCodeLength;

  /// No description provided for @validationTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms to continue'**
  String get validationTermsRequired;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to Kaalmo?'**
  String get authNoAccountPrompt;

  /// No description provided for @authHaveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authHaveAccountPrompt;

  /// No description provided for @authAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to Kaalmo\'s Terms of Service and Privacy Policy.'**
  String get authAcceptTerms;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it below to confirm your email.'**
  String verifyEmailSubtitle(Object email);

  /// No description provided for @verifyEmailAction.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmailAction;

  /// No description provided for @verifyEmailResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyEmailResend;

  /// No description provided for @verifyEmailResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String verifyEmailResendIn(Object seconds);

  /// No description provided for @verifyEmailResent.
  ///
  /// In en, this message translates to:
  /// **'A new code is on its way.'**
  String get verifyEmailResent;

  /// No description provided for @verifyEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Welcome to Kaalmo!'**
  String get verifyEmailSuccess;

  /// No description provided for @verifyEmailAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'This email is already verified.'**
  String get verifyEmailAlreadyVerified;

  /// No description provided for @verifyEmailInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code is incorrect or has expired. Request a new one.'**
  String get verifyEmailInvalidCode;

  /// No description provided for @verifyEmailLater.
  ///
  /// In en, this message translates to:
  /// **'I\'ll do this later'**
  String get verifyEmailLater;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email for your account and we\'ll send a reset code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Send reset code'**
  String get forgotPasswordAction;

  /// No description provided for @forgotPasswordSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotPasswordSentTitle;

  /// No description provided for @forgotPasswordSentBody.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that address, a 6-digit reset code has been sent. It expires in 15 minutes.'**
  String get forgotPasswordSentBody;

  /// No description provided for @forgotPasswordEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter reset code'**
  String get forgotPasswordEnterCode;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your email and a new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @resetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPasswordAction;

  /// No description provided for @resetPasswordInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'This reset code is invalid or has expired. Request a new one.'**
  String get resetPasswordInvalidCode;

  /// No description provided for @resetPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get resetPasswordSuccessTitle;

  /// No description provided for @resetPasswordSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed. Please log in with your new password.'**
  String get resetPasswordSuccessBody;

  /// No description provided for @resetPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to log in'**
  String get resetPasswordBackToLogin;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to continue.'**
  String get logoutConfirmBody;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorAccountDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account is suspended. Contact support if you think this is a mistake.'**
  String get errorAccountDisabled;

  /// No description provided for @errorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account with this email or phone already exists.'**
  String get errorAccountExists;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please wait a little and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorEmailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the email. Please try again shortly.'**
  String get errorEmailSendFailed;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(Object name);

  /// No description provided for @homeGreetingGeneric.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreetingGeneric;

  /// No description provided for @homeGreetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find a cause worth supporting today.'**
  String get homeGreetingSubtitle;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search campaigns'**
  String get homeSearchHint;

  /// No description provided for @homeFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get homeFeatured;

  /// No description provided for @homeCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get homeCategories;

  /// No description provided for @homeRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent campaigns'**
  String get homeRecent;

  /// No description provided for @homeViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Verified campaigns will appear here as soon as they\'re published.'**
  String get homeEmptyBody;

  /// No description provided for @statsRaised.
  ///
  /// In en, this message translates to:
  /// **'Total raised'**
  String get statsRaised;

  /// No description provided for @statsCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get statsCampaigns;

  /// No description provided for @statsDonors.
  ///
  /// In en, this message translates to:
  /// **'Donors'**
  String get statsDonors;

  /// No description provided for @exploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreTitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by title or story'**
  String get exploreSearchHint;

  /// No description provided for @exploreNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching campaigns'**
  String get exploreNoResultsTitle;

  /// No description provided for @exploreNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear your filters.'**
  String get exploreNoResultsBody;

  /// No description provided for @exploreEndOfList.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the end'**
  String get exploreEndOfList;

  /// No description provided for @campaignCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get campaignCompleted;

  /// No description provided for @regionAll.
  ///
  /// In en, this message translates to:
  /// **'All regions'**
  String get regionAll;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get categoryMedical;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get categoryEmergency;

  /// No description provided for @categoryFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get categoryFamily;

  /// No description provided for @categoryFuneral.
  ///
  /// In en, this message translates to:
  /// **'Funeral'**
  String get categoryFuneral;

  /// No description provided for @categoryCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get categoryCommunity;

  /// No description provided for @categoryMosque.
  ///
  /// In en, this message translates to:
  /// **'Mosque'**
  String get categoryMosque;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryOrphanSupport.
  ///
  /// In en, this message translates to:
  /// **'Orphan support'**
  String get categoryOrphanSupport;

  /// No description provided for @categoryDisasterRelief.
  ///
  /// In en, this message translates to:
  /// **'Disaster relief'**
  String get categoryDisasterRelief;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryNgo.
  ///
  /// In en, this message translates to:
  /// **'NGO'**
  String get categoryNgo;

  /// No description provided for @categoryPublicProjects.
  ///
  /// In en, this message translates to:
  /// **'Public projects'**
  String get categoryPublicProjects;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @campaignLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this campaign'**
  String get campaignLoadErrorTitle;

  /// No description provided for @campaignStory.
  ///
  /// In en, this message translates to:
  /// **'Story'**
  String get campaignStory;

  /// No description provided for @campaignStoryUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The organizer hasn\'t added a story yet.'**
  String get campaignStoryUnavailable;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @campaignRaisedAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} raised'**
  String campaignRaisedAmount(Object amount);

  /// No description provided for @campaignOfGoal.
  ///
  /// In en, this message translates to:
  /// **'of {goal} goal'**
  String campaignOfGoal(Object goal);

  /// No description provided for @campaignFundedPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% funded'**
  String campaignFundedPercent(Object percent);

  /// No description provided for @campaignSupportersLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 supporter} other{{count} supporters}} · {percent}% funded'**
  String campaignSupportersLine(int count, int percent);

  /// No description provided for @campaignEnded.
  ///
  /// In en, this message translates to:
  /// **'This campaign has ended'**
  String get campaignEnded;

  /// No description provided for @campaignEndsToday.
  ///
  /// In en, this message translates to:
  /// **'Ends today'**
  String get campaignEndsToday;

  /// No description provided for @campaignDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String campaignDaysLeft(int days);

  /// No description provided for @trustSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get trustSectionTitle;

  /// No description provided for @badgeIdentityVerified.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get badgeIdentityVerified;

  /// No description provided for @badgeBeneficiaryVerified.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary verified'**
  String get badgeBeneficiaryVerified;

  /// No description provided for @badgeOrganizationVerified.
  ///
  /// In en, this message translates to:
  /// **'Organization verified'**
  String get badgeOrganizationVerified;

  /// No description provided for @badgePaymentVerified.
  ///
  /// In en, this message translates to:
  /// **'Payment verified'**
  String get badgePaymentVerified;

  /// No description provided for @galleryCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String galleryCounter(int current, int total);

  /// No description provided for @galleryMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} photos'**
  String galleryMoreCount(int count);

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get statusUnderReview;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get statusPublished;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get statusGoalReached;

  /// No description provided for @statusWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Funds being withdrawn'**
  String get statusWithdrawal;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get statusFrozen;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusExpired;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get statusRejected;

  /// No description provided for @statusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Status unavailable'**
  String get statusUnavailable;

  /// No description provided for @statusBannerCompleted.
  ///
  /// In en, this message translates to:
  /// **'This campaign is complete. You can still read its story and updates.'**
  String get statusBannerCompleted;

  /// No description provided for @statusBannerGoalReached.
  ///
  /// In en, this message translates to:
  /// **'This campaign has reached its goal. Thank you to everyone who gave.'**
  String get statusBannerGoalReached;

  /// No description provided for @statusBannerSuspended.
  ///
  /// In en, this message translates to:
  /// **'This campaign is under review and is not accepting support right now.'**
  String get statusBannerSuspended;

  /// No description provided for @statusBannerFrozen.
  ///
  /// In en, this message translates to:
  /// **'This campaign is temporarily frozen while it is reviewed.'**
  String get statusBannerFrozen;

  /// No description provided for @statusBannerCancelled.
  ///
  /// In en, this message translates to:
  /// **'This campaign was cancelled by the organizer.'**
  String get statusBannerCancelled;

  /// No description provided for @statusBannerExpired.
  ///
  /// In en, this message translates to:
  /// **'This campaign has ended and is no longer active.'**
  String get statusBannerExpired;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @reportAction.
  ///
  /// In en, this message translates to:
  /// **'Report campaign'**
  String get reportAction;

  /// No description provided for @donateComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donateComingSoon;

  /// No description provided for @donationsClosed.
  ///
  /// In en, this message translates to:
  /// **'Donations closed'**
  String get donationsClosed;

  /// No description provided for @campaignUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get campaignUpdates;

  /// No description provided for @updateFromOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Update from the organizer'**
  String get updateFromOrganizer;

  /// No description provided for @updatesEmpty.
  ///
  /// In en, this message translates to:
  /// **'The organizer hasn\'t posted any updates yet.'**
  String get updatesEmpty;

  /// No description provided for @updatesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No updates yet'**
  String get updatesEmptyTitle;

  /// No description provided for @updatesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load updates.'**
  String get updatesLoadError;

  /// No description provided for @seeAllUpdates.
  ///
  /// In en, this message translates to:
  /// **'See all {count} updates'**
  String seeAllUpdates(int count);

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @commentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a message of support.'**
  String get commentsEmpty;

  /// No description provided for @commentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// No description provided for @commentAuthorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get commentAuthorYou;

  /// No description provided for @commentAuthorSupporter.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get commentAuthorSupporter;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write a message of support…'**
  String get commentHint;

  /// No description provided for @commentSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commentSend;

  /// No description provided for @commentSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to add a comment'**
  String get commentSignInPrompt;

  /// No description provided for @supporters.
  ///
  /// In en, this message translates to:
  /// **'Supporters'**
  String get supporters;

  /// No description provided for @supporterAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get supporterAnonymous;

  /// No description provided for @supportersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No confirmed donations yet.'**
  String get supportersEmpty;

  /// No description provided for @supportersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No supporters yet'**
  String get supportersEmptyTitle;

  /// No description provided for @supportersLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load supporters.'**
  String get supportersLoadError;

  /// No description provided for @supportersCountHeadline.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 supporter} other{{count} supporters}}'**
  String supportersCountHeadline(int count);

  /// No description provided for @supportersRecentOnly.
  ///
  /// In en, this message translates to:
  /// **'Showing the most recent supporters.'**
  String get supportersRecentOnly;

  /// No description provided for @seeAllSupporters.
  ///
  /// In en, this message translates to:
  /// **'See all {count} supporters'**
  String seeAllSupporters(int count);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this campaign'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your report goes to the Kaalmo team for review. It stays private.'**
  String get reportSubtitle;

  /// No description provided for @reportReasonScam.
  ///
  /// In en, this message translates to:
  /// **'Scam or fraud'**
  String get reportReasonScam;

  /// No description provided for @reportReasonFalseInfo.
  ///
  /// In en, this message translates to:
  /// **'False or misleading information'**
  String get reportReasonFalseInfo;

  /// No description provided for @reportReasonMisuse.
  ///
  /// In en, this message translates to:
  /// **'Misuse of funds'**
  String get reportReasonMisuse;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate campaign'**
  String get reportReasonDuplicate;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get reportReasonOther;

  /// No description provided for @reportExplanationLabel.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)'**
  String get reportExplanationLabel;

  /// No description provided for @reportExplanationHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you noticed'**
  String get reportExplanationHint;

  /// No description provided for @reportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get reportSubmit;

  /// No description provided for @reportSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Report received'**
  String get reportSuccessTitle;

  /// No description provided for @reportSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you. The Kaalmo team will review this campaign.'**
  String get reportSuccessBody;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'You need an account to {action} this campaign.'**
  String loginRequiredBody(Object action);

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);

  /// No description provided for @donateTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donateTitle;

  /// No description provided for @donateActionLabel.
  ///
  /// In en, this message translates to:
  /// **'donate to'**
  String get donateActionLabel;

  /// No description provided for @donateLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to donate'**
  String get donateLoginTitle;

  /// No description provided for @donateLoginBody.
  ///
  /// In en, this message translates to:
  /// **'You need a Kaalmo account so we can send your receipt and confirm your donation.'**
  String get donateLoginBody;

  /// No description provided for @donateAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose an amount'**
  String get donateAmountLabel;

  /// No description provided for @donateCustomAmount.
  ///
  /// In en, this message translates to:
  /// **'Other amount'**
  String get donateCustomAmount;

  /// No description provided for @donateAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get donateAmountInvalid;

  /// No description provided for @donateAmountTooLow.
  ///
  /// In en, this message translates to:
  /// **'The minimum donation is {amount}.'**
  String donateAmountTooLow(Object amount);

  /// No description provided for @donateAmountTooHigh.
  ///
  /// In en, this message translates to:
  /// **'That is above the maximum of {amount}.'**
  String donateAmountTooHigh(Object amount);

  /// No description provided for @donateMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message (optional)'**
  String get donateMessageLabel;

  /// No description provided for @donateMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Add a word of encouragement…'**
  String get donateMessageHint;

  /// No description provided for @donateMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Your message is a little too long.'**
  String get donateMessageTooLong;

  /// No description provided for @donateAnonymousTitle.
  ///
  /// In en, this message translates to:
  /// **'Donate anonymously'**
  String get donateAnonymousTitle;

  /// No description provided for @donateAnonymousSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your name won\'t be shown publicly on this campaign.'**
  String get donateAnonymousSubtitle;

  /// No description provided for @donateAnonymousYes.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get donateAnonymousYes;

  /// No description provided for @donateAnonymousNo.
  ///
  /// In en, this message translates to:
  /// **'Name shown'**
  String get donateAnonymousNo;

  /// No description provided for @donateContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get donateContinue;

  /// No description provided for @donateReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your donation'**
  String get donateReviewTitle;

  /// No description provided for @donateReviewAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get donateReviewAmount;

  /// No description provided for @donateReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get donateReviewMessage;

  /// No description provided for @donateReviewNoMessage.
  ///
  /// In en, this message translates to:
  /// **'No message'**
  String get donateReviewNoMessage;

  /// No description provided for @donateReviewAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get donateReviewAnonymous;

  /// No description provided for @donatePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get donatePaymentMethod;

  /// No description provided for @donatePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number'**
  String get donatePhoneLabel;

  /// No description provided for @donatePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 0612345678'**
  String get donatePhoneHint;

  /// No description provided for @donatePhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number.'**
  String get donatePhoneInvalid;

  /// No description provided for @donateFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get donateFees;

  /// No description provided for @donateFeesNone.
  ///
  /// In en, this message translates to:
  /// **'No fees'**
  String get donateFeesNone;

  /// No description provided for @donateTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get donateTotal;

  /// No description provided for @donateSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Kaalmo confirms every payment with the provider before your donation counts.'**
  String get donateSecurityNote;

  /// No description provided for @donateConfirm.
  ///
  /// In en, this message translates to:
  /// **'Donate {amount}'**
  String donateConfirm(Object amount);

  /// No description provided for @donateEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit donation'**
  String get donateEdit;

  /// No description provided for @donateProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing your donation'**
  String get donateProcessingTitle;

  /// No description provided for @donateProcessingBody.
  ///
  /// In en, this message translates to:
  /// **'Please wait — we\'re confirming your payment with the provider.'**
  String get donateProcessingBody;

  /// No description provided for @donatePendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your payment is being processed'**
  String get donatePendingTitle;

  /// No description provided for @donatePendingBody.
  ///
  /// In en, this message translates to:
  /// **'This can take a little while. We\'ll update the campaign as soon as it is confirmed — you don\'t need to pay again.'**
  String get donatePendingBody;

  /// No description provided for @donateFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation not completed'**
  String get donateFailedTitle;

  /// No description provided for @donateFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Your payment could not be completed. You have not been charged.'**
  String get donateFailedGeneric;

  /// No description provided for @donateRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get donateRetry;

  /// No description provided for @donateSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support'**
  String get donateSuccessTitle;

  /// No description provided for @donateSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your donation of {amount} is confirmed.'**
  String donateSuccessBody(Object amount);

  /// No description provided for @donateBackToCampaign.
  ///
  /// In en, this message translates to:
  /// **'Back to campaign'**
  String get donateBackToCampaign;

  /// No description provided for @payMethodEvcPlusTitle.
  ///
  /// In en, this message translates to:
  /// **'EVC Plus'**
  String get payMethodEvcPlusTitle;

  /// No description provided for @payMethodEvcPlusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile money — pay from your phone'**
  String get payMethodEvcPlusSubtitle;

  /// No description provided for @payMethodManualTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash / offline'**
  String get payMethodManualTitle;

  /// No description provided for @payMethodManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded now and confirmed by the Kaalmo team'**
  String get payMethodManualSubtitle;

  /// No description provided for @payMethodBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get payMethodBankTitle;

  /// No description provided for @payMethodBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay from your bank account'**
  String get payMethodBankSubtitle;

  /// No description provided for @payMethodCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get payMethodCardTitle;

  /// No description provided for @payMethodCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Debit or credit card'**
  String get payMethodCardSubtitle;

  /// No description provided for @payMethodGenericSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supported payment method'**
  String get payMethodGenericSubtitle;

  /// No description provided for @payNoMethods.
  ///
  /// In en, this message translates to:
  /// **'No payment methods are available right now. Please try again later.'**
  String get payNoMethods;

  /// No description provided for @receiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation receipt'**
  String get receiptTitle;

  /// No description provided for @receiptCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get receiptCampaign;

  /// No description provided for @receiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get receiptAmount;

  /// No description provided for @receiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get receiptDate;

  /// No description provided for @receiptMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get receiptMethod;

  /// No description provided for @receiptVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get receiptVisibility;

  /// No description provided for @receiptReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get receiptReference;

  /// No description provided for @receiptMessage.
  ///
  /// In en, this message translates to:
  /// **'Your message'**
  String get receiptMessage;

  /// No description provided for @errorCampaignNotOpen.
  ///
  /// In en, this message translates to:
  /// **'This campaign is not currently open for donations.'**
  String get errorCampaignNotOpen;

  /// No description provided for @myDonationsTitle.
  ///
  /// In en, this message translates to:
  /// **'My donations'**
  String get myDonationsTitle;

  /// No description provided for @myDonationsActionLabel.
  ///
  /// In en, this message translates to:
  /// **'see your donations'**
  String get myDonationsActionLabel;

  /// No description provided for @myDonationsLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your donations'**
  String get myDonationsLoginTitle;

  /// No description provided for @myDonationsLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Your donation history is linked to your Kaalmo account.'**
  String get myDonationsLoginBody;

  /// No description provided for @myDonationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your donations'**
  String get myDonationsErrorTitle;

  /// No description provided for @myDonationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No donations yet'**
  String get myDonationsEmptyTitle;

  /// No description provided for @myDonationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you support a campaign, it will show up here.'**
  String get myDonationsEmptyBody;

  /// No description provided for @myDonationsExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore campaigns'**
  String get myDonationsExplore;

  /// No description provided for @donationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get donationDetailTitle;

  /// No description provided for @donationCampaignUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Campaign unavailable'**
  String get donationCampaignUnavailable;

  /// No description provided for @donationCampaignRemoved.
  ///
  /// In en, this message translates to:
  /// **'This campaign is no longer available.'**
  String get donationCampaignRemoved;

  /// No description provided for @donationViewCampaign.
  ///
  /// In en, this message translates to:
  /// **'View campaign'**
  String get donationViewCampaign;

  /// No description provided for @donationNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Donation not found'**
  String get donationNotFoundTitle;

  /// No description provided for @donationNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find this donation in your history.'**
  String get donationNotFoundBody;

  /// No description provided for @donationBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to my donations'**
  String get donationBackToList;

  /// No description provided for @donationStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get donationStatusPending;

  /// No description provided for @donationStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get donationStatusConfirmed;

  /// No description provided for @donationStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get donationStatusFailed;

  /// No description provided for @donationStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get donationStatusRefunded;

  /// No description provided for @donationStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get donationStatusUnknown;

  /// No description provided for @receiptStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get receiptStatus;

  /// No description provided for @organizerDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizerDashboardTitle;

  /// No description provided for @organizerNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Not an organizer yet'**
  String get organizerNotAvailableTitle;

  /// No description provided for @organizerNotAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Once your organizer access is approved you can manage campaigns here.'**
  String get organizerNotAvailableBody;

  /// No description provided for @organizerLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your campaigns'**
  String get organizerLoadErrorTitle;

  /// No description provided for @organizerDashboardHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your campaigns at a glance'**
  String get organizerDashboardHeadline;

  /// No description provided for @organizerTotalRaised.
  ///
  /// In en, this message translates to:
  /// **'Total raised across your campaigns'**
  String get organizerTotalRaised;

  /// No description provided for @organizerTotalRaisedNote.
  ///
  /// In en, this message translates to:
  /// **'Confirmed donations only — the backend is the source of truth.'**
  String get organizerTotalRaisedNote;

  /// No description provided for @organizerStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Campaigns'**
  String get organizerStatTotal;

  /// No description provided for @organizerStatLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get organizerStatLive;

  /// No description provided for @organizerStatInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get organizerStatInReview;

  /// No description provided for @organizerStatDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get organizerStatDrafts;

  /// No description provided for @organizerStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get organizerStatCompleted;

  /// No description provided for @organizerStatRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get organizerStatRejected;

  /// No description provided for @organizerRecentCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Recent campaigns'**
  String get organizerRecentCampaigns;

  /// No description provided for @organizerViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get organizerViewAll;

  /// No description provided for @organizerNoCampaignsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any campaigns yet.'**
  String get organizerNoCampaignsYet;

  /// No description provided for @organizerMyCampaignsTitle.
  ///
  /// In en, this message translates to:
  /// **'My campaigns'**
  String get organizerMyCampaignsTitle;

  /// No description provided for @organizerNoCampaignsTitle.
  ///
  /// In en, this message translates to:
  /// **'No campaigns yet'**
  String get organizerNoCampaignsTitle;

  /// No description provided for @organizerNoCampaignsBody.
  ///
  /// In en, this message translates to:
  /// **'Campaigns you create or co-organize will appear here.'**
  String get organizerNoCampaignsBody;

  /// No description provided for @organizerRoleCoOrganizer.
  ///
  /// In en, this message translates to:
  /// **'Co-organizer'**
  String get organizerRoleCoOrganizer;

  /// No description provided for @organizerManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage campaign'**
  String get organizerManageTitle;

  /// No description provided for @organizerRejectedNote.
  ///
  /// In en, this message translates to:
  /// **'This campaign was not approved. Contact support if you\'d like to try again.'**
  String get organizerRejectedNote;

  /// No description provided for @organizerEditReturnsToReview.
  ///
  /// In en, this message translates to:
  /// **'Saving changes will send this campaign back for review before donors see the update.'**
  String get organizerEditReturnsToReview;

  /// No description provided for @organizerActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get organizerActions;

  /// No description provided for @organizerActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit campaign'**
  String get organizerActionEdit;

  /// No description provided for @organizerActionPostUpdate.
  ///
  /// In en, this message translates to:
  /// **'Post an update'**
  String get organizerActionPostUpdate;

  /// No description provided for @organizerActionViewPublic.
  ///
  /// In en, this message translates to:
  /// **'View public page'**
  String get organizerActionViewPublic;

  /// No description provided for @organizerActionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get organizerActionSubmit;

  /// No description provided for @organizerActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel campaign'**
  String get organizerActionCancel;

  /// No description provided for @organizerActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get organizerActionDelete;

  /// No description provided for @organizerSubmitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit for review?'**
  String get organizerSubmitConfirmTitle;

  /// No description provided for @organizerSubmitConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The Kaalmo team will review your campaign before it goes live.'**
  String get organizerSubmitConfirmBody;

  /// No description provided for @organizerSubmitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Campaign submitted for review.'**
  String get organizerSubmitSuccess;

  /// No description provided for @organizerCancelConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this campaign?'**
  String get organizerCancelConfirmTitle;

  /// No description provided for @organizerCancelConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. The campaign will be closed.'**
  String get organizerCancelConfirmBody;

  /// No description provided for @organizerCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Campaign cancelled.'**
  String get organizerCancelSuccess;

  /// No description provided for @organizerDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get organizerDeleteConfirmTitle;

  /// No description provided for @organizerDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The draft will be permanently removed.'**
  String get organizerDeleteConfirmBody;

  /// No description provided for @organizerBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get organizerBeneficiary;

  /// No description provided for @organizerBeneficiaryLinked.
  ///
  /// In en, this message translates to:
  /// **'A beneficiary is linked to this campaign.'**
  String get organizerBeneficiaryLinked;

  /// No description provided for @organizerBeneficiaryNone.
  ///
  /// In en, this message translates to:
  /// **'No beneficiary is linked to this campaign yet.'**
  String get organizerBeneficiaryNone;

  /// No description provided for @organizerTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get organizerTeam;

  /// No description provided for @organizerTeamLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the team list.'**
  String get organizerTeamLoadError;

  /// No description provided for @organizerTeamEmpty.
  ///
  /// In en, this message translates to:
  /// **'No co-organizers on this campaign.'**
  String get organizerTeamEmpty;

  /// No description provided for @organizerTeamAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get organizerTeamAccepted;

  /// No description provided for @organizerTeamPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get organizerTeamPending;

  /// No description provided for @organizerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit campaign'**
  String get organizerEditTitle;

  /// No description provided for @organizerFieldTitleSo.
  ///
  /// In en, this message translates to:
  /// **'Title (Somali)'**
  String get organizerFieldTitleSo;

  /// No description provided for @organizerFieldTitleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (English, optional)'**
  String get organizerFieldTitleEn;

  /// No description provided for @organizerFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get organizerFieldCategory;

  /// No description provided for @organizerFieldRegion.
  ///
  /// In en, this message translates to:
  /// **'Region (optional)'**
  String get organizerFieldRegion;

  /// No description provided for @organizerFieldGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal amount'**
  String get organizerFieldGoal;

  /// No description provided for @organizerFieldStorySo.
  ///
  /// In en, this message translates to:
  /// **'Story (Somali)'**
  String get organizerFieldStorySo;

  /// No description provided for @organizerFieldStoryEn.
  ///
  /// In en, this message translates to:
  /// **'Story (English, optional)'**
  String get organizerFieldStoryEn;

  /// No description provided for @organizerFieldTitleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String organizerFieldTitleTooShort(int min);

  /// No description provided for @organizerFieldTitleTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters.'**
  String organizerFieldTitleTooLong(int max);

  /// No description provided for @organizerFieldStoryTooShort.
  ///
  /// In en, this message translates to:
  /// **'Tell the story in at least {min} characters.'**
  String organizerFieldStoryTooShort(int min);

  /// No description provided for @organizerFieldGoalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a goal amount greater than zero.'**
  String get organizerFieldGoalInvalid;

  /// No description provided for @organizerRegionNone.
  ///
  /// In en, this message translates to:
  /// **'No region'**
  String get organizerRegionNone;

  /// No description provided for @organizerEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Campaign updated.'**
  String get organizerEditSuccess;

  /// No description provided for @organizerEditMediaNote.
  ///
  /// In en, this message translates to:
  /// **'Cover photo and gallery images can\'t be changed from the app yet.'**
  String get organizerEditMediaNote;

  /// No description provided for @organizerSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get organizerSaveChanges;

  /// No description provided for @organizerPostUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Post an update'**
  String get organizerPostUpdateTitle;

  /// No description provided for @organizerPostUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everyone following this campaign will be notified.'**
  String get organizerPostUpdateSubtitle;

  /// No description provided for @organizerUpdateHint.
  ///
  /// In en, this message translates to:
  /// **'Share progress, a thank-you, or what the funds achieved…'**
  String get organizerUpdateHint;

  /// No description provided for @organizerUpdateTooShort.
  ///
  /// In en, this message translates to:
  /// **'Write at least {min} characters.'**
  String organizerUpdateTooShort(int min);

  /// No description provided for @organizerUpdatePosted.
  ///
  /// In en, this message translates to:
  /// **'Update posted.'**
  String get organizerUpdatePosted;

  /// No description provided for @organizerPublishUpdate.
  ///
  /// In en, this message translates to:
  /// **'Publish update'**
  String get organizerPublishUpdate;

  /// No description provided for @beneficiaryDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get beneficiaryDashboardTitle;

  /// No description provided for @beneficiaryLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your beneficiary profile'**
  String get beneficiaryLoadErrorTitle;

  /// No description provided for @beneficiaryStatusNone.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get beneficiaryStatusNone;

  /// No description provided for @beneficiaryStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get beneficiaryStatusPending;

  /// No description provided for @beneficiaryStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get beneficiaryStatusVerified;

  /// No description provided for @beneficiaryStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Not approved'**
  String get beneficiaryStatusRejected;

  /// No description provided for @beneficiaryVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get beneficiaryVerificationTitle;

  /// No description provided for @beneficiaryCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get beneficiaryCheckEmail;

  /// No description provided for @beneficiaryCheckPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get beneficiaryCheckPhone;

  /// No description provided for @beneficiaryCheckIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity verified'**
  String get beneficiaryCheckIdentity;

  /// No description provided for @beneficiaryCheckBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary verified'**
  String get beneficiaryCheckBeneficiary;

  /// No description provided for @beneficiaryNoName.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary profile'**
  String get beneficiaryNoName;

  /// No description provided for @beneficiaryRejectedNote.
  ///
  /// In en, this message translates to:
  /// **'Your beneficiary details were not approved. You can update and resubmit them.'**
  String get beneficiaryRejectedNote;

  /// No description provided for @beneficiaryPendingNote.
  ///
  /// In en, this message translates to:
  /// **'Your details have been submitted and are waiting for review by the Kaalmo team.'**
  String get beneficiaryPendingNote;

  /// No description provided for @beneficiaryStartVerification.
  ///
  /// In en, this message translates to:
  /// **'Start beneficiary verification'**
  String get beneficiaryStartVerification;

  /// No description provided for @beneficiaryUpdateIdentity.
  ///
  /// In en, this message translates to:
  /// **'Update my details'**
  String get beneficiaryUpdateIdentity;

  /// No description provided for @beneficiaryPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Payout account'**
  String get beneficiaryPayoutTitle;

  /// No description provided for @beneficiaryNoPayoutAccount.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added a payout account yet.'**
  String get beneficiaryNoPayoutAccount;

  /// No description provided for @beneficiaryPayoutVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get beneficiaryPayoutVerified;

  /// No description provided for @beneficiaryPayoutUnverified.
  ///
  /// In en, this message translates to:
  /// **'Awaiting verification'**
  String get beneficiaryPayoutUnverified;

  /// No description provided for @beneficiaryAddPayoutButton.
  ///
  /// In en, this message translates to:
  /// **'Add payout account'**
  String get beneficiaryAddPayoutButton;

  /// No description provided for @beneficiaryReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready for withdrawal'**
  String get beneficiaryReadyTitle;

  /// No description provided for @beneficiaryReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Your identity and payout account are verified. Withdrawal requests are handled in a later release.'**
  String get beneficiaryReadyBody;

  /// No description provided for @beneficiaryNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not ready for payout yet'**
  String get beneficiaryNotReadyTitle;

  /// No description provided for @beneficiaryNotReadyVerify.
  ///
  /// In en, this message translates to:
  /// **'Complete beneficiary verification first.'**
  String get beneficiaryNotReadyVerify;

  /// No description provided for @beneficiaryNotReadyLinkage.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified. An admin still needs to link your payout account to your beneficiary profile.'**
  String get beneficiaryNotReadyLinkage;

  /// No description provided for @beneficiaryCampaignLinkNote.
  ///
  /// In en, this message translates to:
  /// **'Linking a beneficiary to a specific campaign is done by the Kaalmo team — there is no self-service option in the app yet.'**
  String get beneficiaryCampaignLinkNote;

  /// No description provided for @beneficiaryIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary details'**
  String get beneficiaryIdentityTitle;

  /// No description provided for @beneficiaryIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your legal name as it appears on your ID. The Kaalmo team verifies it.'**
  String get beneficiaryIdentitySubtitle;

  /// No description provided for @beneficiaryFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full legal name'**
  String get beneficiaryFullNameLabel;

  /// No description provided for @beneficiaryFullNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name (2–100 characters).'**
  String get beneficiaryFullNameInvalid;

  /// No description provided for @beneficiarySubmitIdentity.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get beneficiarySubmitIdentity;

  /// No description provided for @beneficiaryIdentitySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Details submitted for verification.'**
  String get beneficiaryIdentitySubmitted;

  /// No description provided for @beneficiaryAddPayoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Add payout account'**
  String get beneficiaryAddPayoutTitle;

  /// No description provided for @payoutTypeMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get payoutTypeMobileMoney;

  /// No description provided for @payoutTypeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get payoutTypeBank;

  /// No description provided for @beneficiaryProviderLabel.
  ///
  /// In en, this message translates to:
  /// **'Provider name'**
  String get beneficiaryProviderLabel;

  /// No description provided for @beneficiaryProviderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EVC Plus, Salaam Bank'**
  String get beneficiaryProviderHint;

  /// No description provided for @beneficiaryProviderInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the provider name (2–60 characters).'**
  String get beneficiaryProviderInvalid;

  /// No description provided for @beneficiaryAccountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get beneficiaryAccountNumberLabel;

  /// No description provided for @beneficiaryAccountNumberHelper.
  ///
  /// In en, this message translates to:
  /// **'Only the last 4 digits are stored.'**
  String get beneficiaryAccountNumberHelper;

  /// No description provided for @beneficiaryAccountNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid account number (4–30 digits).'**
  String get beneficiaryAccountNumberInvalid;

  /// No description provided for @beneficiaryPayoutAdded.
  ///
  /// In en, this message translates to:
  /// **'Payout account added.'**
  String get beneficiaryPayoutAdded;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsActionLabel.
  ///
  /// In en, this message translates to:
  /// **'see your notifications'**
  String get notificationsActionLabel;

  /// No description provided for @notificationsLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to see your notifications'**
  String get notificationsLoginTitle;

  /// No description provided for @notificationsLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are tied to your Kaalmo account.'**
  String get notificationsLoginBody;

  /// No description provided for @notificationsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your notifications'**
  String get notificationsErrorTitle;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Updates about your donations, campaigns and account will appear here.'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notifKindDonation.
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get notifKindDonation;

  /// No description provided for @notifKindCampaignUpdate.
  ///
  /// In en, this message translates to:
  /// **'Campaign update'**
  String get notifKindCampaignUpdate;

  /// No description provided for @notifKindCampaignStatus.
  ///
  /// In en, this message translates to:
  /// **'Campaign status'**
  String get notifKindCampaignStatus;

  /// No description provided for @notifKindBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary'**
  String get notifKindBeneficiary;

  /// No description provided for @notifKindWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get notifKindWithdrawal;

  /// No description provided for @notifKindTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get notifKindTeam;

  /// No description provided for @notifKindSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get notifKindSupport;

  /// No description provided for @notifKindSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & security'**
  String get notifKindSecurity;

  /// No description provided for @notifKindSystem.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notifKindSystem;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// No description provided for @notFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for isn\'t here.'**
  String get notFoundBody;

  /// No description provided for @notFoundGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get notFoundGoHome;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsApp;

  /// No description provided for @settingsEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get settingsEditName;

  /// No description provided for @settingsFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get settingsFullName;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your name has been updated.'**
  String get settingsNameUpdated;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingsChangePassword;

  /// No description provided for @settingsChangePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, you\'ll be signed out and sent a reset code by email.'**
  String get settingsChangePasswordBody;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsNote.
  ///
  /// In en, this message translates to:
  /// **'Get alerts on your device when push notifications are enabled for your account.'**
  String get settingsPushNotificationsNote;

  /// No description provided for @settingsCloseAccount.
  ///
  /// In en, this message translates to:
  /// **'Close my account'**
  String get settingsCloseAccount;

  /// No description provided for @settingsCloseAccountSubject.
  ///
  /// In en, this message translates to:
  /// **'Please close my Kaalmo account'**
  String get settingsCloseAccountSubject;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Kaalmo'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Community fundraising for Somalia, done right.'**
  String get aboutTagline;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Kaalmo helps people raise and give funds transparently — for medical bills, emergencies, education, mosques, community projects and more. Every campaign is reviewed, and verified beneficiaries receive the funds.'**
  String get aboutBody;

  /// No description provided for @aboutLegalHeading.
  ///
  /// In en, this message translates to:
  /// **'Legal & contact'**
  String get aboutLegalHeading;

  /// No description provided for @aboutTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacy;

  /// No description provided for @aboutContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get supportTitle;

  /// No description provided for @supportNewTicket.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get supportNewTicket;

  /// No description provided for @supportErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your support requests'**
  String get supportErrorTitle;

  /// No description provided for @supportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No support requests'**
  String get supportEmptyTitle;

  /// No description provided for @supportEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Have a question or a problem? Send us a message and the Kaalmo team will help.'**
  String get supportEmptyBody;

  /// No description provided for @supportReplyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String supportReplyCount(int count);

  /// No description provided for @supportStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get supportStatusOpen;

  /// No description provided for @supportStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get supportStatusInProgress;

  /// No description provided for @supportStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get supportStatusResolved;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your question or problem. Include the campaign name if it\'s about a specific campaign.'**
  String get supportNewSubtitle;

  /// No description provided for @supportSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubjectLabel;

  /// No description provided for @supportSubjectInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String supportSubjectInvalid(int min);

  /// No description provided for @supportMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessageLabel;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what\'s going on…'**
  String get supportMessageHint;

  /// No description provided for @supportMessageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use at least {min} characters.'**
  String supportMessageInvalid(int min);

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportSend;

  /// No description provided for @supportTicketCreated.
  ///
  /// In en, this message translates to:
  /// **'Your request has been sent.'**
  String get supportTicketCreated;

  /// No description provided for @supportTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Support request'**
  String get supportTicketTitle;

  /// No description provided for @supportTicketClosed.
  ///
  /// In en, this message translates to:
  /// **'This request is closed. Start a new one if you still need help.'**
  String get supportTicketClosed;

  /// No description provided for @supportAuthorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get supportAuthorYou;

  /// No description provided for @supportAuthorSupport.
  ///
  /// In en, this message translates to:
  /// **'Kaalmo support'**
  String get supportAuthorSupport;

  /// No description provided for @supportReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get supportReplyHint;

  /// No description provided for @invitesTitle.
  ///
  /// In en, this message translates to:
  /// **'Campaign invitations'**
  String get invitesTitle;

  /// No description provided for @invitesErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your invitations'**
  String get invitesErrorTitle;

  /// No description provided for @invitesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No invitations'**
  String get invitesEmptyTitle;

  /// No description provided for @invitesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When an organizer invites you to help manage a campaign, it will show up here.'**
  String get invitesEmptyBody;

  /// No description provided for @invitesUnknownCampaign.
  ///
  /// In en, this message translates to:
  /// **'A campaign'**
  String get invitesUnknownCampaign;

  /// No description provided for @invitesFrom.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to co-organize this campaign.'**
  String invitesFrom(Object name);

  /// No description provided for @invitesGeneric.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited to co-organize this campaign.'**
  String get invitesGeneric;

  /// No description provided for @invitesAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept invitation'**
  String get invitesAccept;

  /// No description provided for @invitesAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted.'**
  String get invitesAccepted;

  /// No description provided for @pushOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pushOpenAction;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'so':
      return AppL10nSo();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
