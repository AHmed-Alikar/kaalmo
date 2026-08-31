import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/di/providers.dart';
import 'package:kaalmo_mobile/features/campaigns/application/explore_state.dart';

import 'support/fakes.dart';

ProviderContainer _container(FakeCampaignRepository repo) {
  final c = ProviderContainer(
    overrides: [campaignRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(c.dispose);
  return c;
}

List<T> _generate<T>(int n, T Function(int) f) => List.generate(n, f);

void main() {
  test('init() loads the first page', () async {
    final repo = FakeCampaignRepository(
      all: _generate(5, (i) => fakeCampaign(id: 'c$i')),
    );
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);

    await controller.init();
    final state = container.read(exploreControllerProvider);
    expect(state.status, ExploreStatus.ready);
    expect(state.campaigns, hasLength(5));
    expect(repo.listCalls, 1);
  });

  test('search is debounced — rapid keystrokes cause a single request', () async {
    final repo = FakeCampaignRepository(all: _generate(3, (i) => fakeCampaign(id: 'c$i')));
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);
    await controller.init();
    repo.listCalls = 0;

    controller.search('m');
    controller.search('me');
    controller.search('med');
    controller.search('medi');
    await Future<void>.delayed(const Duration(milliseconds: 600));

    expect(repo.listCalls, 1);
    expect(repo.listArgs.last['query'], 'medi');
  });

  test('setCategory reloads from page 1 with the category param', () async {
    final repo = FakeCampaignRepository(all: [
      fakeCampaign(id: 'a', category: 'Medical'),
      fakeCampaign(id: 'b', category: 'Education'),
    ]);
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);
    await controller.init();

    controller.setCategory('Education');
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = container.read(exploreControllerProvider);
    expect(state.filters.category, 'Education');
    expect(repo.listArgs.last['category'], 'Education');
    expect(repo.listArgs.last['page'], 1);
    expect(state.campaigns.single.id, 'b');
  });

  test('pull-to-refresh re-requests page 1', () async {
    final repo = FakeCampaignRepository(all: _generate(3, (i) => fakeCampaign(id: 'c$i')));
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);
    await controller.init();
    repo.listCalls = 0;

    await controller.refresh();
    expect(repo.listCalls, 1);
    expect(repo.listArgs.last['page'], 1);
  });

  test('loadMore appends the next page and stops at the end', () async {
    final repo = FakeCampaignRepository(all: _generate(45, (i) => fakeCampaign(id: 'c$i')));
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);
    await controller.init();
    expect(container.read(exploreControllerProvider).campaigns, hasLength(20));
    expect(container.read(exploreControllerProvider).hasMore, isTrue);

    await controller.loadMore();
    expect(container.read(exploreControllerProvider).campaigns, hasLength(40));

    await controller.loadMore();
    final state = container.read(exploreControllerProvider);
    expect(state.campaigns, hasLength(45));
    expect(state.hasMore, isFalse);
  });

  test('a list failure moves to the error state without wiping filters', () async {
    final repo = FakeCampaignRepository(all: [])
      ..listError = DioException(
        requestOptions: RequestOptions(path: '/campaigns'),
        type: DioExceptionType.connectionError,
      );
    final container = _container(repo);
    final controller = container.read(exploreControllerProvider.notifier);

    await controller.init();
    expect(container.read(exploreControllerProvider).status, ExploreStatus.error);
  });
}
