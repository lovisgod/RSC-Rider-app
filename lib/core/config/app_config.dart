// Environment configuration — the single source of truth for every URL in
// the app. Selected at build time via --dart-define=ENVIRONMENT=<env> and
// registered first in DI so anything can read it via getIt<AppConfig>().
class AppConfig {
  const AppConfig._({
    required this.environment,
    required this.baseUrl,
    required this.appName,
  });

  final String environment;
  final String baseUrl;
  final String appName;

  static const AppConfig development = AppConfig._(
    environment: 'development',
    baseUrl: 'https://api-dev.rscdev.tech',
    appName: 'DineOut NG Rider Dev',
  );

  static const AppConfig staging = AppConfig._(
    environment: 'staging',
    baseUrl: 'https://api-staging.rscdev.tech',
    appName: 'DineOut NG Rider Staging',
  );

  static const AppConfig production = AppConfig._(
    environment: 'production',
    baseUrl: 'https://api.rscdev.tech',
    appName: 'DineOut NG Rider',
  );

  // REST base for DioClient — every ApiEndpoints path is relative to /api/v1,
  // while the Socket.IO handshake uses the bare [baseUrl].
  String get apiBaseUrl => '$baseUrl/api/v1';

  bool get isDevelopment => environment == 'development';
  bool get isStaging => environment == 'staging';
  bool get isProduction => environment == 'production';

  // defaultValue 'development' so plain `flutter run` without --dart-define
  // still works.
  static AppConfig fromEnvironment() {
    const env = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: 'development',
    );
    switch (env) {
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return development;
    }
  }

  @override
  String toString() => 'AppConfig($environment: $baseUrl)';
}
