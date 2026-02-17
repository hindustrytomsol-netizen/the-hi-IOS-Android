/// Supported application environments.
enum AppEnvironment {
  development,
  staging,
  production,
}

/// Parse a string into an [AppEnvironment], defaulting to [AppEnvironment.development].
AppEnvironment appEnvironmentFromString(String value) {
  switch (value.toLowerCase()) {
    case 'dev':
    case 'development':
      return AppEnvironment.development;
    case 'stage':
    case 'staging':
      return AppEnvironment.staging;
    case 'prod':
    case 'production':
      return AppEnvironment.production;
    default:
      return AppEnvironment.development;
  }
}

