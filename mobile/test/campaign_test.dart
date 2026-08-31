import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/network/api_client.dart';
import 'package:kaalmo_mobile/core/utils/media_url.dart';
import 'package:kaalmo_mobile/features/campaigns/data/campaign_api.dart';
import 'package:kaalmo_mobile/features/campaigns/data/campaign_repository.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign.dart';

import 'support/fakes.dart';
import 'support/stub_adapter.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

CampaignRepository _repo(Future<ResponseBody> Function(RequestOptions o) handler) {
  final client = ApiClient.create(config: _config)..raw.httpClientAdapter = StubAdapter(handler);
  return CampaignRepository(CampaignApi(client), _config);
}

void main() {
  group('Campaign.fromJson', () {
    test('parses a full payload', () {
      final c = Campaign.fromJson(campaignJson());
      expect(c.id, 'c1');
      expect(c.titleFor('en'), 'Medical help');
      expect(c.titleFor('so'), 'Caawimaad caafimaad');
      expect(c.category, 'Medical');
      expect(c.goalAmount, 8000);
      expect(c.raisedAmount, 2500);
      expect(c.currency, 'USD');
      expect(c.createdAt, isA<DateTime>());
    });

    test('falls back across languages for a missing localized value', () {
      final c = Campaign.fromJson(campaignJson(titleEn: null));
      expect(c.titleFor('en'), 'Caawimaad caafimaad'); // no en → so
    });

    test('tolerates missing optional fields', () {
      final c = Campaign.fromJson({
        '_id': 'x',
        'title': {'so': 'Hooy'},
        'story': {'so': 's'},
        'category': 'Other',
        'goalAmount': 100,
        'raisedAmount': 0,
        'status': 'published',
      });
      expect(c.coverImageUrl, isNull);
      expect(c.region, isNull);
      expect(c.verificationBadges, isEmpty);
      expect(c.tags, isEmpty);
      expect(c.isVerified, isFalse);
    });

    test('rewrites a localhost cover image to the API host', () {
      final c = Campaign.fromJson(
        campaignJson(coverImageUrl: 'http://localhost:5000/uploads/x.jpg'),
        mediaUrlResolver: (u) => resolveMediaUrl(u, _config.apiBaseUrl),
      );
      expect(c.coverImageUrl, 'http://10.0.2.2:5000/uploads/x.jpg');
    });
  });

  group('Campaign.progress (safe calculation)', () {
    test('normal ratio', () {
      final c = fakeCampaign(goal: 8000, raised: 2500);
      expect(c.progress, closeTo(0.3125, 1e-9));
      expect(c.progressPercent, 31);
    });

    test('zero goal → 0, never NaN/Infinity', () {
      final c = fakeCampaign(goal: 0, raised: 500);
      expect(c.progress, 0);
      expect(c.progressPercent, 0);
    });

    test('over-goal is clamped to 1', () {
      final c = fakeCampaign(goal: 1000, raised: 5000);
      expect(c.progress, 1);
      expect(c.progressPercent, 100);
    });

    test('very large amounts stay bounded', () {
      final c = fakeCampaign(goal: 1000000000, raised: 250000000);
      expect(c.progress, closeTo(0.25, 1e-9));
    });
  });

  group('CampaignRepository', () {
    test('list() maps a page of campaigns', () async {
      final repo = _repo((options) async {
        expect(options.path, '/campaigns');
        expect(options.queryParameters['category'], 'Medical');
        return jsonResponse(200, {
          'items': [campaignJson(id: 'a'), campaignJson(id: 'b')],
          'total': 2,
          'page': 1,
          'limit': 20,
        });
      });

      final page = await repo.list(category: 'Medical');
      expect(page.items.map((c) => c.id), ['a', 'b']);
      expect(page.total, 2);
      expect(page.hasMore, isFalse);
    });

    test('list() surfaces a backend error as ApiException', () async {
      final repo = _repo(
        (options) async => jsonResponse(500, {'error': {'code': 'INTERNAL_ERROR', 'message': 'boom', 'fields': {}}}),
      );
      await expectLater(repo.list(), throwsA(isA<ApiException>()));
    });

    test('stats() maps the platform totals', () async {
      final repo = _repo(
        (options) async => jsonResponse(200, {'totalRaised': 1000, 'campaignCount': 3, 'donorCount': 7}),
      );
      final stats = await repo.stats();
      expect(stats.totalRaised, 1000);
      expect(stats.campaignCount, 3);
      expect(stats.donorCount, 7);
    });
  });

  group('resolveMediaUrl', () {
    test('rewrites loopback hosts', () {
      expect(resolveMediaUrl('http://localhost:5000/uploads/a.jpg', 'https://api.kaalmo.example/api/v1'),
          'https://api.kaalmo.example/uploads/a.jpg');
      expect(resolveMediaUrl('http://127.0.0.1:5000/x', 'http://10.0.2.2:5000/api/v1'),
          'http://10.0.2.2:5000/x');
    });

    test('leaves a real CDN url untouched', () {
      const cdn = 'https://cdn.kaalmo.example/img/a.jpg';
      expect(resolveMediaUrl(cdn, 'https://api.kaalmo.example/api/v1'), cdn);
    });
  });
}
