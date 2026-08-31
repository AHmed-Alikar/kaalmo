import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/network/api_client.dart';
import 'package:kaalmo_mobile/features/support/application/support_controllers.dart';
import 'package:kaalmo_mobile/features/support/data/models/support_ticket.dart';
import 'package:kaalmo_mobile/features/support/data/support_api.dart';
import 'package:kaalmo_mobile/features/support/data/support_repository.dart';

import 'support/fakes.dart';
import 'support/stub_adapter.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

SupportRepository _repo(Future<ResponseBody> Function(RequestOptions o) handler) {
  final client = ApiClient.create(config: _config)..raw.httpClientAdapter = StubAdapter(handler);
  return SupportRepository(SupportApi(client));
}

ProviderContainer _c(FakeSupportRepository repo) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(startWithSession: fakeUser())),
    supportRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

void _alive(ProviderContainer c, ProviderListenable<Object?> p) {
  final sub = c.listen(p, (_, _) {});
  addTearDown(sub.close);
}

void main() {
  group('SupportTicket model', () {
    test('fromJson parses the thread and status', () {
      final t = SupportTicket.fromJson({
        '_id': 't1',
        'subject': 'Payment issue',
        'message': 'It failed.',
        'status': 'in_progress',
        'replies': [
          {'authorRole': 'user', 'message': 'Any update?', 'createdAt': '2026-08-27T00:00:00.000Z'},
          {'authorRole': 'admin', 'message': 'Looking into it.', 'createdAt': '2026-08-28T00:00:00.000Z'},
        ],
        'createdAt': '2026-08-26T00:00:00.000Z',
        'updatedAt': '2026-08-28T00:00:00.000Z',
      });
      expect(t.subject, 'Payment issue');
      expect(t.statusView, TicketStatusView.inProgress);
      expect(t.replies, hasLength(2));
      expect(t.replies.first.isMine, isTrue);
      expect(t.replies[1].isMine, isFalse);
    });

    test('status view: unknown falls back, isActive is open/in_progress', () {
      expect(TicketStatusView.from('weird'), TicketStatusView.unknown);
      expect(TicketStatusView.from('open').isActive, isTrue);
      expect(TicketStatusView.from('in_progress').isActive, isTrue);
      expect(TicketStatusView.from('resolved').isActive, isFalse);
      expect(TicketStatusView.from('closed').isActive, isFalse);
    });
  });

  group('SupportRepository', () {
    test('myTickets parses the array, skipping bad rows', () async {
      final repo = _repo((o) async {
        expect(o.path, contains('/support-tickets/mine'));
        return jsonResponse(200, [
          {'_id': 'a', 'subject': 'S', 'message': 'M', 'status': 'open', 'replies': []},
          'bad',
        ]);
      });
      final list = await repo.myTickets();
      expect(list, hasLength(1));
    });

    test('createTicket posts subject + message', () async {
      final repo = _repo((o) async {
        expect(o.method, 'POST');
        expect(o.path, endsWith('/support-tickets'));
        final body = o.data as Map;
        expect(body['subject'], 'Hi');
        expect(body['message'], 'Hello there');
        return jsonResponse(201, {'_id': 't9', 'subject': 'Hi', 'message': 'Hello there', 'status': 'open', 'replies': []});
      });
      final t = await repo.createTicket(subject: 'Hi', message: 'Hello there');
      expect(t.id, 't9');
    });

    test('a 401 surfaces as ApiException', () async {
      final repo = _repo((o) async => jsonResponse(401, {
            'error': {'code': 'UNAUTHORIZED', 'message': 'no', 'fields': {}}
          }));
      expect(repo.myTickets, throwsA(isA<ApiException>()));
    });
  });

  group('NewTicketController', () {
    test('validation gates submission', () async {
      final repo = FakeSupportRepository();
      final c = _c(repo);
      _alive(c, newTicketControllerProvider);
      final ctrl = c.read(newTicketControllerProvider.notifier);
      ctrl.setSubject('ab'); // too short
      ctrl.setMessage('hey'); // too short
      expect(c.read(newTicketControllerProvider).canSubmit, isFalse);
      expect(await ctrl.submit(), isNull);
      expect(repo.calls, isEmpty);

      ctrl.setSubject('Payment problem');
      ctrl.setMessage('My donation failed and I need help.');
      expect(c.read(newTicketControllerProvider).canSubmit, isTrue);
    });

    test('submit success returns the created ticket', () async {
      final repo = FakeSupportRepository();
      final c = _c(repo);
      _alive(c, newTicketControllerProvider);
      final ctrl = c.read(newTicketControllerProvider.notifier);
      ctrl.setSubject('Payment problem');
      ctrl.setMessage('My donation failed and I need help.');
      final t = await ctrl.submit();
      expect(t, isNotNull);
      expect(c.read(newTicketControllerProvider).phase, SubmitPhase.done);
      expect(repo.calls.any((x) => x.startsWith('create:')), isTrue);
    });

    test('submit failure surfaces the error', () async {
      final repo = FakeSupportRepository()
        ..createError = const ApiException('bad', statusCode: 400, code: 'VALIDATION_ERROR');
      final c = _c(repo);
      _alive(c, newTicketControllerProvider);
      final ctrl = c.read(newTicketControllerProvider.notifier);
      ctrl.setSubject('Payment problem');
      ctrl.setMessage('My donation failed and I need help.');
      expect(await ctrl.submit(), isNull);
      expect(c.read(newTicketControllerProvider).phase, SubmitPhase.error);
    });
  });

  group('TicketReplyController', () {
    test('rejects an empty reply; sends a valid one', () async {
      final repo = FakeSupportRepository();
      final c = _c(repo);
      _alive(c, ticketReplyControllerProvider('t1'));
      final ctrl = c.read(ticketReplyControllerProvider('t1').notifier);
      expect(c.read(ticketReplyControllerProvider('t1')).canSubmit, isFalse);
      ctrl.setText('Thanks for the update.');
      final updated = await ctrl.submit();
      expect(updated, isNotNull);
      expect(repo.calls, contains('reply:t1:Thanks for the update.'));
    });
  });
}
