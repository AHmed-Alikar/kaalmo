import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/config/app_config.dart';
import 'package:kaalmo_mobile/core/config/app_environment.dart';
import 'package:kaalmo_mobile/core/network/api_client.dart';
import 'package:kaalmo_mobile/core/network/auth_interceptor.dart';
import 'package:kaalmo_mobile/core/network/token_refresher.dart';
import 'package:kaalmo_mobile/core/storage/secure_token_store.dart';

import 'support/stub_adapter.dart';

const _config = AppConfig(
  environment: AppEnvironment.development,
  apiBaseUrl: 'https://api.test/api/v1',
  webBaseUrl: 'https://kaalmo.test',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 5),
);

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({
        'kaalmo.access_token': 'access-old',
        'kaalmo.refresh_token': 'refresh-0',
      }));

  group('AuthInterceptor', () {
    test('on 401: refreshes once, retries the original request, returns 200', () async {
      final store = SecureTokenStore();
      var refreshCalls = 0;
      var protectedHits = 0;

      final client = ApiClient.create(
        config: _config,
        buildAuthInterceptor: (self) => AuthInterceptor(
          store,
          () async {
            refreshCalls++;
            await store.writeTokens(accessToken: 'access-new', refreshToken: 'refresh-1');
            return true;
          },
          () => fail('session should not expire on a successful refresh'),
          self,
        ),
      );

      client.raw.httpClientAdapter = StubAdapter((options) async {
        if (options.path == '/me') {
          protectedHits++;
          final auth = options.headers['Authorization'];
          if (auth == 'Bearer access-old') return jsonResponse(401, {'error': {'code': 'UNAUTHORIZED', 'message': 'expired', 'fields': {}}});
          return jsonResponse(200, {'id': 'u1', 'auth': auth});
        }
        return jsonResponse(404, {'error': {'code': 'NOT_FOUND', 'message': 'x', 'fields': {}}});
      });

      final result = await client.get<Map<String, dynamic>>('/me');

      expect(refreshCalls, 1);
      expect(protectedHits, 2); // original + one retry
      expect(result['auth'], 'Bearer access-new');
    });

    test('retries only once — a second 401 propagates, no loop', () async {
      final store = SecureTokenStore();
      var refreshCalls = 0;
      var hits = 0;

      final client = ApiClient.create(
        config: _config,
        buildAuthInterceptor: (self) => AuthInterceptor(
          store,
          () async {
            refreshCalls++;
            await store.writeTokens(accessToken: 'access-new', refreshToken: 'r1');
            return true;
          },
          () {},
          self,
        ),
      );

      client.raw.httpClientAdapter = StubAdapter((options) async {
        hits++;
        return jsonResponse(401, {'error': {'code': 'UNAUTHORIZED', 'message': 'nope', 'fields': {}}});
      });

      await expectLater(client.get<dynamic>('/me'), throwsA(isA<Object>()));
      expect(refreshCalls, 1);
      expect(hits, 2); // original + single retry, then it gives up
    });

    test('when refresh fails: fires onSessionExpired and surfaces the error', () async {
      final store = SecureTokenStore();
      var sessionExpired = false;

      final client = ApiClient.create(
        config: _config,
        buildAuthInterceptor: (self) => AuthInterceptor(
          store,
          () async => false, // refresh fails
          () => sessionExpired = true,
          self,
        ),
      );

      client.raw.httpClientAdapter = StubAdapter(
        (options) async => jsonResponse(401, {'error': {'code': 'UNAUTHORIZED', 'message': 'gone', 'fields': {}}}),
      );

      await expectLater(client.get<dynamic>('/me'), throwsA(isA<Object>()));
      expect(sessionExpired, isTrue);
    });
  });

  group('TokenRefresher', () {
    test('single-flights concurrent refreshes into one /auth/refresh call', () async {
      final store = SecureTokenStore();
      var endpointHits = 0;

      final stubbedDio = Dio(BaseOptions(baseUrl: _config.apiBaseUrl))
        ..httpClientAdapter = StubAdapter((options) async {
          endpointHits++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return jsonResponse(200, {'accessToken': 'a1', 'refreshToken': 'r1'});
        });

      final refresher = TokenRefresher(store, _config, httpClient: stubbedDio);

      final results = await Future.wait([refresher.refresh(), refresher.refresh(), refresher.refresh()]);

      expect(results, everyElement(isTrue));
      expect(endpointHits, 1);
      expect(await store.readAccessToken(), 'a1');
    });

    test('returns false (no throw) when there is no stored refresh token', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final refresher = TokenRefresher(SecureTokenStore(), _config);
      expect(await refresher.refresh(), isFalse);
    });

    test('returns false when the refresh endpoint rejects the token', () async {
      final store = SecureTokenStore();
      final stubbedDio = Dio(BaseOptions(baseUrl: _config.apiBaseUrl))
        ..httpClientAdapter = StubAdapter(
          (options) async => jsonResponse(401, {'error': {'code': 'INVALID_TOKEN', 'message': 'x', 'fields': {}}}),
        );
      final refresher = TokenRefresher(store, _config, httpClient: stubbedDio);
      expect(await refresher.refresh(), isFalse);
    });
  });
}
