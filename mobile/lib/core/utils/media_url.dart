/// The backend embeds its own hostname in uploaded-image URLs at upload time
/// (`http://<host>/uploads/...`). In development that host is usually
/// `localhost:5000`, which a device / emulator cannot reach. Rewrite the
/// origin of such URLs to the configured API origin so images actually load.
///
/// Non-loopback URLs (a real CDN / server) are returned unchanged.
String resolveMediaUrl(String rawUrl, String apiBaseUrl) {
  final url = Uri.tryParse(rawUrl);
  if (url == null || !url.hasScheme) return rawUrl;

  const loopback = {'localhost', '127.0.0.1', '10.0.2.2'};
  if (!loopback.contains(url.host)) return rawUrl;

  final api = Uri.tryParse(apiBaseUrl);
  if (api == null || api.host.isEmpty) return rawUrl;

  final origin = api.hasPort ? '${api.scheme}://${api.host}:${api.port}' : '${api.scheme}://${api.host}';
  final query = url.hasQuery ? '?${url.query}' : '';
  return '$origin${url.path}$query';
}
