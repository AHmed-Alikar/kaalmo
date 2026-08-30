// Kaalmo runtime i18n dictionary (Design_Rules.md Rule 34 — Somali and
// English are both first-class, neither is a fallback afterthought).
//
// Scope: Navbar, Footer, and the Home page — the highest-traffic surfaces —
// are fully wired to t(). This is the foundation for extending coverage to
// the rest of the app; it is not yet a translation of every screen.
//
// Somali strings are natural phrasing, not literal/robotic translations
// (Rule 34/35).
export const translations = {
  // Navbar
  'nav.explore': { so: 'Baadh', en: 'Explore' },
  'nav.howItWorks': { so: 'Sida ay u shaqeyso', en: 'How It Works' },
  'nav.safety': { so: 'Nabadgelyo', en: 'Safety' },
  'nav.admin': { so: 'Maamulka', en: 'Admin' },
  'nav.organizerDashboard': { so: 'Dashboard-ka abaabulaha', en: 'Organizer dashboard' },
  'nav.startFundraiser': { so: 'Bilow ololaha', en: 'Start a fundraiser' },
  'nav.login': { so: 'Gal', en: 'Log in' },
  'nav.logout': { so: 'Ka bax', en: 'Log out' },
  'nav.myAccount': { so: 'Akoonkayga', en: 'My account' },

  // Home hero
  'home.heroTitle': { so: 'Qof caawi. Rajo abuur.', en: 'Help someone. Raise hope.' },
  'home.heroSubtitle': {
    so: 'Abaabulayaal la xaqiijiyay, lacag-bixin mobile money iyo kaadhka, iyo cusboonaysiin dhab ah — loo dhisay sida Soomaalidu run ahaantii wax u bixiso.',
    en: 'Verified organizers, mobile money and card donations, and real updates — built for how Somalia actually gives.',
  },
  'home.searchPlaceholder': { so: 'Raadi qof ama sabab', en: 'Search for a person or a cause' },
  'home.search': { so: 'Raadi', en: 'Search' },
  'home.browseCampaigns': { so: 'Baadh ololayaasha', en: 'Browse campaigns' },
  'home.raised': { so: 'Lacagta laga soo ururiyay', en: 'Raised through Kaalmo campaigns' },
  'home.campaigns': { so: 'Ololayaasha firfircoon iyo kuwa dhammaaday', en: 'Active and completed campaigns' },
  'home.donors': { so: 'Dadka wax bixiyay', en: 'People who have donated' },
  'home.browseByCategory': { so: 'Ku baadh qaybta', en: 'Browse by category' },
  'home.campaignsToSupport': { so: 'Ololayaasha aad taageeri karto', en: 'Fundraisers to support' },
  'home.viewAll': { so: 'Dhammaan arag', en: 'View all' },
  'home.noCampaigns': {
    so: 'Wali ma jiraan ololayaal firfircoon. Marka ololo la daabaco, halkan ayey ka soo muuqan doontaa.',
    en: 'No active campaigns yet. Once a campaign is published, it will appear here.',
  },
  'home.trustTitle': { so: 'Sida Kaalmo u dhisto kalsooni', en: 'How Kaalmo builds trust' },
  'home.trustSubtitle': {
    so: 'Amni iyo daahfur tallaabo kasta oo aad wax ku bixinayso.',
    en: 'Security and transparency at every step of your giving journey.',
  },
  'home.closingTitle': { so: 'Wax aad u baahan tahay lacag? Bilow ololahaaga maanta.', en: 'Something to raise? Start your fundraiser today.' },
  'home.startFundraiserBtn': { so: 'Bilow ololo', en: 'Start a fundraiser' },

  // Footer
  'footer.tagline': { so: 'Kalsooni bulsho ku salaysan.', en: 'Human-centered trust.' },
  'footer.helpCenter': { so: 'Xarunta Caawimada', en: 'Help Center' },
  'footer.contact': { so: 'Nala soo xiriir', en: 'Contact' },
  'footer.terms': { so: 'Shuruudaha', en: 'Terms' },
  'footer.privacy': { so: 'Sirta', en: 'Privacy' },

  // How It Works
  'howItWorks.title': { so: 'Sida Kaalmo u shaqeyso', en: 'How Kaalmo works' },
  'howItWorks.subtitle': {
    so: 'Kaalmo waxay ku daraysaa xaqiijinta habab lacag-bixineed oo Soomaalidu horeyba u isticmaalayaan, si ololaha iyo wax-bixintu u noqdaan mid fudud oo la aamini karo.',
    en: 'Kaalmo combines verification with the payment methods Somalis already use, so raising and giving money is simple and trustworthy.',
  },
  'howItWorks.forOrganizers': { so: 'Abaabulayaasha', en: 'For organizers' },
  'howItWorks.forDonors': { so: 'Wax-bixiyayaasha', en: 'For donors' },

  // Safety & Trust
  'safety.title': { so: 'Nabadgelyo & Kalsooni', en: 'Safety & Trust' },
  'safety.subtitle': {
    so: 'Kalsoonidu waa aasaaska Kaalmo. Halkan waxaa ku qoran waxa xaqiijintu ka dhigan tahay, iyo waxa aanay ka dhignayn.',
    en: 'Trust is the foundation of Kaalmo. Here is what verification means, and what it does not mean.',
  },
  'safety.badgesTitle': { so: 'Calaamadaha xaqiijinta', en: 'Verification badges' },
  'safety.badgesNote': {
    so: 'Calaamadda xaqiijinta waxay xaqiijisaa in aan hubinnay xog gaar ah — sida dukumeenti aqoonsi ah ama aqoonsiga qofka faa\'iidaysta. Ma dammaanad qaadayso in sheeko kasta oo olole ku jirta ay run tahay. Had iyo jeer akhri sheekada iyo cusboonaysiinta ka hor inta aadan wax bixin.',
    en: 'A verification badge confirms that we checked a specific detail — such as an ID document or a beneficiary\'s identity. It does not guarantee that every claim in a campaign story is true. Always read the story and updates before donating.',
  },
  'safety.reviewTitle': { so: 'Sida aan u eegno ololayaasha', en: 'How we review campaigns' },
  'safety.reviewText': {
    so: 'Olole kasta waa la eegaa ka hor inta uu bilaabmin. Kooxdayadu waxay hubisaa aqoonsiga abaabulaha, dukumeentiyada qofka faa\'iidaysta, iyo isku-duubnaanta sheekada ololaha. Ololayaasha waa la joojin karaa haddii wax khalad ah la arko ka dib markay bilaabmaan.',
    en: 'Every campaign is reviewed before it goes live. Our team checks the organizer\'s identity, the beneficiary\'s documentation, and the campaign story for consistency. Campaigns can be suspended or frozen if something looks wrong after they go live.',
  },
  'safety.reportTitle': { so: 'Warbixinta walaac', en: 'Reporting a concern' },
  'safety.reportText': {
    so: 'Haddii wax ku saabsan olole ay ku muuqato mid khalad ah, isticmaal batoonka "Ka warbixi" ee bogga ololaha. Kooxdayada Kalsoonida & Nabadgelyada ayaa eegta warbixin kasta.',
    en: 'If something about a campaign looks wrong, use the "Report" button on the campaign page. Our Trust & Safety team reviews every report.',
  },

  // Help Center
  'helpCenter.title': { so: 'Xarunta Caawimada', en: 'Help Center' },
  'helpCenter.subtitle': { so: 'Jawaabaha su\'aalaha caanka ah. Weli u baahan tahay caawimo?', en: 'Answers to common questions. Still need help?' },
  'helpCenter.contactUs': { so: 'Nala soo xiriir', en: 'Contact us' },

  // Legal
  'legal.termsTitle': { so: 'Shuruudaha Adeegga', en: 'Terms of Service' },
  'legal.termsText': {
    so: 'Shuruudaha buuxa ee adeegga Kaalmo waxaa lala dhammaystirayaa la-taliye sharci ah ka hor inta lacag dhab ah la bilaabin (eeg Qaybta 27 ee qoraalka badeecada). Boggan waa la cusboonaysiin doonaa ka hor inta madasha lacag-bixin dhab ah shaqaynayn.',
    en: 'Kaalmo\'s full terms of service are being finalized with legal counsel before real-money launch (see Section 27 of the product specification). This page will be updated before the platform processes live donations.',
  },
  'legal.privacyTitle': { so: 'Siyaasadda Sirta', en: 'Privacy Policy' },
  'legal.privacyText': {
    so: 'Kaalmo waxay ururisaa kaliya xogta loo baahan yahay si loo xaqiijiyo abaabulayaasha, qofka faa\'iidaysta, iyo si loo qabto wax-bixinnada. Siyaasad sir oo dhammaystiran ayaa lala dhammaystirayaa la-taliye sharci ah ka hor inta lacag dhab ah la bilaabin.',
    en: 'Kaalmo collects only the information needed to verify organizers, beneficiaries, and process donations. A complete privacy policy is being finalized with legal counsel before real-money launch.',
  },

  // Contact
  'contact.title': { so: 'La soo xiriir Kaalmo', en: 'Contact Kaalmo' },
  'contact.subtitle': {
    so: 'Su\'aal ma ka qabtaa olole, wax-bixin, ama akoonkaaga? Noo soo dir fariin.',
    en: 'Have a question about a campaign, a donation, or your account? Send us a message.',
  },
  'contact.sentTitle': { so: 'Fariinta waa la helay', en: 'Message received' },
  'contact.sentTextUser': {
    so: 'Kooxda taageerada halkan ayey kaaga jawaabi doonaan, waxaana kuu soo diri doonaan ogeysiis marka ay ku soo laabtaan.',
    en: 'Our support team will reply here and by notification once they follow up.',
  },
  'contact.sentTextGuest': {
    so: 'Kooxda taageerada waxay kuugu jawaabi doonaan email 1-2 maalmood oo shaqo ah gudahood.',
    en: 'Our support team will reply by email within 1–2 business days.',
  },
  'contact.name': { so: 'Magacaaga', en: 'Your name' },
  'contact.email': { so: 'Ciwaanka email-ka', en: 'Email address' },
  'contact.subject': { so: 'Mawduuca', en: 'Subject' },
  'contact.howCanWeHelp': { so: 'Sideen kuu caawin karnaa?', en: 'How can we help?' },
  'contact.sending': { so: 'Diraya…', en: 'Sending…' },
  'contact.sendMessage': { so: 'Dir fariinta', en: 'Send message' },
  'contact.errorFallback': { so: 'Fariintaada lama dirin karin. Fadlan mar kale isku day.', en: 'Could not send your message. Please try again.' },

  // Auth
  'login.welcomeBack': { so: 'Soo dhawoow', en: 'Welcome back' },
  'login.subtitle': { so: 'Gal si aad ugu sii socoto Kaalmo.', en: 'Log in to continue to Kaalmo.' },
  'login.email': { so: 'Ciwaanka email-ka', en: 'Email address' },
  'login.password': { so: 'Furaha sirta ah', en: 'Password' },
  'login.loggingIn': { so: 'Waa la galayaa…', en: 'Logging in…' },
  'login.logIn': { so: 'Gal', en: 'Log in' },
  'login.noAccount': { so: 'Akoon ma lihid?', en: "Don't have an account?" },
  'login.createOne': { so: 'Samee mid', en: 'Create one' },

  'register.title': { so: 'Samee akoonkaaga', en: 'Create your account' },
  'register.subtitle': { so: 'Ku biir Kaalmo si aad wax u bixiso ama olole u bilowdo.', en: 'Join Kaalmo to donate or start a fundraiser.' },
  'register.fullName': { so: 'Magaca oo dhan', en: 'Full name' },
  'register.phone': { so: 'Lambarka taleefanka', en: 'Phone number' },
  'register.creating': { so: 'Waa la abuurayaa…', en: 'Creating account…' },
  'register.createAccount': { so: 'Samee akoon', en: 'Create account' },
  'register.haveAccount': { so: 'Akoon ma leedahay?', en: 'Already have an account?' },

  'checkEmail.title': { so: 'Xaqiiji email-kaaga si aad u sii socoto', en: 'Verify your email to continue' },
  'checkEmail.subtitle': { so: 'Geli lambarka 6-god ah ee aan email-kaaga u dirnay.', en: 'Enter the 6-digit code we sent to your email address.' },
  'checkEmail.verifying': { so: 'Waa la xaqiijinayaa…', en: 'Verifying…' },
  'checkEmail.verifyEmail': { so: 'Xaqiiji email-ka', en: 'Verify email' },
  'checkEmail.resent': { so: 'Lambar cusub ayaa la diray.', en: 'A new code was sent.' },
  'checkEmail.didntGetCode': { so: 'Lambarka ma helin? Dib u dir', en: "Didn't get a code? Resend it" },
  'checkEmail.browseWithoutAccount': { so: 'Baadh ololayaasha adiga oo aan akoon lahayn', en: 'Browse campaigns without an account' },
  'checkEmail.verifyError': { so: 'Lambarkan lama xaqiijin karin. Fadlan mar kale isku day.', en: 'Could not verify this code. Please try again.' },
  'checkEmail.resendError': { so: 'Lambarka dib looma diri karin.', en: 'Could not resend the code.' },

  // Shared/common
  'common.checkConnection': { so: 'Fadlan hubi xiriirkaaga oo mar kale isku day.', en: 'Please check your connection and try again.' },
  'common.save': { so: 'Kaydi', en: 'Save' },
  'common.cancel': { so: 'Jooji', en: 'Cancel' },
  'common.saving': { so: 'Waa la kaydinayaa…', en: 'Saving…' },
  'common.saved': { so: 'Waa la kaydiyay.', en: 'Saved.' },

  // Donor
  'donor.myAccount': { so: 'Akoonkayga', en: 'My account' },
  'donor.myDonations': { so: 'Wax-bixinnadayda', en: 'My donations' },
  'donor.loadDonationsErrorTitle': { so: 'Wax-bixinnadaada lama soo rarin karin', en: "Couldn't load your donations" },
  'donor.noDonationsTitle': { so: 'Wali wax bixin ma jirto', en: 'No donations yet' },
  'donor.noDonationsDesc': { so: 'Wax-bixintaada ugu horreysa halkan ayey ka soo muuqan doontaa marka aad olole taageerto.', en: 'Your first donation will appear here once you support a campaign.' },
  'donor.exploreCampaigns': { so: 'Baadh ololayaasha', en: 'Explore campaigns' },
  'donor.campaign': { so: 'Olole', en: 'Campaign' },
  'donor.savedCampaigns': { so: 'Ololayaasha la kaydiyay', en: 'Saved campaigns' },
  'donor.followedCampaigns': { so: 'Ololayaasha la raacayo', en: 'Followed campaigns' },
  'donor.notifications': { so: 'Ogeysiisyada', en: 'Notifications' },
  'donor.settings': { so: 'Dejinta', en: 'Settings' },
  'donor.noSavedTitle': { so: 'Wali olole ma kaydin', en: 'No saved campaigns yet' },
  'donor.noSavedDesc': { so: 'Ololayaasha aad kaydiso halkan ayey ka soo muuqan doonaan si aad si fudud dib ugu soo laabato.', en: 'Campaigns you save will appear here so you can easily come back to them.' },
  'donor.noFollowedTitle': { so: 'Wali olole ma raacayn', en: 'No followed campaigns yet' },
  'donor.noFollowedDesc': { so: 'La soco olole si aad u hesho cusboonaysiinta marka ay soo baxaan.', en: 'Follow a campaign to get its updates as they post.' },
  'donor.noNotificationsTitle': { so: 'Wali ogeysiis ma jirto', en: 'No notifications yet' },
  'donor.noNotificationsDesc': { so: 'Ogeysiisyada ku saabsan wax-bixinnadaada iyo ololayaasha aad raacayso halkan ayey ka soo muuqan doonaan.', en: 'Notifications about your donations and followed campaigns will appear here.' },
  'donor.markAllRead': { so: 'Dhammaan calaamadi in la akhriyay', en: 'Mark all as read' },
  'donor.loadSavedErrorTitle': { so: 'Ololayaasha la kaydiyay lama soo rarin karin', en: "Couldn't load saved campaigns" },
  'donor.loadFollowedErrorTitle': { so: 'Ololayaasha la raacayo lama soo rarin karin', en: "Couldn't load followed campaigns" },
  'donor.loadNotificationsErrorTitle': { so: 'Ogeysiisyada lama soo rarin karin', en: "Couldn't load notifications" },
  'donor.view': { so: 'Arag', en: 'View' },
  'donor.markRead': { so: 'Calaamadi in la akhriyay', en: 'Mark read' },
  'settings.saveError': { so: 'Isbeddelladaada lama kaydin karin.', en: 'Could not save your changes.' },
  'settings.saveChanges': { so: 'Kaydi isbeddellada', en: 'Save changes' },
  'settings.language': { so: 'Luqadda', en: 'Language' },

  // Donate
  'donate.errorFallback': { so: 'Wax-bixintan lama qaban karin. Fadlan mar kale isku day.', en: 'We could not process this donation. Please try again.' },
  'donate.campaignRemoved': { so: 'Ololahan waa laga saarayay.', en: 'This campaign may have been removed.' },
  'donate.title': { so: 'Wax bixi', en: 'Donate' },
  'donate.to': { so: 'Waxaa loo diray', en: 'To' },
  'donate.amountLabel': { so: 'Qadarka (USD)', en: 'Amount (USD)' },
  'donate.customAmountPlaceholder': { so: 'Geli qadar aad doorato', en: 'Enter a custom amount' },
  'donate.payWith': { so: 'Ku bixi', en: 'Pay with' },
  'donate.evcPlus': { so: 'EVC Plus (mobile money)', en: 'EVC Plus (mobile money)' },
  'donate.evcPlusNumber': { so: 'Lambarka EVC Plus', en: 'EVC Plus number' },
  'donate.evcPlusHint': { so: 'Waxaad heli doontaa dalab lacag-bixineed taleefankan — geli PIN-kaaga EVC Plus si aad u xaqiijiso.', en: "You'll get a payment prompt on this phone — enter your EVC Plus PIN there to confirm." },
  'donate.messageLabel': { so: 'Fariin (ikhtiyaari)', en: 'Message (optional)' },
  'donate.messagePlaceholder': { so: 'Ku dhaaf fariin taageero', en: 'Leave a message of support' },
  'donate.anonymousLabel': { so: 'Ku bixi magac la\'aan (magacaaga si dadweyne ah looma muujin doono)', en: 'Donate anonymously (your name will not be shown publicly)' },
  'donate.total': { so: 'Guud ahaan', en: 'Total' },
  'donate.waitingConfirm': { so: 'Waan sugaynaa inaad taleefankaaga ku xaqiijiso…', en: 'Waiting for you to confirm on your phone…' },
  'donate.donateButtonPrefix': { so: 'Ku bixi', en: 'Donate' },
  'donate.donateButtonSuffix': { so: 'EVC Plus', en: 'with EVC Plus' },
  'donate.backToCampaign': { so: 'Ku noqo ololaha', en: 'Back to campaign' },

  // Donation Confirmed
  'donationConfirmed.title': { so: 'Wax-bixinta waa la helay', en: 'Donation received' },
  'donationConfirmed.thanksFor': { so: 'Waad ku mahadsan tahay taageeradaada', en: 'Thank you for supporting' },
  'donationConfirmed.thisCampaign': { so: 'ololahan', en: 'this campaign' },
  'donationConfirmed.amount': { so: 'Qadarka', en: 'Amount' },
  'donationConfirmed.status': { so: 'Xaaladda', en: 'Status' },
  'donationConfirmed.reference': { so: 'Tixraaca', en: 'Reference' },
  'donationConfirmed.confirmedNote': { so: 'Wax-bixintaada waa la xaqiijiyay. Waxay horeyba ugu jirtaa qadarka la ururiyay ee ololaha.', en: "Your donation has been confirmed. It's already reflected in the campaign's raised amount." },
  'donationConfirmed.exploreMore': { so: 'Baadh wax dheeraad ah', en: 'Explore more' },

  // Beneficiary Verification
  'verification.error': { so: 'Xaqiijintaada lama diri karin. Fadlan mar kale isku day.', en: 'Could not submit your verification. Please try again.' },
  'verification.title': { so: 'Xaqiijinta qofka faa\'iidaysta', en: 'Beneficiary verification' },
  'verification.subtitle': {
    so: 'Xaqiijinta qofka faa\'iidaystu waxay dhistaa kalsooni wax-bixiyayaasha, waana lagama maarmaan ka hor inta lacag-bixin loo codsan olole u gaar ah.',
    en: 'Verifying the beneficiary builds trust with donors, and is required before any withdrawal can be requested for their campaign.',
  },
  'verification.currentStatus': { so: 'Xaaladda hadda', en: 'Current status' },
  'verification.submittedTitle': { so: 'Waa loo gudbiyay eegis', en: 'Submitted for review' },
  'verification.submittedDesc': { so: 'Kooxdayadu waxay xaqiijin doontaa faahfaahintan oo waxay cusboonaysiin doontaa xaaladda kore.', en: 'Our team will verify these details and update the status above.' },
  'verification.fullLegalName': { so: 'Magaca sharciga ah ee oo dhan', en: 'Full legal name' },
  'verification.idDocument': { so: 'Dukumeenti aqoonsi (sawir ID ah)', en: 'Identity document (photo ID)' },
  'verification.submitting': { so: 'Waa la gudbinayaa…', en: 'Submitting…' },
  'verification.submitButton': { so: 'U gudbi xaqiijin', en: 'Submit for verification' },

  // Organizer dashboard
  'organizerDash.title': { so: 'Abaabule', en: 'Organizer' },
  'organizerDash.myCampaigns': { so: 'Ololayaashayda', en: 'My campaigns' },
  'organizerDash.createCampaign': { so: 'Samee olole', en: 'Create campaign' },
  'organizerDash.actionError': { so: 'Falkan lama dhammaystiri karin. Fadlan mar kale isku day.', en: 'Could not complete this action. Please try again.' },
  'organizerDash.loadErrorTitle': { so: 'Ololayaashaada lama soo rarin karin', en: "Couldn't load your campaigns" },
  'organizerDash.noCampaignsTitle': { so: 'Wali olole ma jirto', en: 'No campaigns yet' },
  'organizerDash.noCampaignsDesc': { so: 'Samee ololahaaga ugu horreeya si aad u bilowdo lacag-ururin.', en: 'Create your first campaign to start raising funds.' },
  'organizerDash.coOrganizer': { so: 'La-abaabule', en: 'Co-organizer' },
  'organizerDash.viewPublicPage': { so: 'Arag bogga dadweynaha', en: 'View public page' },
  'organizerDash.edit': { so: 'Wax ka beddel', en: 'Edit' },
  'organizerDash.delete': { so: 'Tirtir', en: 'Delete' },
  'organizerDash.cancelCampaign': { so: 'Jooji ololaha', en: 'Cancel campaign' },
  'organizerDash.deleteConfirmTitle': { so: 'Tirtir ololahan qabyada ah?', en: 'Delete this draft campaign?' },
  'organizerDash.cancelConfirmTitle': { so: 'Jooji ololahan?', en: 'Cancel this campaign?' },
  'organizerDash.deleteConfirmDesc': { so: 'si joogto ah ayaa loo saarayaa. Tan lama beddeli karo.', en: "will be permanently removed. This can't be undone." },
  'organizerDash.cancelConfirmDesc': { so: 'ayaa laga saarayaa eegista, waxaana lagu calaamadinayaa mid la joojiyay. Tan lama beddeli karo.', en: "will be withdrawn from review and marked cancelled. This can't be undone." },
  'organizerDash.keepCampaign': { so: 'Sii wad ololaha', en: 'Keep campaign' },
  'organizerDash.working': { so: 'Waa la shaqaynayaa…', en: 'Working…' },
  'organizerNav.analytics': { so: 'Falanqaynta', en: 'Analytics' },
  'organizerNav.team': { so: 'Kooxda', en: 'Team' },
  'organizerNav.withdrawals': { so: 'Lacag-bixinno', en: 'Withdrawals' },
  'support.nav': { so: 'Taageero', en: 'Support' },

  // Admin nav
  'adminNav.overview': { so: 'Guud ahaan', en: 'Overview' },
  'adminNav.campaigns': { so: 'Ololayaasha', en: 'Campaigns' },
  'adminNav.donations': { so: 'Wax-bixinnada', en: 'Donations' },
  'adminNav.verificationQueue': { so: 'Safka xaqiijinta', en: 'Verification queue' },
  'adminNav.users': { so: 'Isticmaalayaasha', en: 'Users' },
  'adminNav.reports': { so: 'Warbixinno', en: 'Reports' },
  'adminNav.fraudRisk': { so: 'Khiyaano & Halis', en: 'Fraud & risk' },
  'adminNav.supportTickets': { so: 'Tigidhada taageerada', en: 'Support tickets' },
  'adminNav.auditLogs': { so: 'Diiwaanka la eegay', en: 'Audit logs' },

  // Analytics
  'analytics.emptyTitle': { so: 'Wali olole aad falanqayn karto ma jiro', en: 'No campaigns to analyze yet' },
  'analytics.emptyDesc': { so: 'Samee olole si aad halkan uga aragto waxqabadkiisa.', en: 'Create a campaign to see its performance here.' },
  'analytics.totalRaised': { so: 'Wadarta la ururiyay ee ololayaasha oo dhan', en: 'Total raised across all campaigns' },
  'analytics.trackingNote': {
    so: 'Tirada daawadayaasha, heerka isbeddelka, iyo qaybinta isha-tixraaca weli lama la socdo — qaybtan waxay balaadhi doontaa marka la daro ururinta falanqaynta.',
    en: 'View counts, conversion rate, and referral-source breakdown are not tracked yet — this section will expand once analytics collection is added.',
  },

  // Team
  'team.inviteError': { so: 'Casuumaddan lama diri karin.', en: 'Could not send this invitation.' },
  'team.createCampaignFirstTitle': { so: 'Marka hore samee olole', en: 'Create a campaign first' },
  'team.createCampaignFirstDesc': { so: 'Marka aad olole leedahay, waxaad ku casuumi kartaa la-abaabuleyaal si ay kuu caawiyaan maaraynta.', en: 'Once you have a campaign, you can invite co-organizers to help manage it.' },
  'team.campaignLabel': { so: 'Olole', en: 'Campaign' },
  'team.inviteLabel': { so: 'Ku casuun la-abaabule email ahaan', en: 'Invite a co-organizer by email' },
  'team.sending': { so: 'Diraya…', en: 'Sending…' },
  'team.invite': { so: 'Casuun', en: 'Invite' },
  'team.noMembersTitle': { so: 'Wali xubno koox ma jiraan', en: 'No team members yet' },
  'team.noMembersDesc': { so: 'Ku casuun qof email ahaan si uu kuugu caawiyo maaraynta qoraalka ololahan.', en: "Invite someone by email to help manage this campaign's content." },
  'team.remove': { so: 'Ka saar', en: 'Remove' },

  // Withdrawals
  'withdrawals.submitError': { so: 'Codsiga lacag-bixinta lama diri karin.', en: 'Could not submit this withdrawal request.' },
  'withdrawals.requestTitle': { so: 'Codso lacag-bixin', en: 'Request a withdrawal' },
  'withdrawals.noPayoutAccount': { so: 'Weli akoon lacag-bixineed ma lihid. Ka dar akoon mobile money ah ama bangi ah Dejinta ka hor inta aad codsan lacag-bixin.', en: "You don't have a payout account yet. Add a mobile money or bank account from Settings before requesting a withdrawal." },
  'withdrawals.selectCampaign': { so: 'Dooro olole', en: 'Select a campaign' },
  'withdrawals.raisedSuffix': { so: 'la ururiyay', en: 'raised' },
  'withdrawals.payoutAccount': { so: 'Akoonka lacag-bixinta', en: 'Payout account' },
  'withdrawals.selectPayoutAccount': { so: 'Dooro akoon lacag-bixineed', en: 'Select a payout account' },
  'withdrawals.submitVerificationLink': { so: 'U gudbi xaqiijinta qofka faa\'iidaysta', en: 'Submit beneficiary verification' },
  'withdrawals.submitting': { so: 'Waa la gudbinayaa…', en: 'Submitting…' },
  'withdrawals.requestButton': { so: 'Codso lacag-bixin', en: 'Request withdrawal' },
  'withdrawals.historyTitle': { so: 'Taariikhda lacag-bixinta', en: 'Withdrawal history' },
  'withdrawals.noHistoryTitle': { so: 'Wali codsi lacag-bixineed ma jirto', en: 'No withdrawal requests yet' },
  'withdrawals.noHistoryDesc': { so: 'Marka aad codsato lacag-bixin, halkan ayey ka soo muuqan doontaa xaaladdeeda.', en: 'Once you request a withdrawal, it will appear here with its review status.' },

  // Edit Campaign
  'editCampaign.loadError': { so: 'Ololahan lama soo rarin karin.', en: 'Could not load this campaign.' },
  'editCampaign.saveError': { so: 'Isbeddelladan lama kaydin karin. Fadlan mar kale isku day.', en: 'Could not save these changes. Please try again.' },
  'editCampaign.loadErrorTitle': { so: 'Ololahan lama soo rarin karin', en: "Couldn't load this campaign" },
  'editCampaign.title': { so: 'Wax ka beddel ololaha', en: 'Edit campaign' },
  'editCampaign.subtitle': { so: 'Cusboonaysii faahfaahinta wax-bixiyayaashu ka arkaan bogga ololahan.', en: "Update the details donors see on this campaign's page." },
  'editCampaign.reviewWarningPrefix': { so: 'Ololahan durbaba wuxuu ku jiraa', en: 'This campaign is already' },
  'editCampaign.inReview': { so: 'eegis', en: 'in review' },
  'editCampaign.reviewWarningSuffix': {
    so: 'Kaydinta isbeddelladu waxay dib ugu celin doontaa eegis, mana muuqan doono wax-bixiyayaasha ilaa admin uu mar kale ansixiyo.',
    en: "Saving changes will send it back for re-review, and it won't be visible to donors until an admin approves it again.",
  },
  'editCampaign.coverPhoto': { so: 'Sawirka daboolka', en: 'Cover photo' },
  'editCampaign.campaignTitle': { so: 'Cinwaanka ololaha', en: 'Campaign title' },
  'editCampaign.fundingGoal': { so: 'Hadafka lacagta (USD)', en: 'Funding goal (USD)' },
  'editCampaign.regionOptional': { so: 'Gobolka (ikhtiyaari)', en: 'Region (optional)' },
  'editCampaign.story': { so: 'Sheekada', en: 'Story' },

  // Campaign wizard
  'wizard.basics': { so: 'Aasaaska', en: 'Basics' },
  'wizard.story': { so: 'Sheekada', en: 'Story' },
  'wizard.reviewSubmit': { so: 'Eegis & Gudbi', en: 'Review & Submit' },
  'createBasics.error': { so: 'Aasaaska ololahaaga lama kaydin karin. Fadlan mar kale isku day.', en: 'Could not save your campaign basics. Please try again.' },
  'createBasics.title': { so: 'Noo sheeg aasaaska', en: 'Tell us the basics' },
  'createBasics.titlePlaceholder': { so: 'tusaale ahaan: Ka caawi Amina inay dhammaystirto daaweynta kansarka', en: "e.g. Help Amina complete her cancer treatment" },
  'createBasics.continueToStory': { so: 'Sii wad sheekada', en: 'Continue to story' },
  'createStory.error': { so: 'Sheekadaada lama kaydin karin. Fadlan mar kale isku day.', en: 'Could not save your story. Please try again.' },
  'createStory.missingCampaign': { so: 'Olole ma jiro. Fadlan ka bilow tallaabada aasaaska.', en: 'Missing campaign. Please start from the basics step.' },
  'createStory.title': { so: 'Sheekada oo buuxda noo sheeg', en: 'Tell the full story' },
  'createStory.subtitle': { so: 'Sharax cida caawimo u baahan, sababta, iyo sida lacagta loo isticmaali doono. Wax-bixiyayaashu waxay aaminaan sheekooyin gaar ah oo daacad ah.', en: 'Explain who needs help, why, and how the money will be used. Donors trust specific, honest stories.' },
  'createStory.placeholder': { so: 'Ku bilow cida ay tani u gaar tahay iyo sababta lacagta loo baahan yahay...', en: 'Start with who this is for and why the funds are needed...' },
  'createStory.continueToReview': { so: 'Sii wad eegista', en: 'Continue to review' },
  'createReview.error': { so: 'Ololahaaga lama gudbin karin. Fadlan mar kale isku day.', en: 'Could not submit your campaign. Please try again.' },
  'createReview.submittedTitle': { so: 'Ololaha waa loo gudbiyay eegis', en: 'Campaign submitted for review' },
  'createReview.submittedDesc': { so: 'Kooxdayadu waxay eegi doontaa ololahaaga iyo faahfaahinta qofka faa\'iidaysta. Caadi ahaan waxay qaadataa 1-2 maalmood oo shaqo ah.', en: 'Our team will review your campaign and beneficiary details. This usually takes 1–2 business days.' },
  'createReview.goToCampaigns': { so: 'Aad ololayaashayda', en: 'Go to my campaigns' },
  'createReview.title': { so: 'Eeg oo gudbi', en: 'Review and submit' },
  'createReview.goal': { so: 'Hadaf', en: 'Goal' },
  'createReview.withdrawalNote': { so: 'Lacag-bixinta waxay u baahan doontaa qof faa\'iido leh oo la xaqiijiyay ka hor inta la codsan karin — waqti kasta ka hor waad soo gudbin kartaa.', en: 'A withdrawal will require a verified beneficiary before it can be requested — you can submit this any time before then.' },
  'createReview.submitButton': { so: 'U gudbi eegis', en: 'Submit for review' },

  // Invites
  'invites.title': { so: 'Casuumaadaha ololayaasha', en: 'Campaign invitations' },
  'invites.loadErrorTitle': { so: 'Casuumaadaha lama soo rarin karin', en: "Couldn't load invitations" },
  'invites.emptyTitle': { so: 'Wali casuumaad sugaya ma jirto', en: 'No pending invitations' },
  'invites.emptyDesc': { so: 'Marka abaabule kugu casuumo inaad olole ka caawiso, halkan ayey ka soo muuqan doontaa.', en: 'When an organizer invites you to help with a campaign, it will appear here.' },
  'invites.invitedBy': { so: 'Waxaa ku casuumay', en: 'Invited by' },
  'invites.accept': { so: 'Aqbal', en: 'Accept' },

  // Organizer Onboard
  'onboard.genericError': { so: 'Wax baa qaldamay. Fadlan mar kale isku day.', en: 'Something went wrong. Please try again.' },
  'onboard.confirmByEmail': { so: 'Ku xaqiiji email', en: 'Confirm by email' },
  'onboard.confirmSubtitle': { so: 'Geli lambarka 6-god ah ee aan email-kaaga u dirnay si aad u dhaqaajiso helitaanka abaabule.', en: 'Enter the 6-digit code we sent to your email address to activate organizer access.' },
  'onboard.confirmAndContinue': { so: 'Xaqiiji oo sii wad', en: 'Confirm and continue' },
  'onboard.subtitle': { so: 'Xaqiiji dhowr faahfaahin ah waxaana kuu email dirin doonaa lambar aad ku dhaqaajiso helitaanka abaabule.', en: "Confirm a few details and we'll email you a code to activate organizer access." },
  'onboard.yourFullName': { so: 'Magacaaga oo dhan', en: 'Your full name' },
  'onboard.purposeLabel': { so: 'Maxaad qorsheynaysaa inaad lacag u ururiso?', en: 'What do you plan to raise money for?' },
  'onboard.purposePlaceholder': { so: 'tusaale ahaan: Daaweynta caafimaad ee hooyaday', en: 'e.g. Medical treatment for my mother' },
  'onboard.sendCode': { so: 'Dir lambarka xaqiijinta', en: 'Send confirmation code' },

  // My support tickets
  'myTickets.title': { so: 'Tigidhada taageerada', en: 'Support tickets' },
  'myTickets.newMessage': { so: 'Fariin cusub', en: 'New message' },
  'myTickets.loadErrorTitle': { so: 'Tigidhadaada lama soo rarin karin', en: "Couldn't load your tickets" },
  'myTickets.emptyTitle': { so: 'Wali tigidh taageero ma jiro', en: 'No support tickets yet' },
  'myTickets.emptyDesc': { so: 'Haddii aad su\'aal qabto, noo dir fariin waxayna halkan ka soo muuqan doontaa.', en: 'If you have a question, send us a message and it will appear here.' },
  'myTickets.contactSupport': { so: 'La soo xiriir taageerada', en: 'Contact support' },
  'myTickets.reply': { so: 'jawaab', en: 'reply' },
  'myTickets.replies': { so: 'jawaabood', en: 'replies' },
  'myTickets.updated': { so: 'La cusboonaysiiyay', en: 'Updated' },
  'myTickets.you': { so: 'Adiga', en: 'You' },
  'myTickets.kaalmoSupport': { so: 'Taageerada Kaalmo', en: 'Kaalmo support' },
  'myTickets.replyPlaceholder': { so: 'Qor jawaab…', en: 'Write a reply…' },
  'myTickets.sendReply': { so: 'Dir jawaabta', en: 'Send reply' },

  // Image Upload
  'imageUpload.error': { so: 'Sawirkan lama soo geli karin. Fadlan isku day fayl JPEG, PNG, ama WebP oo yar.', en: 'Could not upload this image. Please try a smaller JPEG, PNG, or WebP file.' },
  'imageUpload.uploading': { so: 'Waa la soo gelinayaa…', en: 'Uploading…' },
  'imageUpload.clickToUpload': { so: 'Guji si aad u soo geliso sawir daboolka ah', en: 'Click to upload a cover photo' },

  // Admin Overview
  'adminOverview.confirmedDonations': { so: 'Wax-bixinno la xaqiijiyay', en: 'Confirmed donations' },
  'adminOverview.campaignsAwaitingReview': { so: 'Ololayaal sugaya eegis', en: 'Campaigns awaiting review' },
  'adminOverview.pendingVerification': { so: 'Faa\'iidaystayaal sugaya xaqiijin', en: 'Beneficiaries pending verification' },
  'adminOverview.activeCampaigns': { so: 'Ololayaal firfircoon', en: 'Active campaigns' },
  'adminOverview.openTickets': { so: 'Tigidhada taageero ee furan', en: 'Open support tickets' },
  'adminOverview.fraudNote': {
    so: 'Astaamaha Khiyaanada & Halista waxaa lagu xisaabiyaa xog dhab ah oo ku saabsan wax-bixin/akoon/olole iyadoo la adeegsanayo xeerar fudud, la fahmi karo — ma aha isku-dhafan koritaan mashiin. Xogaha guusha lacag-bixinta weli lama la socdo.',
    en: 'Fraud & Risk signals are computed live from real donation/account/campaign data using simple, explainable rules — not a machine-learning risk score. Payment success-rate metrics are not tracked yet.',
  },

  // Fraud & Risk (admin)
  'fraudRisk.explanation': {
    so: 'Astaamaha hoos ku qoran waxaa lagu xisaabiyaa xog dhab ah oo ku saabsan wax-bixin, akoon, iyo olole iyadoo la adeegsanayo xeerar fudud oo la fahmi karo (xawaaraha wax-bixinta, akoonno cusub oo bilaabaya ololayaal hadaf sare leh, wax-bixinno soo noqnoqda oo isla olole ah). Kani ma aha isku-dhafan koritaan mashiin — u tixgeli astaan kasta bilow eegis gacan lagu sameeyo, ma aha go\'aan.',
    en: 'Signals below are computed live from real donation, account, and campaign data using simple, explainable rules (donation velocity, brand-new accounts launching high-goal campaigns, repeat donations to the same campaign). This is not a machine-learning risk score — treat each signal as a starting point for a manual look, not a verdict.',
  },
  'fraudRisk.loadErrorTitle': { so: 'Astaamaha khiyaanada lama soo rarin karin', en: "Couldn't load fraud signals" },
  'fraudRisk.emptyTitle': { so: 'Astaamo firfircoon ma jiraan', en: 'No active signals' },
  'fraudRisk.emptyDesc': { so: 'Wax hadda kuma wehelin xeerarka ogaanshaha khiyaanada.', en: 'Nothing currently matches the fraud-detection rules.' },
  'fraudRisk.review': { so: 'Eeg', en: 'Review' },

  // Admin Support Tickets
  'adminSupport.noTicketsPrefix': { so: 'Ma jiraan tigidho', en: 'No' },
  'adminSupport.emptyDesc': { so: 'Fariimaha laga soo diray bogga La soo xiriir halkan ayey ka soo muuqan doonaan.', en: 'Messages sent from the Contact page will appear here.' },
  'adminSupport.from': { so: 'Waxaa ka yimid', en: 'From' },
  'adminSupport.unknown': { so: 'Aan la aqoon', en: 'Unknown' },
  'adminSupport.noEmail': { so: 'email ma jiro', en: 'no email' },
  'adminSupport.supportYou': { so: 'Taageero (adiga)', en: 'Support (you)' },
  'adminSupport.userLabel': { so: 'Isticmaale', en: 'User' },
  'adminSupport.markPrefix': { so: 'Calaamadi', en: 'Mark' },

  // Admin Campaigns
  'adminCampaigns.approve': { so: 'Ansixi ololaha', en: 'Approve campaign' },
  'adminCampaigns.startReview': { so: 'Bilow eegis', en: 'Start review' },
  'adminCampaigns.reject': { so: 'Diid ololaha', en: 'Reject campaign' },
  'adminCampaigns.publish': { so: 'Daabac ololaha', en: 'Publish campaign' },
  'adminCampaigns.suspend': { so: 'Joojii ololaha', en: 'Suspend campaign' },
  'adminCampaigns.restore': { so: 'Soo celi ololaha', en: 'Restore campaign' },
  'adminCampaigns.actionError': { so: 'Falkan lama dhammaystiri karin.', en: 'This action could not be completed.' },
  'adminCampaigns.all': { so: 'Dhammaan', en: 'All' },
  'adminCampaigns.emptyTitle': { so: 'Olole xaaladdan kuma jiro', en: 'No campaigns in this status' },
  'adminCampaigns.emptyDesc': { so: 'Isku day shaandhayn kale oo kore ah.', en: 'Try a different filter above.' },
  'adminCampaigns.goalSuffix': { so: 'hadaf', en: 'goal' },
  'adminCampaigns.reasonVisibleNote': { so: 'Falkani wuxuu u muuqdaa abaabulaha. Fadlan sharax sababta, si ay u fahmaan waxa la saxo.', en: 'This action is visible to the organizer. Please explain why, so they understand what to fix.' },
  'adminCampaigns.reasonPlaceholder': { so: 'Sababta (waajib)', en: 'Reason (required)' },
  'adminCampaigns.confirmPrefix': { so: 'Xaqiiji', en: 'Confirm' },

  // Verification Queue
  'verificationQueue.emptyTitle': { so: 'Waxba sugaya ma jiraan', en: 'Nothing pending' },
  'verificationQueue.emptyDesc': { so: 'Faa\'iidaystayaasha sugaya xaqiijin halkan ayey ka soo muuqan doonaan.', en: 'Beneficiaries awaiting verification will appear here.' },
  'verificationQueue.account': { so: 'Akoon', en: 'Account' },
  'verificationQueue.verify': { so: 'Xaqiiji', en: 'Verify' },
  'verificationQueue.reject': { so: 'Diid', en: 'Reject' },

  // User Management
  'userManagement.searchPlaceholder': { so: 'Ku raadi magac ama email', en: 'Search by name or email' },
  'userManagement.emptyTitle': { so: 'Isticmaale lama helin', en: 'No users found' },
  'userManagement.emptyDesc': { so: 'Isku day erayo raadin kale ah.', en: 'Try a different search term.' },
  'userManagement.name': { so: 'Magac', en: 'Name' },
  'userManagement.roles': { so: 'Doorarka', en: 'Roles' },
  'userManagement.actions': { so: 'Ficillo', en: 'Actions' },
  'userManagement.suspend': { so: 'Joojii', en: 'Suspend' },
  'userManagement.reactivate': { so: 'Dib u dhaqaajin', en: 'Reactivate' },

  // Admin Reports
  'adminReports.loadErrorTitle': { so: 'Warbixinnada lama soo rarin karin', en: "Couldn't load reports" },
  'adminReports.emptyTitle': { so: 'Warbixin furan ma jirto', en: 'No open reports' },
  'adminReports.emptyDesc': { so: 'Warbixinta ka timid wax-bixiyayaasha iyo abaabulayaasha halkan ayey ka soo muuqan doonaan.', en: 'Reports from donors and organizers will appear here.' },
  'adminReports.reportedBy': { so: 'waxaa warbixiyay', en: 'reported by' },
  'adminReports.viewTarget': { so: 'arag bartilmaameedka', en: 'view target' },
  'adminReports.markReviewed': { so: 'Calaamadi in la eegay', en: 'Mark reviewed' },
  'adminReports.dismiss': { so: 'Diid', en: 'Dismiss' },

  // Audit Logs
  'auditLogs.loadErrorTitle': { so: 'Diiwaanka la eegay lama soo rarin karin', en: "Couldn't load audit logs" },
  'auditLogs.emptyTitle': { so: 'Wali dhaqdhaqaaq ma jiro', en: 'No activity yet' },
  'auditLogs.emptyDesc': { so: 'Ficillada admin-ka iyo lacagta halkan ayey ka soo muuqan doonaan marka ay dhacaan.', en: 'Admin and financial actions will appear here as they happen.' },
  'auditLogs.time': { so: 'Waqti', en: 'Time' },
  'auditLogs.actor': { so: 'Falaha', en: 'Actor' },
  'auditLogs.action': { so: 'Ficil', en: 'Action' },
  'auditLogs.target': { so: 'Bartilmaameed', en: 'Target' },

  // Admin Donations
  'adminDonations.confirmSingleError': { so: 'Lacag-bixintan lama xaqiijin karin.', en: 'Could not confirm this payment.' },
  'adminDonations.confirmBatchError': { so: 'Lacag-bixinnadan lama xaqiijin karin.', en: 'Could not confirm these payments.' },
  'adminDonations.selected': { so: 'la doortay', en: 'selected' },
  'adminDonations.clear': { so: 'Nadiifi', en: 'Clear' },
  'adminDonations.confirmSelectedPrefix': { so: 'Xaqiiji', en: 'Confirm' },
  'adminDonations.nothingAwaitingTitle': { so: 'Waxba sugaya xaqiijin ma jiraan', en: 'Nothing awaiting confirmation' },
  'adminDonations.nothingAwaitingDesc': { so: 'Wax-bixinnada lagu sameeyay habka gacanta ah halkan ayey ka soo muuqan doonaan si aad u xaqiijiso marka lacagtu timaado.', en: 'Donations made through the manual payment method will appear here for you to confirm once the money arrives.' },
  'adminDonations.date': { so: 'Taariikh', en: 'Date' },
  'adminDonations.donor': { so: 'Wax-bixiye', en: 'Donor' },
  'adminDonations.method': { so: 'Habka', en: 'Method' },
  'adminDonations.guest': { so: 'Marti', en: 'Guest' },
  'adminDonations.confirm': { so: 'Xaqiiji', en: 'Confirm' },
  'adminDonations.batchCompleteTitle': { so: 'Xaqiijinta kooxeed way dhammaatay', en: 'Batch confirmation complete' },
  'adminDonations.confirmedSuffix': { so: 'la xaqiijiyay', en: 'confirmed' },
  'adminDonations.failedSuffix': { so: 'fashilmay', en: 'failed' },
  'adminDonations.done': { so: 'Dhammaystiran', en: 'Done' },
  'adminDonations.confirmNPrefix': { so: 'Xaqiiji', en: 'Confirm' },
  'adminDonations.confirmNSuffix': { so: 'wax-bixin?', en: 'donations?' },
  'adminDonations.batchConfirmNote': {
    so: 'Kaliya xaqiiji ka dib marka aad hubiso in wareejin kasta si dhab ah u timid (tusaale ahaan, ku hubi bayaanka mobile money). Tani waxay isla markiiba cusboonaysiisaa qadarka la ururiyay ee olole kasta oo saameeyay.',
    en: 'Only confirm after verifying each transfer genuinely arrived (e.g. against a mobile money statement). This updates the raised amount on every affected campaign immediately.',
  },
  'adminDonations.confirming': { so: 'Waa la xaqiijinayaa…', en: 'Confirming…' },
  'adminDonations.confirmThisTitle': { so: 'Xaqiiji wax-bixintan?', en: 'Confirm this donation?' },
  'adminDonations.singleConfirmNote': {
    so: 'Kaliya xaqiiji ka dib marka aad hubiso in lacagtu si dhab ah u timid (tusaale ahaan, tixraaca mobile money ama xawaalad). Tani waxay isla markiiba cusboonaysiisaa qadarka la ururiyay ee ololaha.',
    en: 'Only confirm after verifying the money genuinely arrived (e.g. mobile money or hawala reference). This updates the campaign\'s raised amount immediately.',
  },
  'adminDonations.referenceLabel': { so: 'Tixraaca macaamilka (ikhtiyaari)', en: 'Transaction reference (optional)' },
  'adminDonations.referencePlaceholder': { so: 'tusaale ahaan: lambarka xaqiijinta EVC Plus', en: 'e.g. EVC Plus confirmation code' },
  'adminDonations.confirmPayment': { so: 'Xaqiiji lacag-bixinta', en: 'Confirm payment' },

  // Progress bar
  'progressBar.raisedOf': { so: 'waxaa la ururiyay', en: 'raised of' },

  // Category names (Campaign.category enum — value stored in English, label translated)
  'category.Medical': { so: 'Caafimaad', en: 'Medical' },
  'category.Education': { so: 'Waxbarasho', en: 'Education' },
  'category.Emergency': { so: 'Degdeg', en: 'Emergency' },
  'category.Family': { so: 'Qoys', en: 'Family' },
  'category.Funeral': { so: 'Aas', en: 'Funeral' },
  'category.Community': { so: 'Bulsho', en: 'Community' },
  'category.Mosque': { so: 'Masjid', en: 'Mosque' },
  'category.School': { so: 'Dugsi', en: 'School' },
  'category.Orphan Support': { so: 'Taageero Agoon', en: 'Orphan Support' },
  'category.Disaster Relief': { so: 'Gargaar Masiibo', en: 'Disaster Relief' },
  'category.Business/Startup': { so: 'Ganacsi/Bilow', en: 'Business/Startup' },
  'category.NGO': { so: 'Hay\'ad aan faa\'iido doon ahayn', en: 'NGO' },
  'category.Public Projects': { so: 'Mashaariic Dadweyne', en: 'Public Projects' },
  'category.Other': { so: 'Kale', en: 'Other' },

  // Explore
  'explore.title': { so: 'Baadh ololayaasha', en: 'Explore campaigns' },
  'explore.searchPlaceholder': { so: 'Raadi ololayaal, sababo, ama bulshooyin', en: 'Search campaigns, causes, or communities' },
  'explore.category': { so: 'Qaybta', en: 'Category' },
  'explore.region': { so: 'Gobolka', en: 'Region' },
  'explore.allCategories': { so: 'Dhammaan qaybaha', en: 'All categories' },
  'explore.allRegions': { so: 'Dhammaan gobollada', en: 'All regions' },
  'explore.loadError': { so: 'Ma soo raranno ololayaasha hadda. Fadlan hubi xiriirkaaga oo mar kale isku day.', en: 'We could not load campaigns right now. Please check your connection and try again.' },
  'explore.errorTitle': { so: 'Ololayaasha lama soo rarin karin', en: "Couldn't load campaigns" },
  'explore.emptyTitle': { so: 'Ma jiraan ololayaal la mid ah shaandhadan', en: 'No campaigns match these filters' },
  'explore.emptyDescription': { so: 'Isku day qayb ama gobol kale, ama nadiifi raadintaada.', en: 'Try a different category or region, or clear your search.' },

  // Campaign card
  'card.supporter': { so: 'taageere', en: 'supporter' },
  'card.supporters': { so: 'taageere', en: 'supporters' },

  // Campaign Detail
  'campaign.notFoundTitle': { so: 'Ololaha lama helin ama ma jiro', en: 'Campaign not found or unavailable' },
  'campaign.notFoundDesc': { so: 'Ololahan waa laga saarayay, ama linkigu waa qalad.', en: 'This campaign may have been removed, or the link is incorrect.' },
  'campaign.backToExplore': { so: 'Ku noqo Baadhista', en: 'Back to Explore' },
  'campaign.save': { so: 'Kaydi', en: 'Save' },
  'campaign.saved': { so: 'Waa kaydsan yahay', en: 'Saved' },
  'campaign.theStory': { so: 'Sheekada', en: 'The story' },
  'campaign.recentDonations': { so: 'Wax-bixinnadii ugu dambeeyay', en: 'Recent donations' },
  'campaign.noDonationsTitle': { so: 'Wali wax bixin ma jirto', en: 'No donations yet' },
  'campaign.noDonationsDesc': { so: 'Noqo qofka ugu horreeya ee taageera ololahan.', en: 'Be the first to support this campaign.' },
  'campaign.anonymous': { so: 'Qof aan la aqoon', en: 'Anonymous' },
  'campaign.updates': { so: 'Cusboonaysiinno', en: 'Updates' },
  'campaign.following': { so: '✓ La socda', en: '✓ Following' },
  'campaign.followForUpdates': { so: 'La soco cusboonaysiinta', en: 'Follow for updates' },
  'campaign.noUpdatesTitle': { so: 'Wali cusboonaysiin ma jirto', en: 'No updates yet' },
  'campaign.noUpdatesDesc': {
    so: 'Cusboonaysiinta xigta ee abaabulaha halkan ayey ka soo muuqan doontaa si aad u aragto sida lacagta loo isticmaalayo.',
    en: "The organizer's next update will appear here so you can see how funds are being used.",
  },
  'campaign.regionNotSpecified': { so: 'Gobol lama sheegin', en: 'Region not specified' },
  'campaign.donateButton': { so: 'Ku bixi ololahan', en: 'Donate to this campaign' },
  'campaign.linkCopied': { so: 'Link-ga waa la nuqulay', en: 'Link copied' },
  'campaign.share': { so: 'La wadaag', en: 'Share' },
  'campaign.report': { so: 'Ka warbixi', en: 'Report' },
  'campaign.reportSubmittedTitle': { so: 'Warbixinta waa la diray', en: 'Report submitted' },
  'campaign.reportSubmittedDesc': { so: 'Kooxdayada Kalsoonida & Nabadgelyada ayaa eegi doonta ololahan.', en: 'Our Trust & Safety team will review this campaign.' },
  'campaign.close': { so: 'Xir', en: 'Close' },
  'campaign.reportTitle': { so: 'Ka warbixi ololahan', en: 'Report this campaign' },
  'campaign.reportDesc': { so: 'Noo sheeg waxa khaldan. Warbixintaada waxaa eegaya kooxdayada.', en: 'Tell us what looks wrong. Your report is reviewed by our team.' },
  'campaign.reportPlaceholder': { so: 'Waa maxay walaaca?', en: "What's the concern?" },
  'campaign.cancel': { so: 'Jooji', en: 'Cancel' },
  'campaign.submitReport': { so: 'Dir warbixinta', en: 'Submit report' },
  'campaign.reportError': { so: 'Warbixinta lama diri karin.', en: 'Could not submit this report.' },

  // Region names
  'region.Mogadishu': { so: 'Muqdisho', en: 'Mogadishu' },
  'region.Hargeisa': { so: 'Hargeysa', en: 'Hargeisa' },
  'region.Puntland': { so: 'Puntland', en: 'Puntland' },
  'region.Nairobi': { so: 'Nairobi', en: 'Nairobi' },
};

// Look up a Campaign.category or region enum value's display label. Falls
// back to the raw value for anything not in the map (e.g. a free-text
// region) so the UI never shows a blank or a translation key.
export function categoryLabel(value, language) {
  return translations[`category.${value}`]?.[language] || value;
}
export function regionLabel(value, language) {
  return translations[`region.${value}`]?.[language] || value;
}
