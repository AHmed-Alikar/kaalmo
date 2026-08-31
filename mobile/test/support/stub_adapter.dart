import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Minimal Dio [HttpClientAdapter] for tests — routes each request through a
/// handler you supply. No sockets, no server.
class StubAdapter implements HttpClientAdapter {
  StubAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);
}

ResponseBody jsonResponse(int status, Object body) => ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
