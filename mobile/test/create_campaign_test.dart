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
import 'package:kaalmo_mobile/features/auth/presentation/login_screen.dart';
import 'package:kaalmo_mobile/features/organizer/application/create_campaign_controller.dart';
import 'package:kaalmo_mobile/features/organizer/application/organizer_access_controller.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/campaign_manage_screen.dart';
import 'package:kaalmo_mobile/features/organizer/presentation/start_fundraiser_screen.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://localhost:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

ProviderContainer _container({
  required FakeAuthRepository auth,
  FakeOrganizerRepository? organizer,
  FakeCampaignRepository? campaigns,
}) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(auth),
    organizerRepositoryProvider.overrideWithValue(organizer ?? FakeOrganizerRepository()),
    campaignRepositoryProvider.overrideWithValue(campaigns ?? FakeCampaignRepository()),
  ]);
  addTearDown(c.dispose);
  return c;
}

Future<T> _keepAlive<T>(ProviderContainer c, ProviderListenable<T> p) async {
  final sub = c.listen(p, (_, _) {});
  addTearDown(sub.close);
  await c.read(authControllerProvider.notifier).bootstrap();
  await pumpEventQueue();
  return c.read(p);
}

Future<ProviderContainer> _pumpStart(
  WidgetTester tester, {
  required FakeAuthRepository auth,
  FakeOrganizerRepository? organizer,
  FakeCampaignRepository? campaigns,
}) async {
  tester.view.physicalSize = const Size(1200, 6000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(ProviderScope(
    overrides: [
      appConfigProvider.overrideWithValue(_config),
      authRepositoryProvider.overrideWithValue(auth),
      organizerRepositoryProvider.overrideWithValue(organizer ?? FakeOrganizerRepository()),
      campaignRepositoryProvider.overrideWithValue(campaigns ?? FakeCampaignRepository()),
    ],
    child: const KaalmoApp(),
  ));
  await tester.pumpAndSettle();
  final container = ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  container.read(goRouterProvider).go('/organizer/start');
  await tester.pumpAndSettle();
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('CreateCampaignController', () {
    test('validates title / story / goal before allowing submit', () async {
      final c = _container(auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['donor', 'organizer'])));
      await _keepAlive(c, createCampaignControllerProvider);
      final ctrl = c.read(createCampaignControllerProvider.notifier);

      ctrl.setTitleSo('abc'); // < 5
      expect(c.read(createCampaignControllerProvider).titleSoError, 'min');
      ctrl.setTitleSo('A real campaign title');
      ctrl.setStorySo('too short'); // < 20
      expect(c.read(createCampaignControllerProvider).storySoError, 'min');
      ctrl.setStorySo('This is a long enough story to pass the minimum.');
      ctrl.setGoal('0');
      expect(c.read(createCampaignControllerProvider).goalError, 'invalid');
      ctrl.setGoal('500');

      expect(c.read(createCampaignControllerProvider).canSubmit, isTrue);
    });

    test('submit sends the backend contract shape and lands on done', () async {
      final org = FakeOrganizerRepository()..createResult = fakeCampaign(id: 'camp-77', status: 'draft');
      final c = _container(
        auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['organizer'])),
        organizer: org,
      );
      await _keepAlive(c, createCampaignControllerProvider);
      final ctrl = c.read(createCampaignControllerProvider.notifier);

      ctrl.setTitleSo('Ka caawi qoyska Xamar');
      ctrl.setTitleEn('Help the Xamar family');
      ctrl.setStorySo('Sheeko dheer oo ku filan si loo gaaro xadka ugu yar ee shuruudda.');
      ctrl.setCategory('Family');
      ctrl.setGoal('1200');
      ctrl.setRegion('Mogadishu');

      final result = await ctrl.submit();
      await pumpEventQueue();

      expect(result?.id, 'camp-77');
      expect(c.read(createCampaignControllerProvider).phase, CreatePhase.done);
      expect(org.createCalls, hasLength(1));
      final body = org.createCalls.first;
      expect((body['title'] as Map)['so'], 'Ka caawi qoyska Xamar');
      expect((body['title'] as Map)['en'], 'Help the Xamar family');
      expect((body['story'] as Map)['so'], startsWith('Sheeko dheer'));
      expect(body['category'], 'Family');
      expect(body['goalAmount'], 1200);
      expect(body['region'], 'Mogadishu');
      expect(body.containsKey('coverImageUrl'), isFalse); // no mobile upload — omitted
    });

    test('a backend error surfaces without a false success', () async {
      final org = FakeOrganizerRepository()
        ..createError = const ApiException('bad', statusCode: 400, code: 'VALIDATION_ERROR');
      final c = _container(auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['organizer'])), organizer: org);
      await _keepAlive(c, createCampaignControllerProvider);
      final ctrl = c.read(createCampaignControllerProvider.notifier);
      ctrl.setTitleSo('A valid campaign title here');
      ctrl.setStorySo('A story that is definitely long enough to pass validation.');
      ctrl.setGoal('300');

      await ctrl.submit();
      await pumpEventQueue();
      final s = c.read(createCampaignControllerProvider);
      expect(s.phase, CreatePhase.error);
      expect(s.error, isA<ApiException>());
      expect(s.created, isNull);
    });
  });

  group('OrganizerAccessController', () {
    test('send → code sent → confirm upgrades the account to organizer', () async {
      final auth = FakeAuthRepository(startWithSession: fakeUser(roles: ['donor']));
      final c = _container(auth: auth);
      await _keepAlive(c, organizerAccessControllerProvider);
      final ctrl = c.read(organizerAccessControllerProvider.notifier);

      ctrl.setFullName('Amina Ali');
      await ctrl.sendCode();
      await pumpEventQueue();
      expect(c.read(organizerAccessControllerProvider).phase, OrganizerAccessPhase.codeSent);
      expect(auth.calls.any((x) => x.startsWith('requestOrganizerAccess:Amina Ali')), isTrue);

      ctrl.setCode('123456');
      final ok = await ctrl.confirm();
      await pumpEventQueue();
      expect(ok, isTrue);
      expect(auth.calls, contains('confirmOrganizerAccess:123456'));
      expect(c.read(authControllerProvider).user?.isOrganizer, isTrue);
    });

    test('a wrong code returns to the code step with an error, role unchanged', () async {
      final auth = FakeAuthRepository(startWithSession: fakeUser(roles: ['donor']))
        ..confirmOrganizerError = const ApiException('bad code', statusCode: 400, code: 'INVALID_CODE');
      final c = _container(auth: auth);
      await _keepAlive(c, organizerAccessControllerProvider);
      final ctrl = c.read(organizerAccessControllerProvider.notifier);
      ctrl.setFullName('Amina Ali');
      await ctrl.sendCode();
      ctrl.setCode('000000');
      final ok = await ctrl.confirm();
      await pumpEventQueue();
      expect(ok, isFalse);
      expect(c.read(organizerAccessControllerProvider).phase, OrganizerAccessPhase.codeSent);
      expect(c.read(organizerAccessControllerProvider).error, isA<ApiException>());
      expect(c.read(authControllerProvider).user?.isOrganizer, isFalse);
    });

    test('cannot send without a name', () async {
      final c = _container(auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['donor'])));
      await _keepAlive(c, organizerAccessControllerProvider);
      final ctrl = c.read(organizerAccessControllerProvider.notifier);
      ctrl.setFullName('A');
      expect(c.read(organizerAccessControllerProvider).canSend, isFalse);
    });
  });

  group('Start a fundraiser screen', () {
    testWidgets('a guest is bounced to login', (tester) async {
      await _pumpStart(tester, auth: FakeAuthRepository());
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(StartFundraiserScreen), findsNothing);
    });

    testWidgets('a donor sees the become-an-organizer step', (tester) async {
      await _pumpStart(tester, auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['donor'])));
      expect(find.byType(StartFundraiserScreen), findsOneWidget);
      expect(find.text('Become an organizer'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Send code'), findsOneWidget);
    });

    testWidgets('an organizer sees the create-campaign form and can submit', (tester) async {
      final org = FakeOrganizerRepository()..createResult = fakeCampaign(id: 'c-new', status: 'draft');
      final campaigns = FakeCampaignRepository()..campaign = fakeCampaign(id: 'c-new', status: 'draft');
      await _pumpStart(
        tester,
        auth: FakeAuthRepository(startWithSession: fakeUser(roles: ['organizer'])),
        organizer: org,
        campaigns: campaigns,
      );

      expect(find.text('Campaign details'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('cc_titleSo')), 'Ololaha caafimaadka carruurta');
      await tester.enterText(
        find.byKey(const Key('cc_storySo')),
        'Sheeko dheer oo faahfaahin ku filan leh si loo gaaro xadka ugu yar.',
      );
      await tester.enterText(find.byKey(const Key('cc_goal')), '900');
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Create campaign'));
      await tester.pumpAndSettle();

      expect(org.createCalls, hasLength(1));
      expect(find.byType(CampaignManageScreen), findsOneWidget);
    });
  });
}
