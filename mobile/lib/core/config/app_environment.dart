/// Build-time environment selection.
///
/// Chosen with `--dart-define=ENV=staging` (or `production`); defaults to
/// development. Only non-secret values (base URLs) live here — API keys,
/// Firebase credentials and payment secrets must never be compiled into the
/// app.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromName(String value) {
    return AppEnvironment.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppEnvironment.development,
    );
  }

  bool get isProduction => this == AppEnvironment.production;
}
