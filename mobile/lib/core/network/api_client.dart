import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'api_exception_mapper.dart';
import 'auth_interceptor.dart';

/// Thin wrapper over Dio. Every method returns decoded JSON or throws an
/// [AppException]; callers never see a raw [DioException].
class ApiClient {
  ApiClient._(this._dio);

  final Dio _dio;

  Dio get raw => _dio;

  /// Builds the configured client. [buildAuthInterceptor] receives a getter for
  /// the very Dio instance being created, so the interceptor can replay
  /// requests after a token refresh.
  factory ApiClient.create({
    required AppConfig config,
    AuthInterceptor Function(Dio Function() self)? buildAuthInterceptor,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.connectTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    if (buildAuthInterceptor != null) {
      dio.interceptors.add(buildAuthInterceptor(() => dio));
    }

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false, requestHeader: false),
      );
    }

    return ApiClient._(dio);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _send<T>(() => _dio.get<T>(path, queryParameters: query, options: options, cancelToken: cancelToken));

  Future<T> post<T>(String path, {Object? body, Map<String, dynamic>? query, Options? options}) =>
      _send<T>(() => _dio.post<T>(path, data: body, queryParameters: query, options: options));

  Future<T> patch<T>(String path, {Object? body, Options? options}) =>
      _send<T>(() => _dio.patch<T>(path, data: body, options: options));

  Future<T> delete<T>(String path, {Object? body, Options? options}) =>
      _send<T>(() => _dio.delete<T>(path, data: body, options: options));

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      throw ApiExceptionMapper.fromDio(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnexpectedException(e.toString());
    }
  }
}
