import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/network/api_client.dart';
import 'package:kaalmo_mobile/features/beneficiary/application/beneficiary_controllers.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/beneficiary_api.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/beneficiary_repository.dart';
import 'package:kaalmo_mobile/features/beneficiary/data/models/beneficiary_profile.dart';

import 'support/fakes.dart';
import 'support/stub_adapter.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

BeneficiaryRepository _repo(Future<ResponseBody> Function(RequestOptions o) handler) {
  final client = ApiClient.create(config: _config)..raw.httpClientAdapter = StubAdapter(handler);
  return BeneficiaryRepository(BeneficiaryApi(client));
}

ProviderContainer _c(FakeBeneficiaryRepository repo) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(startWithSession: fakeUser())),
    beneficiaryRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

void _alive(ProviderContainer c, ProviderListenable<Object?> p) {
  final sub = c.listen(p, (_, _) {});
  addTearDown(sub.close);
}

void main() {
  group('BeneficiaryProfile', () {
    test('fromJson + status view', () {
      final p = BeneficiaryProfile.fromJson({
        '_id': 'b1',
        'fullName': 'Amina Ali',
        'verificationStatus': 'verified',
        'verifiedAt': '2026-08-25T00:00:00.000Z',
        'payoutAccountId': 'pa1',
      });
      expect(p.fullName, 'Amina Ali');
      expect(p.isVerified, isTrue);
      expect(p.statusView, BeneficiaryStatusView.verified);
      expect(p.hasLinkedPayoutAccount, isTrue);
      expect(p.payoutReady, isTrue);
    });

    test('verified but no payout account is not payout-ready', () {
      final p = BeneficiaryProfile.fromJson({'_id': 'b1', 'fullName': 'X', 'verificationStatus': 'verified'});
      expect(p.isVerified, isTrue);
      expect(p.payoutReady, isFalse);
    });

    test('unknown status → none', () {
      expect(BeneficiaryStatusView.from(null), BeneficiaryStatusView.none);
      expect(BeneficiaryStatusView.from('weird'), BeneficiaryStatusView.none);
    });
  });

  group('BeneficiaryRepository', () {
    test('getMyProfile maps 404 to null (not an error)', () async {
      final repo = _repo((o) async => jsonResponse(404, {
            'error': {'code': 'NOT_FOUND', 'message': 'none', 'fields': {}}
          }));
      expect(await repo.getMyProfile(), isNull);
    });

    test('getMyProfile parses a real profile', () async {
      final repo = _repo((o) async {
        expect(o.path, contains('/beneficiaries/me'));
        return jsonResponse(200, {'_id': 'b1', 'fullName': 'Amina', 'verificationStatus': 'pending'});
      });
      final p = await repo.getMyProfile();
      expect(p, isNotNull);
      expect(p!.isPending, isTrue);
    });

    test('getMyProfile rethrows a real server error', () async {
      final repo = _repo((o) async => jsonResponse(500, {
            'error': {'code': 'SERVER_ERROR', 'message': 'boom', 'fields': {}}
          }));
      expect(repo.getMyProfile, throwsA(isA<ApiException>()));
    });

    test('myPayoutAccounts parses the list, skipping bad entries', () async {
      final repo = _repo((o) async => jsonResponse(200, [
            {'_id': 'a', 'type': 'bank', 'accountNumberMasked': '***1', 'providerName': 'P', 'verified': true},
            'bad',
          ]));
      final list = await repo.myPayoutAccounts();
      expect(list, hasLength(1));
      expect(list.first.verified, isTrue);
    });
  });

  group('BeneficiaryIdentityController', () {
    test('rejects a too-short name', () async {
      final repo = FakeBeneficiaryRepository();
      final c = _c(repo);
      _alive(c, beneficiaryIdentityControllerProvider(''));
      final ctrl = c.read(beneficiaryIdentityControllerProvider('').notifier);
      ctrl.setName('A');
      expect(c.read(beneficiaryIdentityControllerProvider('')).canSubmit, isFalse);
      expect(await ctrl.submit(), isNull);
      expect(repo.calls, isEmpty);
    });

    test('submit success returns the pending profile', () async {
      final repo = FakeBeneficiaryRepository();
      final c = _c(repo);
      _alive(c, beneficiaryIdentityControllerProvider(''));
      final ctrl = c.read(beneficiaryIdentityControllerProvider('').notifier);
      ctrl.setName('Amina Ali');
      final p = await ctrl.submit();
      expect(p, isNotNull);
      expect(p!.isPending, isTrue);
      expect(repo.calls, contains('submitProfile:Amina Ali'));
    });

    test('submit failure surfaces the error', () async {
      final repo = FakeBeneficiaryRepository()
        ..submitError = const ApiException('conflict', statusCode: 409, code: 'ALREADY_VERIFIED');
      final c = _c(repo);
      _alive(c, beneficiaryIdentityControllerProvider(''));
      final ctrl = c.read(beneficiaryIdentityControllerProvider('').notifier);
      ctrl.setName('Amina Ali');
      expect(await ctrl.submit(), isNull);
      expect(c.read(beneficiaryIdentityControllerProvider('')).phase, FormPhase.error);
    });
  });

  group('PayoutAccountFormController', () {
    test('validates account number and provider length', () async {
      final repo = FakeBeneficiaryRepository();
      final c = _c(repo);
      _alive(c, payoutAccountFormControllerProvider);
      final ctrl = c.read(payoutAccountFormControllerProvider.notifier);
      ctrl.setProviderName('E');
      ctrl.setAccountNumber('12');
      expect(c.read(payoutAccountFormControllerProvider).canSubmit, isFalse);
      ctrl.setProviderName('EVC Plus');
      ctrl.setAccountNumber('0612345678');
      expect(c.read(payoutAccountFormControllerProvider).canSubmit, isTrue);
    });

    test('submit success returns the account and records the type', () async {
      final repo = FakeBeneficiaryRepository();
      final c = _c(repo);
      _alive(c, payoutAccountFormControllerProvider);
      final ctrl = c.read(payoutAccountFormControllerProvider.notifier);
      ctrl.setType('bank');
      ctrl.setProviderName('Salaam Bank');
      ctrl.setAccountNumber('123456789');
      final a = await ctrl.submit();
      expect(a, isNotNull);
      expect(repo.calls, contains('createPayout:bank:Salaam Bank'));
    });
  });
}
