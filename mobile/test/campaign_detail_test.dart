import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/features/campaigns/application/campaign_comments_controller.dart';
import 'package:kaalmo_mobile/features/campaigns/application/campaign_detail_state.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_comment.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_interactions.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/campaign_update.dart';
import 'package:kaalmo_mobile/features/campaigns/data/models/supporter.dart';
import 'package:kaalmo_mobile/features/campaigns/domain/campaign_status.dart';
import 'package:kaalmo_mobile/features/campaigns/domain/report_reasons.dart';
import 'package:kaalmo_mobile/features/campaigns/domain/verification_badges.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

ProviderContainer _container(FakeCampaignRepository repo, {bool authed = true}) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(
      authed ? FakeAuthRepository(startWithSession: fakeUser()) : FakeAuthRepository(),
    ),
    campaignRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('model parsing', () {
    test('CampaignUpdate tolerates missing image / date', () {
      final u = CampaignUpdate.fromJson({'_id': 'u1', 'text': 'progress'});
      expect(u.id, 'u1');
      expect(u.text, 'progress');
      expect(u.imageUrl, isNull);
      expect(u.createdAt, isNull);
    });

    test('CampaignComment.isMine compares the raw user id', () {
      final c = CampaignComment.fromJson({'_id': 'x', 'userId': 'u9', 'text': 'hi', 'createdAt': '2026-08-01T00:00:00.000Z'});
      expect(c.isMine('u9'), isTrue);
      expect(c.isMine('other'), isFalse);
      expect(c.isMine(null), isFalse);
    });

    test('Supporter handles the anonymous (null donorName) case', () {
      final anon = Supporter.fromJson({'_id': 's1', 'amount': 20, 'currency': 'USD', 'donorName': null});
      final named = Supporter.fromJson({'_id': 's2', 'amount': 20, 'currency': 'USD', 'donorName': 'Amina'});
      expect(anon.isAnonymous, isTrue);
      expect(named.isAnonymous, isFalse);
      expect(named.donorName, 'Amina');
    });

    test('SupporterList reads items + count', () {
      final list = SupporterList.fromJson({
        'items': [
          {'_id': 'a', 'amount': 10, 'currency': 'USD', 'donorName': 'A'},
        ],
        'supporterCount': 12,
      });
      expect(list.items, hasLength(1));
      expect(list.supporterCount, 12);
    });

    test('CampaignInteractions defaults to false', () {
      expect(const CampaignInteractions().following, isFalse);
      expect(CampaignInteractions.fromJson({'following': true, 'saved': false}).following, isTrue);
    });
  });

  group('verification badges', () {
    test('parses only recognised values', () {
      final badges = parseBadges(['identity_verified', 'nonsense', 'payment_verified']);
      expect(badges, [CampaignBadge.identityVerified, CampaignBadge.paymentVerified]);
    });

    test('empty in → empty out', () {
      expect(parseBadges(const []), isEmpty);
    });
  });

  group('campaign status', () {
    test('donatable statuses', () {
      expect(CampaignStatusView.from('active').isOpenForDonations, isTrue);
      expect(CampaignStatusView.from('completed').isOpenForDonations, isFalse);
      expect(CampaignStatusView.from('suspended').isOpenForDonations, isFalse);
    });

    test('banner + negative flags', () {
      expect(CampaignStatusView.from('completed').needsBanner, isTrue);
      expect(CampaignStatusView.from('suspended').isNegative, isTrue);
      expect(CampaignStatusView.from('active').needsBanner, isFalse);
    });

    test('unknown status degrades to "other"', () {
      expect(CampaignStatusView.from('brand_new_state'), CampaignStatusView.other);
    });
  });

  group('report reasons', () {
    test('backend phrase is always >= 5 chars and compose caps at 500', () {
      for (final r in ReportReason.values) {
        expect(r.backendPhrase.length, greaterThanOrEqualTo(5));
      }
      final long = ReportReason.scam.compose('x' * 800);
      expect(long.length, lessThanOrEqualTo(500));
      expect(ReportReason.scam.compose(''), ReportReason.scam.backendPhrase);
      expect(ReportReason.scam.compose('details'), contains('details'));
    });
  });

  group('CampaignDetailController', () {
    test('loads the campaign and interactions on success', () async {
      final repo = FakeCampaignRepository()
        ..campaign = fakeCampaign(id: 'c1')
        ..interactions = const CampaignInteractions(following: true, saved: false);
      final c = _container(repo);
      await c.read(authControllerProvider.notifier).bootstrap();

      final controller = c.read(campaignDetailControllerProvider('c1').notifier);
      await controller.load();

      final state = c.read(campaignDetailControllerProvider('c1'));
      expect(state.status, CampaignDetailStatus.ready);
      expect(state.campaign!.id, 'c1');
      expect(state.interactions.following, isTrue);
    });

    test('a load failure moves to the error state', () async {
      final repo = FakeCampaignRepository()
        ..campaignError = const ApiException('nope', statusCode: 404, code: 'NOT_FOUND');
      final c = _container(repo);
      final controller = c.read(campaignDetailControllerProvider('missing').notifier);
      await controller.load();
      expect(c.read(campaignDetailControllerProvider('missing')).status, CampaignDetailStatus.error);
    });

    test('toggleFollow / toggleSave update interactions on success', () async {
      final repo = FakeCampaignRepository()..campaign = fakeCampaign(id: 'c1');
      final c = _container(repo);
      await c.read(authControllerProvider.notifier).bootstrap();
      final controller = c.read(campaignDetailControllerProvider('c1').notifier);
      await controller.load();

      await controller.toggleFollow();
      expect(c.read(campaignDetailControllerProvider('c1')).interactions.following, isTrue);
      await controller.toggleFollow();
      expect(c.read(campaignDetailControllerProvider('c1')).interactions.following, isFalse);

      await controller.toggleSave();
      expect(c.read(campaignDetailControllerProvider('c1')).interactions.saved, isTrue);
      expect(repo.mutations, containsAll(['follow:true', 'follow:false', 'save:true']));
    });

    test('a follow failure keeps the previous state and reports the error', () async {
      final repo = FakeCampaignRepository()
        ..campaign = fakeCampaign(id: 'c1')
        ..followError = const NetworkException('offline');
      final c = _container(repo);
      await c.read(authControllerProvider.notifier).bootstrap();
      final controller = c.read(campaignDetailControllerProvider('c1').notifier);
      await controller.load();

      await controller.toggleFollow();
      final state = c.read(campaignDetailControllerProvider('c1'));
      expect(state.interactions.following, isFalse); // unchanged
      expect(state.mutationError, isNotNull);
      expect(state.followBusy, isFalse);
    });

    test('unauthenticated user cannot toggle follow', () async {
      final repo = FakeCampaignRepository()..campaign = fakeCampaign(id: 'c1');
      final c = _container(repo, authed: false);
      final controller = c.read(campaignDetailControllerProvider('c1').notifier);
      await controller.load();
      await controller.toggleFollow();
      expect(repo.mutations, isEmpty);
    });
  });

  group('CampaignCommentsController', () {
    FakeCampaignRepository repo() => FakeCampaignRepository()..comments = [fakeComment(id: 'a'), fakeComment(id: 'b')];

    test('loads comments', () async {
      final r = repo();
      final c = _container(r);
      final controller = c.read(campaignCommentsControllerProvider('c1').notifier);
      await controller.load();
      expect(c.read(campaignCommentsControllerProvider('c1')).comments, hasLength(2));
    });

    test('empty / error surface as states', () async {
      final r = FakeCampaignRepository()..commentsError = const NetworkException('x');
      final c = _container(r);
      final controller = c.read(campaignCommentsControllerProvider('c1').notifier);
      await controller.load();
      expect(c.read(campaignCommentsControllerProvider('c1')).status, CommentsStatus.error);
    });

    test('submit rejects empty and over-long comments without calling the API', () async {
      final r = repo();
      final c = _container(r);
      final controller = c.read(campaignCommentsControllerProvider('c1').notifier);
      await controller.load();

      await controller.submit('   ');
      await controller.submit('x' * (kCommentMaxLength + 1));
      expect(r.mutations.where((m) => m.startsWith('postComment')), isEmpty);
    });

    test('submit prepends the new comment on success', () async {
      final r = repo();
      final c = _container(r);
      final controller = c.read(campaignCommentsControllerProvider('c1').notifier);
      await controller.load();

      final err = await controller.submit('Great cause');
      expect(err, isNull);
      final state = c.read(campaignCommentsControllerProvider('c1'));
      expect(state.comments.first.text, 'Great cause');
      expect(state.comments, hasLength(3));
      expect(r.mutations, contains('postComment:Great cause'));
    });

    test('submit returns the error on failure and does not add the comment', () async {
      final r = repo()..postCommentError = const ApiException('bad', statusCode: 400, code: 'VALIDATION_ERROR');
      final c = _container(r);
      final controller = c.read(campaignCommentsControllerProvider('c1').notifier);
      await controller.load();

      final err = await controller.submit('hi');
      expect(err, isA<ApiException>());
      expect(c.read(campaignCommentsControllerProvider('c1')).comments, hasLength(2));
    });
  });
}
