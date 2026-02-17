import 'app_environment.dart';
import '../logging/app_logger.dart';

/// Basic, non-secret application configuration.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.environment,
    required this.isDebug,
    this.supabaseUrl,
    this.supabaseAnonKey,
  });

  final String appName;
  final AppEnvironment environment;
  final bool isDebug;
  final String? supabaseUrl;
  final String? supabaseAnonKey;

  bool get isProd => environment == AppEnvironment.production;

  /// Whether Supabase configuration appears to be present.
  bool get hasSupabaseConfig =>
      (supabaseUrl != null && supabaseUrl!.isNotEmpty) &&
      (supabaseAnonKey != null && supabaseAnonKey!.isNotEmpty);

  /// Default configuration for local development.
  factory AppConfig.development() {
    return const AppConfig(
      appName: 'the-hi (Flutter migration)',
      environment: AppEnvironment.development,
      isDebug: true,
    );
  }

  /// Build configuration from compile-time environment values.
  ///
  /// Uses `--dart-define` values where provided and falls back to sensible
  /// defaults so the app can still boot in local development.
  factory AppConfig.fromEnvironment({AppLogger? logger}) {
    const envString =
        String.fromEnvironment('APP_ENV', defaultValue: 'development');
    final environment = appEnvironmentFromString(envString);
    final bool isDebug = environment == AppEnvironment.development;

    const rawSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const rawSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    final String? supabaseUrl =
        rawSupabaseUrl.isEmpty ? null : rawSupabaseUrl;
    final String? supabaseAnonKey =
        rawSupabaseAnonKey.isEmpty ? null : rawSupabaseAnonKey;

    if (environment != AppEnvironment.development) {
      final bool missingUrl = supabaseUrl == null || supabaseUrl.isEmpty;
      final bool missingKey =
          supabaseAnonKey == null || supabaseAnonKey.isEmpty;

      if ((missingUrl || missingKey) && logger != null) {
        logger.w(
          'Supabase configuration is incomplete for non-development environment '
          '($environment). URL missing: $missingUrl, key missing: $missingKey',
        );
      }
    }

    return AppConfig(
      appName: 'the-hi (Flutter migration)',
      environment: environment,
      isDebug: isDebug,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
    );
  }
}
