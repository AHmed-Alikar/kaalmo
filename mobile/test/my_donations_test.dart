import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/network/api_client.dart';
import 'package:kaalmo_mobile/features/donations/data/donation_api.dart';
import 'package:kaalmo_mobile/features/donations/data/donation_repository.dart';
import 'package:kaalmo_mobile/features/donations/data/models/my_donation.dart';
import 'package:kaalmo_mobile/features/donations/domain/donation_status.dart';

import 'support/stub_adapter.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

DonationRepository _repo(Future<ResponseBody> Function(RequestOptions o) handler) {
  final client = ApiClient.create(config: _config)..raw.httpClientAdapter = StubAdapter(handler);
  return DonationRepository(DonationApi(client), _config);
}

Map<String, dynamic> _donationJson({
  String id = 'd1',
  num amount = 25,
  String status = 'confirmed',
  bool anonymous = false,
  String? message,
  Object? campaign = _keep,
}) =>
    {
      '_id': id,
      'amount': amount,
      'currency': 'USD',
      'status': status,
      'isAnonymous': anonymous,
      'message': ?message,
      'paymentId': 'p_$id',
      'createdAt': '2026-08-28T09:15:00.000Z',
      'campaignId': identical(campaign, _keep)
          ? {
              '_id': 'c1',
              'title': {'en': 'Medical help', 'so': 'Caawimaad'},
              'coverImageUrl': 'http://localhost:5000/uploads/c.jpg',
              'category': 'Medical',
            }
          : campaign,
    };

const _keep = Object();

void main() {
  group('MyDonation.fromJson', () {
    test('parses a full row', () {
      final d = MyDonation.fromJson(_donationJson(message: 'Get well'));
      expect(d.id, 'd1');
      expect(d.amount, 25);
      expect(d.currency, 'USD');
      expect(d.status, 'confirmed');
      expect(d.statusView, DonationStatusView.confirmed);
      expect(d.isAnonymous, isFalse);
      expect(d.message, 'Get well');
      expect(d.createdAt, isA<DateTime>());
      expect(d.reference, 'd1');
      expect(d.campaign, isNotNull);
      expect(d.campaign!.titleFor('en'), 'Medical help');
      expect(d.campaign!.category, 'Medical');
    });

    test('anonymous donation', () {
      final d = MyDonation.fromJson(_donationJson(anonymous: true));
      expect(d.isAnonymous, isTrue);
    });

    test('a deleted campaign parses as a null campaign, not a crash', () {
      final d = MyDonation.fromJson(_donationJson(campaign: null));
      expect(d.campaign, isNull);
    });

    test('tolerates missing optional fields', () {
      final d = MyDonation.fromJson({'_id': 'x', 'amount': 10, 'status': 'pending'});
      expect(d.currency, 'USD');
      expect(d.message, isNull);
      expect(d.createdAt, isNull);
      expect(d.paymentId, isNull);
      expect(d.campaign, isNull);
      expect(d.statusView, DonationStatusView.pending);
    });

    test('resolves a localhost cover image to the API host', () {
      final d = MyDonation.fromJson(
        _donationJson(),
        mediaUrlResolver: (u) => u.replaceFirst('localhost:5000', '10.0.2.2:5000'),
      );
      expect(d.campaign!.coverImageUrl, 'http://10.0.2.2:5000/uploads/c.jpg');
    });
  });

  group('DonationStatusView', () {
    test('maps the backend enum and falls back for anything else', () {
      expect(DonationStatusView.from('pending'), DonationStatusView.pending);
      expect(DonationStatusView.from('confirmed'), DonationStatusView.confirmed);
      expect(DonationStatusView.from('failed'), DonationStatusView.failed);
      expect(DonationStatusView.from('refunded'), DonationStatusView.refunded);
      expect(DonationStatusView.from('weird'), DonationStatusView.unknown);
      expect(DonationStatusView.from(null), DonationStatusView.unknown);
    });
  });

  group('DonationRepository.getMyDonations', () {
    test('parses the array newest-first as the backend returns it', () async {
      final repo = _repo((o) async {
        expect(o.path, contains('/donations/mine'));
        return jsonResponse(200, [
          _donationJson(id: 'a', amount: 50),
          _donationJson(id: 'b', amount: 10, status: 'pending', campaign: null),
        ]);
      });
      final list = await repo.getMyDonations();
      expect(list, hasLength(2));
      expect(list.first.id, 'a');
      expect(list.first.campaign, isNotNull);
      expect(list[1].campaign, isNull);
      expect(list.first.campaign!.coverImageUrl, contains('10.0.2.2:5000'));
    });

    test('skips a malformed entry rather than throwing', () async {
      final repo = _repo((o) async => jsonResponse(200, [
            _donationJson(id: 'a'),
            'not-an-object',
            42,
          ]));
      final list = await repo.getMyDonations();
      expect(list, hasLength(1));
    });

    test('a server error surfaces as ApiException', () async {
      final repo = _repo((o) async => jsonResponse(500, {
            'error': {'code': 'SERVER_ERROR', 'message': 'boom', 'fields': {}}
          }));
      expect(repo.getMyDonations, throwsA(isA<ApiException>()));
    });

    test('a connectivity failure surfaces as NetworkException', () async {
      final repo = _repo((o) async => throw DioException.connectionError(
            requestOptions: o,
            reason: 'offline',
          ));
      expect(repo.getMyDonations, throwsA(isA<NetworkException>()));
    });
  });
}
