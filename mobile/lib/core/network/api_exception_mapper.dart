import 'package:dio/dio.dart';

import '../errors/app_exception.dart';

/// Turns a [DioException] into the app's single [AppException] hierarchy,
/// parsing the backend's `{ "error": { "code", "message", "fields" } }` body.
class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static AppException fromDio(DioException error) {
    final type = error.type;

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const TimeoutException();
    }
    if (type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    if (type == DioExceptionType.badCertificate) {
      return const NetworkException('Could not establish a secure connection');
    }
    if (type == DioExceptionType.cancel) {
      return const UnexpectedException('Request cancelled');
    }
    if (type == DioExceptionType.badResponse) {
      return _fromResponse(error.response);
    }

    // DioExceptionType.unknown (and any future member): pass a wrapped
    // AppException through, otherwise treat as a connectivity problem.
    if (error.error is AppException) return error.error as AppException;
    return const NetworkException();
  }

  static ApiException _fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode ?? 0;
    final data = response?.data;

    String message = 'Request failed';
    String? code;
    final fields = <String, String>{};

    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        if (err['message'] is String) message = err['message'] as String;
        if (err['code'] is String) code = err['code'] as String;
        final rawFields = err['fields'];
        if (rawFields is Map) {
          rawFields.forEach((key, value) {
            if (value != null) fields['$key'] = '$value';
          });
        }
      } else if (data['message'] is String) {
        message = data['message'] as String;
      }
    }

    return ApiException(
      message,
      statusCode: status,
      code: code,
      fieldErrors: fields,
    );
  }
}
