import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kaalmo_mobile/core/errors/app_exception.dart';
import 'package:kaalmo_mobile/core/network/api_exception_mapper.dart';

RequestOptions _req() => RequestOptions(path: '/x');

void main() {
  group('ApiExceptionMapper', () {
    test('parses the backend { error: { code, message, fields } } shape', () {
      final err = DioException(
        requestOptions: _req(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: _req(),
          statusCode: 400,
          data: {
            'error': {
              'code': 'VALIDATION_ERROR',
              'message': 'Invalid request data',
              'fields': {'email': 'Enter a valid email address'},
            },
          },
        ),
      );

      final mapped = ApiExceptionMapper.fromDio(err);
      expect(mapped, isA<ApiException>());
      final api = mapped as ApiException;
      expect(api.statusCode, 400);
      expect(api.code, 'VALIDATION_ERROR');
      expect(api.message, 'Invalid request data');
      expect(api.fieldErrors['email'], 'Enter a valid email address');
      expect(api.isValidation, isTrue);
    });

    test('flags 401 responses as unauthorized', () {
      final mapped = ApiExceptionMapper.fromDio(DioException(
        requestOptions: _req(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: _req(),
          statusCode: 401,
          data: {'error': {'code': 'UNAUTHORIZED', 'message': 'Missing access token', 'fields': {}}},
        ),
      ));
      expect((mapped as ApiException).isUnauthorized, isTrue);
    });

    test('maps timeouts', () {
      final mapped = ApiExceptionMapper.fromDio(
        DioException(requestOptions: _req(), type: DioExceptionType.receiveTimeout),
      );
      expect(mapped, isA<TimeoutException>());
      expect(mapped.code, AppErrorCode.timeout);
    });

    test('maps connection errors to NetworkException', () {
      final mapped = ApiExceptionMapper.fromDio(
        DioException(requestOptions: _req(), type: DioExceptionType.connectionError),
      );
      expect(mapped, isA<NetworkException>());
      expect(mapped.code, AppErrorCode.network);
    });

    test('passes an AppException wrapped inside DioException through unchanged', () {
      const inner = NetworkException('offline');
      final mapped = ApiExceptionMapper.fromDio(DioException(
        requestOptions: _req(),
        type: DioExceptionType.unknown,
        error: inner,
      ));
      expect(identical(mapped, inner), isTrue);
    });
  });
}
