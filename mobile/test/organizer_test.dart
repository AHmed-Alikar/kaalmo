import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/features/organizer/application/campaign_editor_controller.dart';
import 'package:kaalmo_mobile/features/organizer/application/campaign_editor_state.dart';
import 'package:kaalmo_mobile/features/organizer/application/post_update_controller.dart';
import 'package:kaalmo_mobile/features/organizer/data/models/organizer_stats.dart';
import 'package:kaalmo_mobile/features/organizer/domain/campaign_lifecycle.dart';

import 'support/fakes.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'http://10.0.2.2:5000/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

ProviderContainer _c(FakeOrganizerRepository repo) {
  final c = ProviderContainer(overrides: [
    appConfigProvider.overrideWithValue(_config),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository(startWithSession: fakeUser())),
    organizerRepositoryProvider.overrideWithValue(repo),
  ]);
  addTearDown(c.dispose);
  return c;
}

/// Hold a subscription so an autoDispose provider survives `await` points.
void _alive(ProviderContainer c, ProviderListenable<Object?> p) {
  final sub = c.listen(p, (_, _) {});
  addTearDown(sub.close);
}

void main() {
  group('OrganizerStats.from', () {
    test('tallies statuses and sums raised from the real list', () {
      final stats = OrganizerStats.from([
        fakeCampaign(id: 'a', status: 'draft', raised: 0),
        fakeCampaign(id: 'b', status: 'submitted', raised: 0),
        fakeCampaign(id: 'c', status: 'active', raised: 500),
        fakeCampaign(id: 'd', status: 'goal_reached', raised: 1000),
        fakeCampaign(id: 'e', status: 'completed', raised: 2000),
        fakeCampaign(id: 'f', status: 'rejected', raised: 0),
      ]);
      expect(stats.total, 6);
      expect(stats.drafts, 1);
      expect(stats.inReview, 1);
      expect(stats.live, 2);
      expect(stats.completed, 1);
      expect(stats.rejected, 1);
      expect(stats.totalRaised, 3500);
    });

    test('empty list is all zeros', () {
      final stats = OrganizerStats.from(const []);
      expect(stats.total, 0);
      expect(stats.totalRaised, 0);
    });
  });

  group('CampaignActionSet mirrors the backend lifecycle', () {
    test('draft (owner): edit, submit, cancel, delete, post update', () {
      final a = CampaignActionSet.forCampaign(fakeCampaign(status: 'draft'), isOwner: true);
      expect(a.canEdit, isTrue);
      expect(a.canSubmit, isTrue);
      expect(a.canCancel, isTrue);
      expect(a.canDelete, isTrue);
      expect(a.canPostUpdate, isTrue);
      expect(a.canViewPublic, isFalse);
      expect(a.editReturnsToReview, isFalse);
    });

    test('submitted (owner): cancel yes, submit/delete no', () {
      final a = CampaignActionSet.forCampaign(fakeCampaign(status: 'submitted'), isOwner: true);
      expect(a.canSubmit, isFalse);
      expect(a.canCancel, isTrue);
      expect(a.canDelete, isFalse);
      expect(a.editReturnsToReview, isTrue);
    });

    test('active (owner): edit returns to review, no submit/cancel/delete, view public', () {
      final a = CampaignActionSet.forCampaign(fakeCampaign(status: 'active'), isOwner: true);
      expect(a.canEdit, isTrue);
      expect(a.editReturnsToReview, isTrue);
      expect(a.canSubmit, isFalse);
      expect(a.canCancel, isFalse);
      expect(a.canDelete, isFalse);
      expect(a.canViewPublic, isTrue);
    });

    test('completed / suspended: no edit at all', () {
      expect(CampaignActionSet.forCampaign(fakeCampaign(status: 'completed'), isOwner: true).canEdit, isFalse);
      expect(CampaignActionSet.forCampaign(fakeCampaign(status: 'suspended'), isOwner: true).canEdit, isFalse);
    });

    test('co-organizer never gets owner-only actions', () {
      final a = CampaignActionSet.forCampaign(fakeCampaign(status: 'draft'), isOwner: false);
      expect(a.canEdit, isTrue);
      expect(a.canPostUpdate, isTrue);
      expect(a.canSubmit, isFalse);
      expect(a.canCancel, isFalse);
      expect(a.canDelete, isFalse);
    });
  });

  group('CampaignEditorController', () {
    CampaignEditorController hydrated(ProviderContainer c, {String status = 'draft'}) {
      _alive(c, campaignEditorControllerProvider('c1'));
      final ctrl = c.read(campaignEditorControllerProvider('c1').notifier);
      ctrl.hydrate(fakeCampaign(id: 'c1', status: status, goal: 8000));
      return ctrl;
    }

    test('hydrates the form from the campaign', () {
      final ctrl = hydrated(_c(FakeOrganizerRepository()));
      final s = ctrl.state;
      expect(s.titleSo, 'Caawimaad caafimaad');
      expect(s.goalText, '8000');
      expect(s.category, 'Medical');
      expect(s.isValid, isTrue);
    });

    test('flags a short title, short story and a bad goal', () {
      final c = _c(FakeOrganizerRepository());
      final ctrl = hydrated(c);
      ctrl.setTitleSo('abc');
      ctrl.setStorySo('too short');
      ctrl.setGoal('0');
      final s = c.read(campaignEditorControllerProvider('c1'));
      expect(s.titleSoError, 'min');
      expect(s.storySoError, 'min');
      expect(s.goalError, 'invalid');
      expect(s.isValid, isFalse);
    });

    test('save success returns the updated campaign', () async {
      final repo = FakeOrganizerRepository()..updateResult = fakeCampaign(id: 'c1', status: 'under_review');
      final c = _c(repo);
      final ctrl = hydrated(c);
      final updated = await ctrl.save();
      expect(updated, isNotNull);
      expect(repo.calls, contains('update:c1'));
      expect(c.read(campaignEditorControllerProvider('c1')).phase, EditorPhase.saved);
    });

    test('save failure surfaces the error, no updated campaign', () async {
      final repo = FakeOrganizerRepository()
        ..updateError = const ApiException('bad', statusCode: 400, code: 'VALIDATION_ERROR');
      final c = _c(repo);
      final ctrl = hydrated(c);
      final updated = await ctrl.save();
      expect(updated, isNull);
      expect(c.read(campaignEditorControllerProvider('c1')).phase, EditorPhase.error);
    });
  });

  group('CampaignManageController', () {
    test('submit success records the call', () async {
      final repo = FakeOrganizerRepository();
      final c = _c(repo);
      _alive(c, campaignManageControllerProvider('c1'));
      final ok = await c.read(campaignManageControllerProvider('c1').notifier).submit();
      expect(ok, isTrue);
      expect(repo.calls, contains('submit:c1'));
    });

    test('submit failure surfaces the error and returns false', () async {
      final repo = FakeOrganizerRepository()
        ..submitError = const ApiException('nope', statusCode: 400, code: 'INVALID_TRANSITION');
      final c = _c(repo);
      _alive(c, campaignManageControllerProvider('c1'));
      final ctrl = c.read(campaignManageControllerProvider('c1').notifier);
      final ok = await ctrl.submit();
      expect(ok, isFalse);
      expect(c.read(campaignManageControllerProvider('c1')).error, isA<ApiException>());
    });

    test('cancel and delete route to the right endpoints', () async {
      final repo = FakeOrganizerRepository();
      final c = _c(repo);
      _alive(c, campaignManageControllerProvider('c1'));
      await c.read(campaignManageControllerProvider('c1').notifier).cancel();
      await c.read(campaignManageControllerProvider('c1').notifier).deleteDraft();
      expect(repo.calls, containsAll(['cancel:c1', 'delete:c1']));
    });

    test('a second action while busy is ignored', () async {
      final repo = FakeOrganizerRepository();
      final c = _c(repo);
      _alive(c, campaignManageControllerProvider('c1'));
      final ctrl = c.read(campaignManageControllerProvider('c1').notifier);
      await Future.wait([ctrl.submit(), ctrl.submit()]);
      expect(repo.calls.where((x) => x == 'submit:c1'), hasLength(1));
    });
  });

  group('PostUpdateController', () {
    test('rejects a too-short update without calling the API', () async {
      final repo = FakeOrganizerRepository();
      final c = _c(repo);
      _alive(c, postUpdateControllerProvider('c1'));
      final ctrl = c.read(postUpdateControllerProvider('c1').notifier);
      ctrl.setText('short');
      expect(c.read(postUpdateControllerProvider('c1')).canSubmit, isFalse);
      final created = await ctrl.submit();
      expect(created, isNull);
      expect(repo.calls, isEmpty);
    });

    test('submit success returns the created update', () async {
      final repo = FakeOrganizerRepository();
      final c = _c(repo);
      _alive(c, postUpdateControllerProvider('c1'));
      final ctrl = c.read(postUpdateControllerProvider('c1').notifier);
      ctrl.setText('We finished the school roof this week, thank you all.');
      final created = await ctrl.submit();
      expect(created, isNotNull);
      expect(c.read(postUpdateControllerProvider('c1')).phase, PostUpdatePhase.posted);
      expect(repo.calls.any((x) => x.startsWith('postUpdate:c1')), isTrue);
    });

    test('submit failure surfaces the error', () async {
      final repo = FakeOrganizerRepository()
        ..postUpdateError = const ApiException('forbidden', statusCode: 403, code: 'FORBIDDEN');
      final c = _c(repo);
      _alive(c, postUpdateControllerProvider('c1'));
      final ctrl = c.read(postUpdateControllerProvider('c1').notifier);
      ctrl.setText('A long enough update text for the backend.');
      final created = await ctrl.submit();
      expect(created, isNull);
      expect(c.read(postUpdateControllerProvider('c1')).phase, PostUpdatePhase.error);
    });
  });
}
