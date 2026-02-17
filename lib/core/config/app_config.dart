/// Application environment enumeration.
enum AppEnvironment { dev, stage, prod }

/// Basic, non-secret application configuration.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.isDebug,
  });

  final String appName;
  final AppEnvironment environment;
  final bool isDebug;

  bool get isProd => environment == AppEnvironment.prod;

  /// Default configuration for local development.
  factory AppConfig.development() {
    return const AppConfig(
      appName: 'the-hi (Flutter migration)',
      environment: AppEnvironment.dev,
      isDebug: true,
    );
  }
}

