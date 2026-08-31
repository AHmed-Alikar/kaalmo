import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/app.dart';
import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/router/app_router.dart';
import 'package:kaalmo_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:kaalmo_mobile/features/auth/presentation/login_screen.dart';
import 'package:kaalmo_mobile/features/organizer/data/models/campaign_invite.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/campaign_manage_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/organizer_invites_screen.dart';
import 'package:kaalmo_mobile/features/profile/presentation/about_screen.dart';
import 'package:kaalmo_mobile/features/profile/presentation/settings_screen.dart';
import 'package:kaalmo_mobile/features/support/data/models/support_ticket.dart';
import 'package:kaalmo_mobile/features/support/presentation/create_ticket_screen.dart';
import 'package:kaalmo_mobile/features/support/presentation/support_screen.dart';
import 'package:kaalmo_mobile/features/support/presentation/ticket_detail_screen.dart';
import 'package:kaalmo_mobile/shared/states/state_views.dart';
import 'package:kaalmo_mobile/shared/widgets/not_found_screen.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  bool authed = true,
  FakeSupportRepository? support,
  FakeOrganizerRepository? organizer,
  FakeCampaignRepository? campaigns,
  String start = '/profile',
}) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        authRepositoryProvider.overrideWithValue(
          authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
        ),
        supportRepositoryProvider.overrideWithValue(support ?? FakeSupportRepository()),
        organizerRepositoryProvider.overrideWithValue(organizer ?? FakeOrganizerRepository()),
        campaignRepositoryProvider.overrideWithValue(campaigns ?? FakeCampaignRepository()),
      ],
      child: const KaalmoApp(),
    ),
  );
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go(start);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('routing & profile', () {
    testWidgets('Profile → Settings → About', (tester) async {
      await _pump(tester, start: '/profile');
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(find.text('About Kaalmo'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.textContaining('kaalmo.example/terms'), findsOneWidget);
    });

    testWidgets('an unknown route shows the localized NotFoundScreen', (tester) async {
      final c = await _pump(tester, start: '/profile');
      c.read(goRouterProvider).go('/this-route/does-not-exist');
      await tester.pumpAndSettle();
      expect(find.byType(NotFoundScreen), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget); // AppBar title only
      expect(find.widgetWithText(FilledButton, 'Go to Home'), findsOneWidget);
    });
  });

  group('settings', () {
    testWidgets('edit name calls PATCH /users/me and shows a confirmation', (tester) async {
      final c = await _pump(tester, start: '/profile/settings');
      final auth = c.read(authRepositoryProvider) as FakeAuthRepository;

      await tester.tap(find.text('Edit name'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'New Name');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(auth.calls.any((x) => x.startsWith('updateProfile:New Name')), isTrue);
      expect(find.text('Your name has been updated.'), findsOneWidget);
    });

    testWidgets('toggling push notifications persists via PATCH', (tester) async {
      final c = await _pump(tester, start: '/profile/settings');
      final auth = c.read(authRepositoryProvider) as FakeAuthRepository;
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(auth.calls.any((x) => x.contains('updateProfile') && x.endsWith('false')), isTrue);
    });

    testWidgets('change password confirms, signs out, and opens forgot-password', (tester) async {
      final c = await _pump(tester, start: '/profile/settings');
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();
      expect(c.read(authControllerProvider).isAuthenticated, isFalse);
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('close account routes to a pre-filled support request', (tester) async {
      await _pump(tester, start: '/profile/settings');
      await tester.tap(find.text('Close my account'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateTicketScreen), findsOneWidget);
      expect(find.text('Please close my Kaalmo account'), findsOneWidget);
    });
  });

  group('support', () {
    testWidgets('list, empty and error states', (tester) async {
      final repo = FakeSupportRepository()..ticketsError = const NetworkException('offline');
      await _pump(tester, support: repo, start: '/support');
      expect(find.byType(ErrorView), findsOneWidget);

      repo.ticketsError = null;
      repo.tickets = const [];
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();
      expect(find.text('No support requests'), findsOneWidget);
    });

    testWidgets('renders tickets with status', (tester) async {
      final repo = FakeSupportRepository()
        ..tickets = [
          fakeTicket(id: 'a', subject: 'Payment issue', status: 'open'),
          fakeTicket(id: 'b', subject: 'Question', status: 'resolved'),
        ];
      await _pump(tester, support: repo, start: '/support');
      expect(find.text('Payment issue'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Resolved'), findsOneWidget);
    });

    testWidgets('create a ticket → opens the new ticket', (tester) async {
      final repo = FakeSupportRepository()
        ..createResult = fakeTicket(id: 'new1', subject: 'My subject line');
      await _pump(tester, support: repo, start: '/support/new');

      await tester.enterText(find.widgetWithText(TextField, 'Subject'), 'My subject line');
      await tester.enterText(find.widgetWithText(TextField, 'Message'), 'Here is my detailed problem.');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Send'));
      await tester.pumpAndSettle();

      expect(repo.calls.any((x) => x.startsWith('create:')), isTrue);
      expect(find.byType(TicketDetailScreen), findsOneWidget);
    });

    testWidgets('ticket detail shows the thread and accepts a reply', (tester) async {
      final repo = FakeSupportRepository()
        ..ticket = fakeTicket(id: 't1', subject: 'Payment issue', status: 'in_progress', replies: [
          const TicketReply(authorRole: 'admin', message: 'We are checking this.'),
        ]);
      await _pump(tester, support: repo, start: '/support/t1');

      expect(find.byType(TicketDetailScreen), findsOneWidget);
      expect(find.textContaining('We are checking this.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Thank you');
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(repo.calls.any((x) => x.startsWith('reply:t1:')), isTrue);
    });

    testWidgets('a guest is redirected to login', (tester) async {
      await _pump(tester, authed: false, start: '/support');
      expect(find.byType(SupportScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('co-organizer invitations', () {
    testWidgets('empty and populated states', (tester) async {
      final repo = FakeOrganizerRepository()..invites = const [];
      await _pump(tester, organizer: repo, start: '/organizer/invites');
      expect(find.byType(OrganizerInvitesScreen), findsOneWidget);
      expect(find.text('No invitations'), findsOneWidget);
    });

    testWidgets('accept an invitation → records the call and navigates', (tester) async {
      final repo = FakeOrganizerRepository()..invites = [fakeInvite(id: 'inv1', campaignId: 'c1')];
      final campaigns = FakeCampaignRepository()..campaign = fakeCampaign(id: 'c1', status: 'active');
      await _pump(tester, organizer: repo, campaigns: campaigns, start: '/organizer/invites');

      expect(find.textContaining('invited you'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Accept invitation'));
      await tester.pumpAndSettle();
      expect(repo.calls, contains('acceptInvite:inv1'));
      expect(find.byType(CampaignManageScreen), findsOneWidget);
    });

    testWidgets('accept failure shows a message', (tester) async {
      final repo = FakeOrganizerRepository()
        ..invites = [fakeInvite(id: 'inv1')]
        ..acceptInviteError = const ApiException('gone', statusCode: 404, code: 'NOT_FOUND');
      await _pump(tester, organizer: repo, start: '/organizer/invites');
      await tester.tap(find.widgetWithText(FilledButton, 'Accept invitation'));
      await tester.pumpAndSettle();
      expect(find.byType(OrganizerInvitesScreen), findsOneWidget);
    });
  });

  group('invite model', () {
    test('parses populated campaign + inviter', () {
      final i = CampaignInvite.fromJson({
        '_id': 'inv1',
        'campaignId': {'_id': 'c1', 'title': {'en': 'Medical', 'so': 'Caafimaad'}},
        'invitedBy': {'_id': 'u9', 'fullName': 'Yusuf M.'},
        'createdAt': '2026-08-27T00:00:00.000Z',
      });
      expect(i.campaignId, 'c1');
      expect(i.titleFor('en'), 'Medical');
      expect(i.inviterName, 'Yusuf M.');
    });
  });
}
