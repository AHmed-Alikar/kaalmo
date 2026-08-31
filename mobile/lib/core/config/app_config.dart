import 'app_environment.dart';

/// Resolved, immutable runtime configuration.
///
/// Values come from compile-time `--dart-define`s with safe defaults so the
/// app runs against a local backend out of the box:
///
/// ```
/// flutter run --dart-define=ENV=staging
/// flutter run --dart-define=API_BASE_URL=https://api.kaalmo.example/api/v1
/// ```
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.webBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
  });

  final AppEnvironment environment;

  /// Includes the `/api/v1` prefix — matches the existing backend.
  final String apiBaseUrl;

  /// Public web app origin — used to build shareable campaign links
  /// (`<webBaseUrl>/campaigns/<id>`). Non-secret.
  final String webBaseUrl;

  final Duration connectTimeout;
  final Duration receiveTimeout;

  static const _envName = String.fromEnvironment('ENV', defaultValue: 'development');
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
  static const _webBaseUrlOverride = String.fromEnvironment('WEB_BASE_URL');

  static const _defaultBaseUrls = <AppEnvironment, String>{
    // Local backend on the dev machine's port 5000, reached via
    //   adb reverse tcp:5000 tcp:5000
    // which tunnels the device's localhost:5000 to the PC over USB. This works
    // the same for a physical device and an emulator. (An emulator can also use
    // --dart-define=API_BASE_URL=http://10.0.2.2:5000/api/v1 without adb reverse.)
    // Cleartext HTTP to localhost is permitted in debug builds only — see
    // android/app/src/debug/res/xml/network_security_config.xml.
    AppEnvironment.development: 'http://localhost:5000/api/v1',
    AppEnvironment.staging: 'https://staging.kaalmo.example/api/v1',
    AppEnvironment.production: 'https://api.kaalmo.example/api/v1',
  };

  static const _defaultWebBaseUrls = <AppEnvironment, String>{
    AppEnvironment.development: 'http://localhost:5173',
    AppEnvironment.staging: 'https://staging.kaalmo.example',
    AppEnvironment.production: 'https://kaalmo.example',
  };

  factory AppConfig.resolve() {
    final env = AppEnvironment.fromName(_envName);
    return AppConfig(
      environment: env,
      apiBaseUrl: _apiBaseUrlOverride.isNotEmpty ? _apiBaseUrlOverride : _defaultBaseUrls[env]!,
      webBaseUrl: _webBaseUrlOverride.isNotEmpty ? _webBaseUrlOverride : _defaultWebBaseUrls[env]!,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
    );
  }
}
