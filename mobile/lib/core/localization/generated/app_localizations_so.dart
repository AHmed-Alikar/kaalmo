// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppL10nSo extends AppL10n {
  AppL10nSo([String locale = 'so']) : super(locale);

  @override
  String get appName => 'Kaalmo';

  @override
  String get splashTagline => 'Aruurinta lacagta bulshada, si hufan';

  @override
  String get navHome => 'Guriga';

  @override
  String get navExplore => 'Sahamin';

  @override
  String get navNotifications => 'Ogeysiisyo';

  @override
  String get navProfile => 'Profile-ka';

  @override
  String get actionContinue => 'Sii wad';

  @override
  String get actionCancel => 'Jooji';

  @override
  String get actionRetry => 'Isku day mar kale';

  @override
  String get actionSave => 'Kaydi';

  @override
  String get actionClose => 'Xir';

  @override
  String get authLogIn => 'Gal';

  @override
  String get authRegister => 'Akoon samee';

  @override
  String get authForgotPassword => 'Furaha sirta ah ma illowday?';

  @override
  String get authResetPassword => 'Dib u deji furaha sirta ah';

  @override
  String get authLogOut => 'Ka bax';

  @override
  String get stateLoading => 'Waa la soo rarayaa…';

  @override
  String get stateEmptyTitle => 'Weli waxba halkan ma jiraan';

  @override
  String get stateEmptyBody =>
      'Marka wax la tuso jiro, halkan ayay ka soo bixi doonaan.';

  @override
  String get stateErrorTitle => 'Wax baa qaldamay';

  @override
  String get stateErrorGeneric =>
      'Fadlan hubi xiriirkaaga oo isku day mar kale.';

  @override
  String get stateSuccessTitle => 'Waa la sameeyay';

  @override
  String get errorNetwork => 'Hadda lama gaari karo Kaalmo. Hubi xiriirkaaga.';

  @override
  String get errorTimeout =>
      'Codsigu wakhti badan ayuu qaatay. Fadlan isku day mar kale.';

  @override
  String get errorUnexpected => 'Wax baa qaldamay. Fadlan isku day mar kale.';

  @override
  String get errorSessionExpired =>
      'Fadhigaagu wuu dhammaaday. Fadlan mar kale gal.';

  @override
  String get settingsLanguage => 'Luqadda';

  @override
  String get languageSomali => 'Soomaali';

  @override
  String get languageEnglish => 'English';

  @override
  String get authWelcomeBack => 'Ku soo dhawoow';

  @override
  String get authLoginSubtitle =>
      'Gal si aad u sii wadato taageerada bulshadaada.';

  @override
  String get authRegisterTitle => 'Samee akoonkaaga';

  @override
  String get authRegisterSubtitle =>
      'Ku biir Kaalmo si aad lacag ugu aruuriso oo si kalsooni leh u bixiso.';

  @override
  String get fieldEmail => 'Cinwaanka iimaylka';

  @override
  String get fieldEmailHint => 'adiga@tusaale.com';

  @override
  String get fieldPassword => 'Furaha sirta ah';

  @override
  String get fieldPasswordHint => 'Ugu yaraan 8 xaraf';

  @override
  String get fieldConfirmPassword => 'Xaqiiji furaha sirta ah';

  @override
  String get fieldFullName => 'Magaca oo dhan';

  @override
  String get fieldFullNameHint => 'Magacaaga sida uu u muuqan doono';

  @override
  String get fieldPhone => 'Lambarka taleefanka';

  @override
  String get fieldPhoneHint => 'tusaale +252 61 234 5678';

  @override
  String get fieldResetCode => 'Lambarka dib-u-dejinta';

  @override
  String get fieldVerificationCode => 'Lambarka xaqiijinta';

  @override
  String get fieldNewPassword => 'Fure cusub';

  @override
  String get validationRequired => 'Goobtan waa loo baahan yahay';

  @override
  String get validationEmailInvalid => 'Geli cinwaan iimayl oo sax ah';

  @override
  String get validationPasswordTooShort =>
      'Furaha waa inuu ahaadaa ugu yaraan 8 xaraf';

  @override
  String get validationPasswordTooLong =>
      'Furaha waa inuu ahaadaa 72 xaraf ama ka yar';

  @override
  String get validationPasswordMismatch => 'Furayaashu isku mid ma aha';

  @override
  String get validationNameTooShort => 'Geli magacaaga oo dhan';

  @override
  String get validationPhoneInvalid => 'Geli lambar taleefan oo sax ah';

  @override
  String get validationCodeLength => 'Geli lambarka 6-god ah';

  @override
  String get validationTermsRequired =>
      'Fadlan aqbal shuruudaha si aad u sii wadato';

  @override
  String get authNoAccountPrompt => 'Ma cusub tahay Kaalmo?';

  @override
  String get authHaveAccountPrompt => 'Horeba akoon ma leedahay?';

  @override
  String get authAcceptTerms =>
      'Waxaan aqbalayaa Shuruudaha Adeegga iyo Siyaasadda Asturnaanta ee Kaalmo.';

  @override
  String get verifyEmailTitle => 'Xaqiiji iimaylkaaga';

  @override
  String verifyEmailSubtitle(Object email) {
    return 'Waxaan u dirnay lambar 6-god ah $email. Halkan hoose geli si aad u xaqiijiso iimaylkaaga.';
  }

  @override
  String get verifyEmailAction => 'Xaqiiji iimaylka';

  @override
  String get verifyEmailResend => 'Dib u dir lambarka';

  @override
  String verifyEmailResendIn(Object seconds) {
    return 'Dib u dir lambarka ${seconds}s gudahood';
  }

  @override
  String get verifyEmailResent => 'Lambar cusub ayaa soo socda.';

  @override
  String get verifyEmailSuccess =>
      'Iimaylka waa la xaqiijiyay. Ku soo dhawoow Kaalmo!';

  @override
  String get verifyEmailAlreadyVerified =>
      'Iimaylkan horeba waa la xaqiijiyay.';

  @override
  String get verifyEmailInvalidCode =>
      'Lambarku waa qaldan yahay ama wuu dhacay. Codso mid cusub.';

  @override
  String get verifyEmailLater => 'Mar dambe ayaan samayn';

  @override
  String get forgotPasswordTitle => 'Dib u deji furahaaga';

  @override
  String get forgotPasswordSubtitle =>
      'Geli iimaylka akoonkaaga waxaanan kuu soo diri doonaa lambar dib-u-dejin.';

  @override
  String get forgotPasswordAction => 'Dir lambarka dib-u-dejinta';

  @override
  String get forgotPasswordSentTitle => 'Hubi iimaylkaaga';

  @override
  String get forgotPasswordSentBody =>
      'Haddii akoon u jiro cinwaankaas, lambar 6-god ah oo dib-u-dejin ah ayaa la diray. Wuxuu dhacayaa 15 daqiiqo gudahood.';

  @override
  String get forgotPasswordEnterCode => 'Geli lambarka dib-u-dejinta';

  @override
  String get resetPasswordTitle => 'Dooro fure cusub';

  @override
  String get resetPasswordSubtitle =>
      'Geli lambarka iimaylkaaga iyo fure cusub.';

  @override
  String get resetPasswordAction => 'Dib u deji furaha';

  @override
  String get resetPasswordInvalidCode =>
      'Lambarkan dib-u-dejintu waa qaldan yahay ama wuu dhacay. Codso mid cusub.';

  @override
  String get resetPasswordSuccessTitle => 'Furaha waa la cusboonaysiiyay';

  @override
  String get resetPasswordSuccessBody =>
      'Furahaaga waa la beddelay. Fadlan ku gal furahaaga cusub.';

  @override
  String get resetPasswordBackToLogin => 'Ku noqo galitaanka';

  @override
  String get logoutConfirmTitle => 'Ma ka baxaysaa?';

  @override
  String get logoutConfirmBody =>
      'Waxaad u baahan doontaa inaad mar kale gasho si aad u sii wadato.';

  @override
  String get errorInvalidCredentials =>
      'Iimaylka ama furaha sirta ah waa qaldan yahay.';

  @override
  String get errorAccountDisabled =>
      'Akoonkan waa la joojiyay. La xiriir taageerada haddii aad u malaynayso in tani qalad tahay.';

  @override
  String get errorAccountExists =>
      'Akoon leh iimaylkan ama taleefankan horeba wuu jiraa.';

  @override
  String get errorRateLimited =>
      'Isku dayo badan. Fadlan wax yar sug oo isku day mar kale.';

  @override
  String get errorEmailSendFailed =>
      'Ma dirin karin iimaylka. Fadlan isku day mar kale wax yar kadib.';

  @override
  String homeGreeting(Object name) {
    return 'Salaan, $name';
  }

  @override
  String get homeGreetingGeneric => 'Ku soo dhawoow';

  @override
  String get homeGreetingSubtitle =>
      'Maanta hel sabab u qalanta in la taageero.';

  @override
  String get homeSearchHint => 'Raadi ololayaal';

  @override
  String get homeFeatured => 'La soo hordhigay';

  @override
  String get homeCategories => 'Qaybaha';

  @override
  String get homeRecent => 'Ololayaasha dhow';

  @override
  String get homeViewAll => 'Dhammaan arag';

  @override
  String get homeEmptyTitle => 'Weli ma jiraan ololayaal';

  @override
  String get homeEmptyBody =>
      'Ololayaasha la xaqiijiyay ayaa halkan ka soo bixi doona marka la daabaco.';

  @override
  String get statsRaised => 'Wadarta la aruuriyay';

  @override
  String get statsCampaigns => 'Ololayaal';

  @override
  String get statsDonors => 'Deeqbixiyayaal';

  @override
  String get exploreTitle => 'Sahamin';

  @override
  String get exploreSearchHint => 'Ku raadi cinwaan ama sheeko';

  @override
  String get exploreNoResultsTitle => 'Ma jiraan ololayaal u dhigma';

  @override
  String get exploreNoResultsBody =>
      'Isku day raadin kale ama nadiifi shaandhaynta.';

  @override
  String get exploreEndOfList => 'Waxaad gaadhay dhammaadka';

  @override
  String get campaignCompleted => 'Dhammaystiran';

  @override
  String get regionAll => 'Dhammaan gobollada';

  @override
  String get categoryAll => 'Dhammaan';

  @override
  String get categoryMedical => 'Caafimaad';

  @override
  String get categoryEducation => 'Waxbarasho';

  @override
  String get categoryEmergency => 'Degdeg';

  @override
  String get categoryFamily => 'Qoys';

  @override
  String get categoryFuneral => 'Aas';

  @override
  String get categoryCommunity => 'Bulsho';

  @override
  String get categoryMosque => 'Masjid';

  @override
  String get categorySchool => 'Iskuul';

  @override
  String get categoryOrphanSupport => 'Taageero agoon';

  @override
  String get categoryDisasterRelief => 'Gargaar musiibo';

  @override
  String get categoryBusiness => 'Ganacsi';

  @override
  String get categoryNgo => 'NGO';

  @override
  String get categoryPublicProjects => 'Mashaariic dadweyne';

  @override
  String get categoryOther => 'Kale';

  @override
  String get campaignLoadErrorTitle => 'Ololahan lama soo rari karin';

  @override
  String get campaignStory => 'Sheekada';

  @override
  String get campaignStoryUnavailable => 'Abaabulaha weli sheeko kuma darin.';

  @override
  String get readMore => 'Akhri wax badan';

  @override
  String get showLess => 'Muuji wax yar';

  @override
  String campaignRaisedAmount(Object amount) {
    return '$amount la aruuriyay';
  }

  @override
  String campaignOfGoal(Object goal) {
    return 'ka mid ah $goal bartilmaameed';
  }

  @override
  String campaignFundedPercent(Object percent) {
    return '$percent% la buuxiyay';
  }

  @override
  String campaignSupportersLine(int count, int percent) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taageerayaal',
      one: '1 taageere',
    );
    return '$_temp0 · $percent% la buuxiyay';
  }

  @override
  String get campaignEnded => 'Ololahan wuu dhammaaday';

  @override
  String get campaignEndsToday => 'Maanta ayuu dhammaanayaa';

  @override
  String campaignDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days maalmood ayaa hadhay',
      one: '1 maalmood ayaa hadhay',
    );
    return '$_temp0';
  }

  @override
  String get trustSectionTitle => 'Xaqiijin';

  @override
  String get badgeIdentityVerified => 'Aqoonsi la xaqiijiyay';

  @override
  String get badgeBeneficiaryVerified => 'Faa\'iidaystaha la xaqiijiyay';

  @override
  String get badgeOrganizationVerified => 'Hay\'ad la xaqiijiyay';

  @override
  String get badgePaymentVerified => 'Lacag-bixin la xaqiijiyay';

  @override
  String galleryCounter(int current, int total) {
    return '$current ka mid ah $total';
  }

  @override
  String galleryMoreCount(int count) {
    return '+$count sawir';
  }

  @override
  String get statusDraft => 'Qabyo';

  @override
  String get statusSubmitted => 'La gudbiyay';

  @override
  String get statusUnderReview => 'Dib-u-eegis ku jira';

  @override
  String get statusApproved => 'La ansixiyay';

  @override
  String get statusPublished => 'La daabacay';

  @override
  String get statusActive => 'Firfircoon';

  @override
  String get statusGoalReached => 'Bartilmaameedka la gaadhay';

  @override
  String get statusWithdrawal => 'Lacagta waa la saarayaa';

  @override
  String get statusCompleted => 'Dhammaystiran';

  @override
  String get statusSuspended => 'La joojiyay';

  @override
  String get statusFrozen => 'La barafeeyay';

  @override
  String get statusCancelled => 'La joojiyay';

  @override
  String get statusExpired => 'Dhammaaday';

  @override
  String get statusRejected => 'Lama ansixin';

  @override
  String get statusUnavailable => 'Xaalad lama hayo';

  @override
  String get statusBannerCompleted =>
      'Ololahani wuu dhammaystiran yahay. Weli waad akhrisan kartaa sheekadiisa iyo cusboonaysiintiisa.';

  @override
  String get statusBannerGoalReached =>
      'Ololahani wuxuu gaadhay bartilmaameedkiisa. Mahadsanid dhammaan kuwii bixiyay.';

  @override
  String get statusBannerSuspended =>
      'Ololahani waa dib-u-eegis, hadda taageero ma aqbalayo.';

  @override
  String get statusBannerFrozen =>
      'Ololahani wuu barafoobay muddo ah inta la dib-u-eegayo.';

  @override
  String get statusBannerCancelled => 'Ololahan waxaa joojiyay abaabulaha.';

  @override
  String get statusBannerExpired =>
      'Ololahan wuu dhammaaday, mana firfircoona.';

  @override
  String get follow => 'Raac';

  @override
  String get following => 'Waad raacaysaa';

  @override
  String get save => 'Kaydi';

  @override
  String get saved => 'La kaydiyay';

  @override
  String get share => 'Wadaag';

  @override
  String get reportAction => 'Ka warbixi ololaha';

  @override
  String get donateComingSoon => 'Deeq bixi';

  @override
  String get donationsClosed => 'Deeqaha waa xiran yihiin';

  @override
  String get campaignUpdates => 'Cusboonaysiin';

  @override
  String get updateFromOrganizer => 'Cusboonaysiin ka timid abaabulaha';

  @override
  String get updatesEmpty => 'Abaabulaha weli cusboonaysiin ma soo dhigin.';

  @override
  String get updatesEmptyTitle => 'Weli cusboonaysiin ma jirto';

  @override
  String get updatesLoadError => 'Cusboonaysiinta lama soo rari karin.';

  @override
  String seeAllUpdates(int count) {
    return 'Arag dhammaan $count cusboonaysiin';
  }

  @override
  String get comments => 'Faallooyin';

  @override
  String get commentsEmpty =>
      'Noqo kii ugu horreeyay ee fariin taageero reeba.';

  @override
  String get commentsEmptyTitle => 'Weli faallo ma jirto';

  @override
  String get commentAuthorYou => 'Adiga';

  @override
  String get commentAuthorSupporter => 'Taageere';

  @override
  String get commentHint => 'Qor fariin taageero…';

  @override
  String get commentSend => 'Dir';

  @override
  String get commentSignInPrompt => 'Gal si aad faallo u darto';

  @override
  String get supporters => 'Taageerayaal';

  @override
  String get supporterAnonymous => 'Qarsoodi';

  @override
  String get supportersEmpty => 'Weli deeq la xaqiijiyay ma jirto.';

  @override
  String get supportersEmptyTitle => 'Weli taageerayaal ma jiraan';

  @override
  String get supportersLoadError => 'Taageerayaasha lama soo rari karin.';

  @override
  String supportersCountHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count taageerayaal',
      one: '1 taageere',
    );
    return '$_temp0';
  }

  @override
  String get supportersRecentOnly =>
      'Waxaa la tusayaa taageerayaasha ugu dambeeyay.';

  @override
  String seeAllSupporters(int count) {
    return 'Arag dhammaan $count taageerayaal';
  }

  @override
  String get reportTitle => 'Ka warbixi ololahan';

  @override
  String get reportSubtitle =>
      'Warbixintaadu waxay tagaysaa kooxda Kaalmo si loo eego. Waa qarsoodi.';

  @override
  String get reportReasonScam => 'Khiyaano ama been-abuur';

  @override
  String get reportReasonFalseInfo => 'Macluumaad been ah ama marin-habaabin';

  @override
  String get reportReasonMisuse => 'Ku-xadgudubka lacagta';

  @override
  String get reportReasonInappropriate => 'Content aan habboonayn';

  @override
  String get reportReasonDuplicate => 'Olole isku mid ah';

  @override
  String get reportReasonOther => 'Wax kale';

  @override
  String get reportExplanationLabel => 'Ku dar faahfaahin (ikhtiyaari)';

  @override
  String get reportExplanationHint => 'Noo sheeg waxa aad ogaatay';

  @override
  String get reportSubmit => 'Gudbi warbixinta';

  @override
  String get reportSuccessTitle => 'Warbixinta waa la helay';

  @override
  String get reportSuccessBody =>
      'Mahadsanid. Kooxda Kaalmo ayaa eegi doonta ololahan.';

  @override
  String get loginRequiredTitle => 'Gal si aad u sii wadato';

  @override
  String loginRequiredBody(Object action) {
    return 'Waxaad u baahan tahay akoon si aad ololahan ugu $action.';
  }

  @override
  String get timeJustNow => 'hadda';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes daqiiqo ka hor';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours saac ka hor';
  }

  @override
  String timeDaysAgo(int days) {
    return '$days maalmood ka hor';
  }

  @override
  String get donateTitle => 'Deeq bixi';

  @override
  String get donateActionLabel => 'u deeqdo';

  @override
  String get donateLoginTitle => 'Gal si aad u deeqdo';

  @override
  String get donateLoginBody =>
      'Waxaad u baahan tahay akoon Kaalmo si aan kuugu soo dirno rasiidka oo aan u xaqiijino deeqdaada.';

  @override
  String get donateAmountLabel => 'Dooro qadar';

  @override
  String get donateCustomAmount => 'Qadar kale';

  @override
  String get donateAmountInvalid => 'Geli qadar sax ah.';

  @override
  String donateAmountTooLow(Object amount) {
    return 'Deeqda ugu yar waa $amount.';
  }

  @override
  String donateAmountTooHigh(Object amount) {
    return 'Taasi way ka sarreysaa xadka ugu badan ee $amount.';
  }

  @override
  String get donateMessageLabel => 'Fariin (ikhtiyaari)';

  @override
  String get donateMessageHint => 'Ku dar eray dhiirrigelin ah…';

  @override
  String get donateMessageTooLong => 'Fariintaadu waa dheer tahay.';

  @override
  String get donateAnonymousTitle => 'Deeq bixi si qarsoodi ah';

  @override
  String get donateAnonymousSubtitle =>
      'Magacaaga lagama tusi doono ololahan si caro leh.';

  @override
  String get donateAnonymousYes => 'Qarsoodi';

  @override
  String get donateAnonymousNo => 'Magaca la tusi';

  @override
  String get donateContinue => 'Sii wad';

  @override
  String get donateReviewTitle => 'Dib u eeg deeqdaada';

  @override
  String get donateReviewAmount => 'Qadar';

  @override
  String get donateReviewMessage => 'Fariin';

  @override
  String get donateReviewNoMessage => 'Fariin ma jirto';

  @override
  String get donateReviewAnonymous => 'Muuqaal';

  @override
  String get donatePaymentMethod => 'Habka lacag-bixinta';

  @override
  String get donatePhoneLabel => 'Nambarka lacagta mobaylka';

  @override
  String get donatePhoneHint => 'tusaale 0612345678';

  @override
  String get donatePhoneInvalid => 'Geli nambar mobayl sax ah.';

  @override
  String get donateFees => 'Khidmad';

  @override
  String get donateFeesNone => 'Khidmad ma jirto';

  @override
  String get donateTotal => 'Wadarta';

  @override
  String get donateSecurityNote =>
      'Kaalmo waxay xaqiijisaa lacag-bixin kasta iyada oo la wada shaqaynaya bixiyaha ka hor inta aan deeqdaadu la tirin.';

  @override
  String donateConfirm(Object amount) {
    return 'Deeq bixi $amount';
  }

  @override
  String get donateEdit => 'Wax ka beddel deeqda';

  @override
  String get donateProcessingTitle => 'Waxaa la hawlgelinayaa deeqdaada';

  @override
  String get donateProcessingBody =>
      'Fadlan sug — waxaan xaqiijinaynaa lacag-bixintaada iyada oo la wada shaqaynayo bixiyaha.';

  @override
  String get donatePendingTitle => 'Lacag-bixintaada waa la hawlgelinayaa';

  @override
  String get donatePendingBody =>
      'Tani way qaadan kartaa wakhti yar. Waxaan cusboonaysiin doonaa ololaha marka la xaqiijiyo — uma baahnid inaad mar labaad bixiso.';

  @override
  String get donateFailedTitle => 'Deeqda lama dhammaystirin';

  @override
  String get donateFailedGeneric =>
      'Lacag-bixintaada lama dhammaystiri karin. Lacag lagaama qaadin.';

  @override
  String get donateRetry => 'Isku day mar kale';

  @override
  String get donateSuccessTitle => 'Mahadsanid taageeradaada';

  @override
  String donateSuccessBody(Object amount) {
    return 'Deeqdaada $amount waa la xaqiijiyay.';
  }

  @override
  String get donateBackToCampaign => 'Ku noqo ololaha';

  @override
  String get payMethodEvcPlusTitle => 'EVC Plus';

  @override
  String get payMethodEvcPlusSubtitle =>
      'Lacagta mobaylka — ka bixi taleefankaaga';

  @override
  String get payMethodManualTitle => 'Cash / offline';

  @override
  String get payMethodManualSubtitle =>
      'Hadda waa la diiwaan geliyaa, kooxda Kaalmo ayaana xaqiijisa';

  @override
  String get payMethodBankTitle => 'Wareejin bangi';

  @override
  String get payMethodBankSubtitle => 'Ka bixi akoonkaaga bangiga';

  @override
  String get payMethodCardTitle => 'Kaadh';

  @override
  String get payMethodCardSubtitle => 'Kaadh debit ama credit ah';

  @override
  String get payMethodGenericSubtitle => 'Hab lacag-bixin oo la taageero';

  @override
  String get payNoMethods =>
      'Hadda ma jiraan habab lacag-bixin oo la heli karo. Fadlan mar kale isku day.';

  @override
  String get receiptTitle => 'Rasiidka deeqda';

  @override
  String get receiptCampaign => 'Olole';

  @override
  String get receiptAmount => 'Qadar';

  @override
  String get receiptDate => 'Taariikh';

  @override
  String get receiptMethod => 'Hab';

  @override
  String get receiptVisibility => 'Muuqaal';

  @override
  String get receiptReference => 'Tixraac';

  @override
  String get receiptMessage => 'Fariintaada';

  @override
  String get errorCampaignNotOpen => 'Ololahani hadda uma furna deeqaha.';

  @override
  String get myDonationsTitle => 'Deeqahayga';

  @override
  String get myDonationsActionLabel => 'aad u aragto deeqahaaga';

  @override
  String get myDonationsLoginTitle => 'Gal si aad u aragto deeqahaaga';

  @override
  String get myDonationsLoginBody =>
      'Taariikhda deeqahaaga waxay ku xiran tahay akoonkaaga Kaalmo.';

  @override
  String get myDonationsErrorTitle => 'Deeqahaaga lama soo rari karin';

  @override
  String get myDonationsEmptyTitle => 'Weli deeq ma jirto';

  @override
  String get myDonationsEmptyBody =>
      'Marka aad ololo taageerto, halkan ayay ka soo muuqan doontaa.';

  @override
  String get myDonationsExplore => 'Baadh ololayaasha';

  @override
  String get donationDetailTitle => 'Deeq';

  @override
  String get donationCampaignUnavailable => 'Olole lama helayo';

  @override
  String get donationCampaignRemoved => 'Ololahani mar dambe lama heli karo.';

  @override
  String get donationViewCampaign => 'Eeg ololaha';

  @override
  String get donationNotFoundTitle => 'Deeqda lama helin';

  @override
  String get donationNotFoundBody => 'Kama helin deeqdan taariikhdaada.';

  @override
  String get donationBackToList => 'Ku noqo deeqahayga';

  @override
  String get donationStatusPending => 'La sugayo';

  @override
  String get donationStatusConfirmed => 'La xaqiijiyay';

  @override
  String get donationStatusFailed => 'Way fashilantay';

  @override
  String get donationStatusRefunded => 'La celiyay';

  @override
  String get donationStatusUnknown => 'Lama garanayo';

  @override
  String get receiptStatus => 'Xaalad';

  @override
  String get organizerDashboardTitle => 'Abaabule';

  @override
  String get organizerNotAvailableTitle => 'Weli abaabule ma tihid';

  @override
  String get organizerNotAvailableBody =>
      'Marka la ansixiyo gelitaankaaga abaabulaha, halkan ayaad ka maamuli kartaa ololayaasha.';

  @override
  String get organizerLoadErrorTitle => 'Ololayaashaada lama soo rari karin';

  @override
  String get organizerDashboardHeadline => 'Ololayaashaada gaba-gabo';

  @override
  String get organizerTotalRaised => 'Wadarta la ururiyay ololayaashaada';

  @override
  String get organizerTotalRaisedNote =>
      'Deeqaha la xaqiijiyay kaliya — backend-ka ayaa xaqiiqada haya.';

  @override
  String get organizerStatTotal => 'Ololayaal';

  @override
  String get organizerStatLive => 'Firfircoon';

  @override
  String get organizerStatInReview => 'Dib-u-eegis';

  @override
  String get organizerStatDrafts => 'Qabyo';

  @override
  String get organizerStatCompleted => 'La dhammeeyay';

  @override
  String get organizerStatRejected => 'Lama ansixin';

  @override
  String get organizerRecentCampaigns => 'Ololayaasha dhow';

  @override
  String get organizerViewAll => 'Arag dhammaan';

  @override
  String get organizerNoCampaignsYet => 'Weli olole ma aadan abuurin.';

  @override
  String get organizerMyCampaignsTitle => 'Ololayaashayda';

  @override
  String get organizerNoCampaignsTitle => 'Weli olole ma jiro';

  @override
  String get organizerNoCampaignsBody =>
      'Ololayaasha aad abuurto ama aad wada-abaabusho halkan ayay ka muuqan doonaan.';

  @override
  String get organizerRoleCoOrganizer => 'Wada-abaabule';

  @override
  String get organizerManageTitle => 'Maamul ololaha';

  @override
  String get organizerRejectedNote =>
      'Ololahan lama ansixin. La xiriir taageerada haddii aad rabto inaad mar kale isku daydo.';

  @override
  String get organizerEditReturnsToReview =>
      'Kaydinta isbeddelka waxay ololaha dib ugu celin doontaa dib-u-eegis ka hor inta deeq-bixiyayaashu arki.';

  @override
  String get organizerActions => 'Ficillo';

  @override
  String get organizerActionEdit => 'Wax ka beddel ololaha';

  @override
  String get organizerActionPostUpdate => 'Dhig cusboonaysiin';

  @override
  String get organizerActionViewPublic => 'Arag bogga dadweynaha';

  @override
  String get organizerActionSubmit => 'U gudbi dib-u-eegis';

  @override
  String get organizerActionCancel => 'Jooji ololaha';

  @override
  String get organizerActionDelete => 'Tirtir qabyada';

  @override
  String get organizerSubmitConfirmTitle => 'U gudbi dib-u-eegis?';

  @override
  String get organizerSubmitConfirmBody =>
      'Kooxda Kaalmo ayaa eegi doonta ololahaaga ka hor inta uusan firfircoonaan.';

  @override
  String get organizerSubmitSuccess => 'Ololaha waa loo gudbiyay dib-u-eegis.';

  @override
  String get organizerCancelConfirmTitle => 'Jooji ololahan?';

  @override
  String get organizerCancelConfirmBody =>
      'Tan dib looma celin karo. Ololaha waa la xiri doonaa.';

  @override
  String get organizerCancelSuccess => 'Ololaha waa la joojiyay.';

  @override
  String get organizerDeleteConfirmTitle => 'Tirtir qabyadan?';

  @override
  String get organizerDeleteConfirmBody =>
      'Qabyada si joogto ah ayaa loo tirtiri doonaa.';

  @override
  String get organizerBeneficiary => 'Ka-faa\'iidaystaha';

  @override
  String get organizerBeneficiaryLinked =>
      'Ka-faa\'iidayste ayaa lala xiray ololahan.';

  @override
  String get organizerBeneficiaryNone =>
      'Weli ka-faa\'iidayste lalama xirin ololahan.';

  @override
  String get organizerBeneficiaryEmailLabel => 'Iimaylka ka-faa\'iidaystaha';

  @override
  String get organizerBeneficiarySend => 'Dir casuumaad';

  @override
  String get organizerBeneficiarySent =>
      'Casuumaadda waa la diray. Way aqbali doonaan oo xaqiijin dhammaystiri doonaan.';

  @override
  String get organizerTeam => 'Kooxda';

  @override
  String get organizerTeamLoadError => 'Liiska kooxda lama soo rari karin.';

  @override
  String get organizerTeamEmpty => 'Ma jiraan wada-abaabulayaal ololahan.';

  @override
  String get organizerTeamAccepted => 'La aqbalay';

  @override
  String get organizerTeamPending => 'La sugayo';

  @override
  String get organizerEditTitle => 'Wax ka beddel ololaha';

  @override
  String get organizerFieldTitleSo => 'Cinwaan (Soomaali)';

  @override
  String get organizerFieldTitleEn => 'Cinwaan (Ingiriisi, ikhtiyaari)';

  @override
  String get organizerFieldCategory => 'Qaybta';

  @override
  String get organizerFieldRegion => 'Gobol (ikhtiyaari)';

  @override
  String get organizerFieldGoal => 'Qadarka la doonayo';

  @override
  String get organizerFieldStorySo => 'Sheeko (Soomaali)';

  @override
  String get organizerFieldStoryEn => 'Sheeko (Ingiriisi, ikhtiyaari)';

  @override
  String organizerFieldTitleTooShort(int min) {
    return 'Isticmaal ugu yaraan $min xaraf.';
  }

  @override
  String organizerFieldTitleTooLong(int max) {
    return 'Ka yaree $max xaraf.';
  }

  @override
  String organizerFieldStoryTooShort(int min) {
    return 'Sheekada ku qor ugu yaraan $min xaraf.';
  }

  @override
  String get organizerFieldGoalInvalid => 'Geli qadar ka weyn eber.';

  @override
  String get organizerRegionNone => 'Gobol ma jiro';

  @override
  String get organizerEditSuccess => 'Ololaha waa la cusboonaysiiyay.';

  @override
  String get organizerEditMediaNote =>
      'Sawirka daboolka iyo sawirrada kale weli lagama beddeli karo app-ka.';

  @override
  String get organizerSaveChanges => 'Kaydi isbeddelka';

  @override
  String get organizerPostUpdateTitle => 'Dhig cusboonaysiin';

  @override
  String get organizerPostUpdateSubtitle =>
      'Qof kasta oo raacaya ololahan waa la ogeysiin doonaa.';

  @override
  String get organizerUpdateHint =>
      'La wadaag horumar, mahadnaq, ama waxa lacagtu gaartay…';

  @override
  String organizerUpdateTooShort(int min) {
    return 'Qor ugu yaraan $min xaraf.';
  }

  @override
  String get organizerUpdatePosted => 'Cusboonaysiinta waa la dhigay.';

  @override
  String get organizerPublishUpdate => 'Daabac cusboonaysiinta';

  @override
  String get startFundraiserTitle => 'Bilow olole aruurin';

  @override
  String get organizerAccessTitle => 'Noqo abaabule';

  @override
  String get organizerAccessBody =>
      'Abaabulayaashu waxay abuuraan oo maamulaan ololayaal aruurin lacag. Waxaan kuu soo diri doonnaa koodh 6-god ah oo aad xaqiijiso — tallaabo hal mar ah, wax ka beddeli maayo sida aad u deeqdo.';

  @override
  String get organizerAccessConfirmTitle => 'Ku xaqiiji iimaylka';

  @override
  String get organizerAccessConfirmBody =>
      'Geli koodhka 6-god ah ee aan u soo dirnay cinwaanka iimaylkaaga.';

  @override
  String get organizerAccessFullName => 'Magacaaga oo dhan';

  @override
  String get organizerAccessPurpose =>
      'Maxaad lacag u aruurinaysaa? (ikhtiyaari)';

  @override
  String get organizerAccessPurposeHint =>
      'tusaale: Daaweynta caafimaad ee walaalkay';

  @override
  String get organizerAccessSendCode => 'Dir koodhka';

  @override
  String get organizerAccessConfirm => 'Xaqiiji oo sii wad';

  @override
  String get organizerAccessResend => 'Dib u dir koodhka';

  @override
  String get organizerAccessResent => 'Koodh cusub ayaa soo socda.';

  @override
  String get organizerAccessChangeDetails => 'Beddel faahfaahinta';

  @override
  String get createCampaignTitle => 'Faahfaahinta ololaha';

  @override
  String get createCampaignSubtitle =>
      'Ololahaaga waxaa loo kaydiyay qabyo. Waad dib u eegi kartaa oo aqbalaad u gudbin kartaa ka dib.';

  @override
  String get createCampaignTitleHint =>
      'tusaale: Ka caawi dib-u-dhiska rugta caafimaad ee Xamar';

  @override
  String get createCampaignStoryHint =>
      'Sharax cidda ay tahay, waxa lacagtu qaban doonto, iyo sababta ay muhiim u tahay.';

  @override
  String get createCampaignFieldEndDate => 'Taariikhda dhammaadka (ikhtiyaari)';

  @override
  String get createCampaignEndDatePick => 'Dooro taariikh';

  @override
  String get createCampaignCoverNote =>
      'Sawirka daboolka waxaad ku dari kartaa mar dambe bogga ololaha ee webka.';

  @override
  String get createCampaignSubmit => 'Abuur ololaha';

  @override
  String get createCampaignSuccess =>
      'Ololaha waa la abuuray — waxaa loo kaydiyay qabyo.';

  @override
  String get coOrgBanner =>
      'Waxaad tahay wada-abaabule ololahan. Waad wax ka beddeli kartaa nuxurka oo aad cusboonaysiin dhigi kartaa; milkiiluhu wuxuu maamulaa kooxda, ka-faa\'iidaystaha, iyo lacag-bixinta.';

  @override
  String get beneficiaryDashboardTitle => 'Ka-faa\'iidayste';

  @override
  String get beneficiaryLoadErrorTitle =>
      'Xogtaada ka-faa\'iidaystaha lama soo rari karin';

  @override
  String get beneficiaryAccountBanner =>
      'Kanu waa akoonkaaga ka-faa\'iidaystaha — wuu ka duwan yahay abaabulka ololayaasha. Halkan waxaad ku aqbashaa casuumaadaha oo aad ku dhammaystirtaa xaqiijinta.';

  @override
  String get beneficiaryForCampaignLabel => 'Ololaha';

  @override
  String get beneficiaryNextNone =>
      'Weli casuumaad ka-faa\'iidayste ma haysatid. Abaabulaha ayaa iimayl kugu casuumaya.';

  @override
  String get beneficiaryNextInvited =>
      'Aqbal casuumaadda kore si aad u bilowdo. Aqbalitaanku ku maaha xaqiijin.';

  @override
  String get beneficiaryNextAccepted =>
      'Gudbi xogtaada xaqiijinta. Maamulaha ayaa kadib dib u eegaya.';

  @override
  String get beneficiaryNextPending =>
      'Xaqiijintaada waa la gudbiyay waxayna sugaysaa dib-u-eegis maamul.';

  @override
  String get beneficiaryNextVerified =>
      'Waxaad tahay ka-faa\'iidayste la xaqiijiyay. Diyaarinta lacag-bixinta waxaa qabta kooxda Kaalmo.';

  @override
  String get beneficiaryNextRejected =>
      'Cusboonaysii xogtaada oo dib u gudbi si dib loogu eego.';

  @override
  String get beneficiaryStatusNone => 'Lama bilaabin';

  @override
  String get beneficiaryStatusInvited => 'La casuumay';

  @override
  String get beneficiaryStatusAccepted =>
      'La aqbalay — xaqiijin loo baahan yahay';

  @override
  String get beneficiaryStatusPending => 'Dib-u-eegis ku jira';

  @override
  String get beneficiaryStatusVerified => 'La xaqiijiyay';

  @override
  String get beneficiaryStatusRejected => 'Lama ansixin';

  @override
  String get beneficiaryStatusNeedsInfo =>
      'Macluumaad dheeraad ah ayaa loo baahan yahay';

  @override
  String get beneficiaryNeedsInfoNote =>
      'Kooxda dib-u-eegista ayaa codsatay macluumaad dheeraad ah. Cusboonaysii faahfaahintaada oo dib u gudbi.';

  @override
  String get beneficiaryInvitesTitle => 'Casuumaadaha ka-faa\'iidaystaha';

  @override
  String get beneficiaryInviteGeneric =>
      'Waxaa lagugu magacaabay ka-faa\'iidayste olole.';

  @override
  String get beneficiaryInviteAccept => 'Aqbal casuumaadda';

  @override
  String get beneficiaryInviteAccepted =>
      'Casuumaadda waa la aqbalay. Hadda buuxi xaqiijintaada.';

  @override
  String get beneficiaryVerificationTitle => 'Xaqiijin';

  @override
  String get beneficiaryCheckEmail => 'Iimaylka waa la xaqiijiyay';

  @override
  String get beneficiaryCheckPhone => 'Taleefanka waa la xaqiijiyay';

  @override
  String get beneficiaryCheckIdentity => 'Aqoonsiga waa la xaqiijiyay';

  @override
  String get beneficiaryCheckBeneficiary =>
      'Ka-faa\'iidaystaha waa la xaqiijiyay';

  @override
  String get beneficiaryNoName => 'Xogta ka-faa\'iidaystaha';

  @override
  String get beneficiaryRejectedNote =>
      'Xogtaada ka-faa\'iidaystaha lama ansixin. Waad cusboonaysiin kartaa oo dib u gudbin kartaa.';

  @override
  String get beneficiaryPendingNote =>
      'Xogtaada waa la gudbiyay waxayna sugaysaa dib-u-eegista kooxda Kaalmo.';

  @override
  String get beneficiaryStartVerification =>
      'Bilaw xaqiijinta ka-faa\'iidaystaha';

  @override
  String get beneficiaryUpdateIdentity => 'Cusboonaysii xogtayda';

  @override
  String get beneficiaryPayoutTitle => 'Akoonka lacag-qaadashada';

  @override
  String get beneficiaryNoPayoutAccount =>
      'Weli akoon lacag-qaadasho ma aadan darin.';

  @override
  String get beneficiaryPayoutVerified => 'La xaqiijiyay';

  @override
  String get beneficiaryPayoutUnverified => 'Xaqiijin la sugayo';

  @override
  String get beneficiaryAddPayoutButton => 'Ku dar akoon lacag-qaadasho';

  @override
  String get beneficiaryReadyTitle => 'Diyaar u ah lacag-qaadasho';

  @override
  String get beneficiaryReadyBody =>
      'Aqoonsigaaga iyo akoonkaaga lacag-qaadashada waa la xaqiijiyay. Codsiyada lacag-qaadashada waxaa la maamuli doonaa sii-deyn dambe.';

  @override
  String get beneficiaryNotReadyTitle => 'Weli diyaar uma aha lacag-qaadasho';

  @override
  String get beneficiaryNotReadyVerify =>
      'Marka hore dhammaystir xaqiijinta ka-faa\'iidaystaha.';

  @override
  String get beneficiaryNotReadyLinkage =>
      'Aqoonsigaaga waa la xaqiijiyay. Maamulaha weli wuxuu u baahan yahay inuu akoonkaaga lacag-qaadashada ku xiro xogtaada ka-faa\'iidaystaha.';

  @override
  String get beneficiaryCampaignLinkNote =>
      'Ku xirista ka-faa\'iidayste olole gaar ah waxaa sameeya kooxda Kaalmo — weli ma jiro doorasho is-adeeg ah oo app-ka ku jirta.';

  @override
  String get beneficiaryIdentityTitle => 'Xogta ka-faa\'iidaystaha';

  @override
  String get beneficiaryIdentitySubtitle =>
      'Bixi magacaaga sharci sida uu ugu qoran yahay aqoonsigaaga. Kooxda Kaalmo ayaa xaqiijisa.';

  @override
  String get beneficiaryFullNameLabel => 'Magaca buuxa ee sharciga';

  @override
  String get beneficiaryFullNameInvalid =>
      'Geli magacaaga buuxa (2–100 xaraf).';

  @override
  String get beneficiarySubmitIdentity => 'U gudbi xaqiijin';

  @override
  String get beneficiaryIdentitySubmitted => 'Xogta waa loo gudbiyay xaqiijin.';

  @override
  String get beneficiaryAddPayoutTitle => 'Ku dar akoon lacag-qaadasho';

  @override
  String get payoutTypeMobileMoney => 'Lacagta mobaylka';

  @override
  String get payoutTypeBank => 'Bangi';

  @override
  String get beneficiaryProviderLabel => 'Magaca bixiyaha';

  @override
  String get beneficiaryProviderHint => 'tusaale EVC Plus, Salaam Bank';

  @override
  String get beneficiaryProviderInvalid => 'Geli magaca bixiyaha (2–60 xaraf).';

  @override
  String get beneficiaryAccountNumberLabel => 'Nambarka akoonka';

  @override
  String get beneficiaryAccountNumberHelper =>
      'Kaliya 4-ta lambar ee ugu dambeeya ayaa la kaydiyaa.';

  @override
  String get beneficiaryAccountNumberInvalid =>
      'Geli nambar akoon sax ah (4–30 lambar).';

  @override
  String get beneficiaryPayoutAdded =>
      'Akoonka lacag-qaadashada waa lagu daray.';

  @override
  String get notificationsTitle => 'Ogeysiisyo';

  @override
  String get notificationsActionLabel => 'aad u aragto ogeysiisyadaada';

  @override
  String get notificationsLoginTitle => 'Gal si aad u aragto ogeysiisyadaada';

  @override
  String get notificationsLoginBody =>
      'Ogeysiisyadu waxay ku xiran yihiin akoonkaaga Kaalmo.';

  @override
  String get notificationsErrorTitle => 'Ogeysiisyadaada lama soo rari karin';

  @override
  String get notificationsEmptyTitle => 'Weli ogeysiis ma jiro';

  @override
  String get notificationsEmptyBody =>
      'Cusboonaysiinta ku saabsan deeqahaaga, ololayaashaada iyo akoonkaaga halkan ayay ka soo muuqan doonaan.';

  @override
  String get notificationsMarkAllRead => 'Calaamadee dhammaan la akhriyay';

  @override
  String get notifKindDonation => 'Deeq';

  @override
  String get notifKindCampaignUpdate => 'Cusboonaysiin ololaha';

  @override
  String get notifKindCampaignStatus => 'Xaaladda ololaha';

  @override
  String get notifKindBeneficiary => 'Ka-faa\'iidayste';

  @override
  String get notifKindWithdrawal => 'Lacag-qaadasho';

  @override
  String get notifKindTeam => 'Koox';

  @override
  String get notifKindSupport => 'Taageero';

  @override
  String get notifKindSecurity => 'Akoon & amni';

  @override
  String get notifKindSystem => 'Ogeysiis';

  @override
  String get notFoundTitle => 'Bogga lama helin';

  @override
  String get notFoundBody => 'Bogga aad raadinayso halkan ma joogo.';

  @override
  String get notFoundGoHome => 'Aad Guriga';

  @override
  String get settingsTitle => 'Dejinta';

  @override
  String get settingsPreferences => 'Doorbidyada';

  @override
  String get settingsAccount => 'Akoon';

  @override
  String get settingsApp => 'App';

  @override
  String get settingsEditName => 'Wax ka beddel magaca';

  @override
  String get settingsFullName => 'Magaca oo dhan';

  @override
  String get settingsSave => 'Kaydi';

  @override
  String get settingsNameUpdated => 'Magacaaga waa la cusboonaysiiyay.';

  @override
  String get settingsChangePassword => 'Beddel furaha sirta ah';

  @override
  String get settingsChangePasswordBody =>
      'Amnigaaga awgeed, waa lagaa saari doonaa waxaana iimayl lagugu soo diri doonaa lambar dib-u-dejin.';

  @override
  String get settingsPushNotifications => 'Ogeysiisyo riixmo';

  @override
  String get settingsPushNotificationsNote =>
      'Hel digniin qalabkaaga marka ogeysiisyada riixmada loo hawlgeliyo akoonkaaga.';

  @override
  String get settingsCloseAccount => 'Xir akoonkayga';

  @override
  String get settingsCloseAccountSubject => 'Fadlan xir akoonkayga Kaalmo';

  @override
  String get aboutTitle => 'Ku saabsan Kaalmo';

  @override
  String get aboutTagline =>
      'Aruurinta lacagta bulshada ee Soomaaliya, si hufan.';

  @override
  String get aboutBody =>
      'Kaalmo waxay dadka ka caawisaa inay si hufan lacag u aruuriyaan oo u bixiyaan — biilasha caafimaad, degdegga, waxbarashada, masaajidada, mashaariicda bulshada iyo wixii kale. Olole kasta waa la eegaa, ka-faa\'iidaystayaasha la xaqiijiyay ayaana lacagta hela.';

  @override
  String get aboutLegalHeading => 'Sharci & xiriir';

  @override
  String get aboutTerms => 'Shuruudaha Adeegga';

  @override
  String get aboutPrivacy => 'Siyaasadda Asturnaanta';

  @override
  String get aboutContact => 'Xiriir';

  @override
  String get supportTitle => 'Caawimaad & Taageero';

  @override
  String get supportNewTicket => 'Codsi cusub';

  @override
  String get supportErrorTitle => 'Codsiyadaada taageerada lama soo rari karin';

  @override
  String get supportEmptyTitle => 'Ma jiraan codsiyo taageero';

  @override
  String get supportEmptyBody =>
      'Su\'aal ama dhibaato ma qabtaa? Noo soo dir fariin, kooxda Kaalmo ayaa ku caawin doonta.';

  @override
  String supportReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jawaab',
      one: '1 jawaab',
    );
    return '$_temp0';
  }

  @override
  String get supportStatusOpen => 'Furan';

  @override
  String get supportStatusInProgress => 'Socda';

  @override
  String get supportStatusResolved => 'La xalliyay';

  @override
  String get supportStatusClosed => 'La xiray';

  @override
  String get supportNewSubtitle =>
      'Sharrax su\'aashaada ama dhibaatadaada. Ku dar magaca ololaha haddii ay ku saabsan tahay olole gaar ah.';

  @override
  String get supportSubjectLabel => 'Mawduuc';

  @override
  String supportSubjectInvalid(int min) {
    return 'Isticmaal ugu yaraan $min xaraf.';
  }

  @override
  String get supportMessageLabel => 'Fariin';

  @override
  String get supportMessageHint => 'Noo sheeg waxa dhacaya…';

  @override
  String supportMessageInvalid(int min) {
    return 'Isticmaal ugu yaraan $min xaraf.';
  }

  @override
  String get supportSend => 'Dir';

  @override
  String get supportTicketCreated => 'Codsigaaga waa la diray.';

  @override
  String get supportTicketTitle => 'Codsi taageero';

  @override
  String get supportTicketClosed =>
      'Codsigan waa la xiray. Bilow mid cusub haddii aad weli caawimaad u baahan tahay.';

  @override
  String get supportAuthorYou => 'Adiga';

  @override
  String get supportAuthorSupport => 'Taageerada Kaalmo';

  @override
  String get supportReplyHint => 'Qor jawaab…';

  @override
  String get invitesTitle => 'Casuumaadaha ololaha';

  @override
  String get invitesErrorTitle => 'Casuumaadahaaga lama soo rari karin';

  @override
  String get invitesEmptyTitle => 'Ma jiraan casuumaado';

  @override
  String get invitesEmptyBody =>
      'Marka abaabule kuu casuumo inaad ka caawiso maamulka ololaha, halkan ayay ka soo muuqan doontaa.';

  @override
  String get invitesUnknownCampaign => 'Olole';

  @override
  String invitesFrom(Object name) {
    return '$name wuxuu kuugu casuumay inaad wada-abaabusho ololahan.';
  }

  @override
  String get invitesGeneric =>
      'Waxaa lagugu casuumay inaad wada-abaabusho ololahan.';

  @override
  String get invitesAccept => 'Aqbal casuumaadda';

  @override
  String get invitesAccepted => 'Casuumaadda waa la aqbalay.';

  @override
  String get pushOpenAction => 'Fur';
}
