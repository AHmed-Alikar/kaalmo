import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/utils/idempotency.dart';
import 'package:kaalmo_mobile/core/utils/money_input.dart';
import 'package:kaalmo_mobile/features/donations/application/donate_controller.dart';
import 'package:kaalmo_mobile/features/donations/application/donate_state.dart';
import 'package:kaalmo_mobile/features/donations/data/models/donation_result.dart';
import 'package:kaalmo_mobile/features/donations/data/models/payment_config.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

ProviderContainer _container(FakeDonationRepository repo, {bool authed = true}) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(
      authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
    ),
    donationRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

Future<DonateController> _controller(
  ProviderContainer c, {
  String id = 'c1',
}) async {
  await c.read(authControllerProvider.notifier).bootstrap();
  // Hold a subscription so the autoDispose provider survives `pumpEventQueue`.
  final sub = c.listen(donateControllerProvider(id), (_, _) {});
  addTearDown(sub.close);
  await pumpEventQueue();
  return c.read(donateControllerProvider(id).notifier);
}

void main() {
  group('money input helpers', () {
    test('parseAmount accepts positive numbers only', () {
      expect(parseAmount('25'), 25);
      expect(parseAmount('12.50'), 12.5);
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
      expect(parseAmount('0'), isNull);
      expect(parseAmount('-5'), isNull);
    });

    test('formatAmount groups thousands and trims .00', () {
      expect(formatAmount(25, 'USD'), 'USD 25');
      expect(formatAmount(2500, 'USD'), 'USD 2,500');
      expect(formatAmount(12.5, 'USD'), 'USD 12.50');
    });

    test('DecimalAmountFormatter blocks letters and extra dots', () {
      const f = DecimalAmountFormatter();
      TextEditingValue apply(String oldT, String newT) => f.formatEditUpdate(
            TextEditingValue(text: oldT),
            TextEditingValue(text: newT),
          );
      expect(apply('12', '12a').text, '12');
      expect(apply('12.5', '12.5.').text, '12.5');
      expect(apply('12.5', '12.55').text, '12.55');
      expect(apply('12.55', '12.555').text, '12.55');
      expect(apply('', '5').text, '5');
    });

    test('newIdempotencyKey is unique per call', () {
      final keys = List.generate(50, (_) => newIdempotencyKey());
      expect(keys.toSet(), hasLength(50));
    });
  });

  group('model parsing', () {
    test('PaymentConfig.fromJson', () {
      final c = PaymentConfig.fromJson({
        'providers': ['manual', 'evc_plus'],
        'currency': 'USD',
        'minAmount': 1,
      });
      expect(c.providers, ['manual', 'evc_plus']);
      expect(c.currency, 'USD');
      expect(c.minAmount, 1);
      expect(c.hasAnyProvider, isTrue);
    });

    test('PaymentConfig tolerates a missing providers list', () {
      final c = PaymentConfig.fromJson({'currency': 'USD'});
      expect(c.providers, isEmpty);
      expect(c.hasAnyProvider, isFalse);
    });

    test('PaymentConfig.donorProviders excludes the offline "manual" method', () {
      final both = PaymentConfig.fromJson({'providers': ['manual', 'evc_plus'], 'currency': 'USD', 'minAmount': 1});
      expect(both.donorProviders, ['evc_plus']);
      expect(both.hasDonorProvider, isTrue);

      final manualOnly = PaymentConfig.fromJson({'providers': ['manual'], 'currency': 'USD', 'minAmount': 1});
      expect(manualOnly.donorProviders, isEmpty);
      expect(manualOnly.hasDonorProvider, isFalse);
    });

    test('DonationResult.fromJson — confirmed', () {
      final r = DonationResult.fromJson({
        'donation': {
          '_id': 'd1',
          'amount': 25,
          'currency': 'USD',
          'isAnonymous': false,
          'status': 'confirmed',
          'message': 'Good luck',
          'createdAt': '2026-08-30T10:30:00.000Z',
        },
        'payment': {'paymentId': 'p1', 'status': 'confirmed'},
        'raisedAmount': 2525,
        'note': 'Donation confirmed.',
      });
      expect(r.donationId, 'd1');
      expect(r.amount, 25);
      expect(r.isConfirmed, isTrue);
      expect(r.isPending, isFalse);
      expect(r.raisedAmount, 2525);
      expect(r.message, 'Good luck');
    });

    test('DonationResult treats a pending payment as not-confirmed', () {
      final r = DonationResult.fromJson({
        'donation': {'_id': 'd1', 'amount': 10, 'status': 'pending'},
        'payment': {'status': 'pending'},
        'raisedAmount': 10,
      });
      expect(r.isConfirmed, isFalse);
      expect(r.isPending, isTrue);
    });
  });

  group('DonateController — amount + message validation', () {
    test('flags empty / non-numeric / below-min / above-max amounts', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);

      ctrl.setAmount('');
      expect(c.read(donateControllerProvider('c1')).amountIssue, AmountIssue.empty);

      ctrl.setAmount('abc');
      expect(c.read(donateControllerProvider('c1')).amountIssue, AmountIssue.notANumber);

      ctrl.setAmount('0.005'); // min is 0.01
      expect(c.read(donateControllerProvider('c1')).amountIssue, AmountIssue.belowMinimum);

      ctrl.setAmount('0.01'); // exactly the minimum is allowed
      expect(c.read(donateControllerProvider('c1')).amountIssue, AmountIssue.none);

      ctrl.setAmount('2000000');
      expect(c.read(donateControllerProvider('c1')).amountIssue, AmountIssue.aboveMaximum);

      ctrl.setAmount('25');
      final s = c.read(donateControllerProvider('c1'));
      expect(s.amountIssue, AmountIssue.none);
      expect(s.amountValid, isTrue);
      expect(s.canContinue, isTrue);
    });

    test('preset selection sets the amount', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);
      ctrl.selectPreset(50);
      final s = c.read(donateControllerProvider('c1'));
      expect(s.amountText, '50');
      expect(s.amountValue, 50);
    });

    test('custom decimal amount parses', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);
      ctrl.setAmount('12.50');
      expect(c.read(donateControllerProvider('c1')).amountValue, 12.5);
    });

    test('anonymous toggle', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);
      ctrl.setAnonymous(true);
      expect(c.read(donateControllerProvider('c1')).isAnonymous, isTrue);
    });

    test('an over-long message blocks continuing', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);
      ctrl.setAmount('25');
      ctrl.setMessage('x' * (kDonationMessageMax + 1));
      final s = c.read(donateControllerProvider('c1'));
      expect(s.messageTooLong, isTrue);
      expect(s.canContinue, isFalse);
    });
  });

  group('DonateController — payment config', () {
    test('defaults to the first real payment method, never manual', () async {
      final c = _container(FakeDonationRepository(config: fakePaymentConfig(providers: ['manual', 'evc_plus'])));
      await _controller(c);
      final s = c.read(donateControllerProvider('c1'));
      expect(s.configLoading, isFalse);
      // The raw config still carries everything the backend sent…
      expect(s.config?.providers, ['manual', 'evc_plus']);
      // …but the donor flow only offers / selects real payment methods.
      expect(s.donorProviders, ['evc_plus']);
      expect(s.providerId, 'evc_plus');
      expect(s.paymentUnavailable, isFalse);
    });

    test('when the backend offers only manual, payment is unavailable (no silent fallback)', () async {
      final c = _container(FakeDonationRepository(config: fakePaymentConfig(providers: ['manual'])));
      await _controller(c);
      final s = c.read(donateControllerProvider('c1'));
      expect(s.donorProviders, isEmpty);
      expect(s.providerId, isNull);
      expect(s.paymentUnavailable, isTrue);
      expect(s.canSubmit, isFalse);
    });

    test('a config failure is surfaced, not fatal', () async {
      final repo = FakeDonationRepository()..configError = const NetworkException('offline');
      final c = _container(repo);
      await _controller(c);
      final s = c.read(donateControllerProvider('c1'));
      expect(s.configError, isA<NetworkException>());
      expect(s.configLoading, isFalse);
    });
  });

  group('DonateController — review + submit', () {
    // The donor flow defaults to evc_plus, which requires a phone number.
    Future<DonateController> ready(ProviderContainer c, {String amount = '25'}) async {
      final ctrl = await _controller(c);
      ctrl.setAmount(amount);
      ctrl.setPhone('0615123456');
      ctrl.goToReview();
      return ctrl;
    }

    test('goToReview only advances with a valid amount', () async {
      final c = _container(FakeDonationRepository());
      final ctrl = await _controller(c);
      ctrl.goToReview();
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.editing);
      ctrl.setAmount('25');
      ctrl.goToReview();
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.review);
    });

    test('submit drives the EVC Plus payment: provider evc_plus + phone are sent', () async {
      final repo = FakeDonationRepository();
      final c = _container(repo);
      final ctrl = await ready(c);
      await ctrl.submit();
      await pumpEventQueue();

      final s = c.read(donateControllerProvider('c1'));
      expect(s.phase, DonatePhase.success);
      expect(s.result?.isConfirmed, isTrue);
      expect(repo.donateCalls, hasLength(1));
      final call = repo.donateCalls.first;
      expect(call['amount'], 25);
      // The bug was that mobile sent 'manual' (offline) and no payment prompt
      // ever fired. It must send the real provider + the phone to charge.
      expect(call['provider'], 'evc_plus');
      expect(call['phone'], '0615123456');
    });

    test('a single Donate action creates exactly one donation (no duplicate)', () async {
      final repo = FakeDonationRepository();
      final c = _container(repo);
      final ctrl = await ready(c);
      await ctrl.submit();
      await pumpEventQueue();
      // Tapping "Back to campaign" etc. must not re-submit.
      expect(repo.donateCalls, hasLength(1));
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.success);
    });

    test('cancelling on review (editDonation) charges nothing', () async {
      final repo = FakeDonationRepository();
      final c = _container(repo);
      final ctrl = await ready(c);
      ctrl.editDonation();
      await pumpEventQueue();
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.editing);
      expect(repo.donateCalls, isEmpty);
    });

    test('a backend-pending payment → pending phase, never shown as success', () async {
      final repo = FakeDonationRepository()
        ..result = fakeDonationResult(
          donationStatus: 'pending',
          paymentStatus: DonationPaymentStatus.pending,
        );
      final c = _container(repo);
      final ctrl = await ready(c);
      await ctrl.submit();
      await pumpEventQueue();
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.pending);
    });

    test('a declined payment → failed phase with the error', () async {
      final repo = FakeDonationRepository()
        ..donateError = const ApiException('Insufficient balance', statusCode: 402, code: 'PAYMENT_DECLINED');
      final c = _container(repo);
      final ctrl = await ready(c);
      await ctrl.submit();
      await pumpEventQueue();
      final s = c.read(donateControllerProvider('c1'));
      expect(s.phase, DonatePhase.failed);
      expect(s.submitError, isA<ApiException>());
    });

    test('a network failure → failed phase', () async {
      final repo = FakeDonationRepository()..donateError = const NetworkException('offline');
      final c = _container(repo);
      final ctrl = await ready(c);
      await ctrl.submit();
      await pumpEventQueue();
      expect(c.read(donateControllerProvider('c1')).phase, DonatePhase.failed);
    });

    test('a second submit while processing is ignored (no double charge)', () async {
      final repo = FakeDonationRepository();
      final c = _container(repo);
      final ctrl = await ready(c);
      // Fire twice without awaiting the first.
      final f1 = ctrl.submit();
      final f2 = ctrl.submit();
      await Future.wait([f1, f2]);
      await pumpEventQueue();
      expect(repo.donateCalls, hasLength(1));
    });

    test('retry re-uses the same idempotency key; editing generates a new one', () async {
      final repo = FakeDonationRepository()..donateError = const NetworkException('offline');
      final c = _container(repo);
      final ctrl = await ready(c);

      await ctrl.submit();
      await pumpEventQueue();
      final firstKey = repo.donateCalls.first['idempotencyKey'];
      expect(firstKey, isA<String>());
      expect((firstKey as String).isNotEmpty, isTrue);

      // Retry the same attempt.
      ctrl.retry();
      await ctrl.submit();
      await pumpEventQueue();
      expect(repo.donateCalls[1]['idempotencyKey'], firstKey);

      // Edit → a fresh attempt → new key.
      repo.donateError = null;
      ctrl.editDonation();
      ctrl.setAmount('30');
      ctrl.goToReview();
      await ctrl.submit();
      await pumpEventQueue();
      expect(repo.donateCalls[2]['idempotencyKey'], isNot(firstKey));
    });

    test('an unauthenticated user cannot submit a donation', () async {
      final repo = FakeDonationRepository();
      final c = _container(repo, authed: false);
      final ctrl = await _controller(c);
      ctrl.setAmount('25');
      ctrl.goToReview();
      await ctrl.submit();
      await pumpEventQueue();
      expect(repo.donateCalls, isEmpty);
    });
  });
}
