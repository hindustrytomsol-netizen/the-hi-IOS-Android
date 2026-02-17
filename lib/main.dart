import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/services/supabase_service.dart';

export 'app/app.dart';

Future<void> main() async {
  await _bootstrap();
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppLogger logger = const DebugPrintAppLogger();
  final AppConfig config = AppConfig.fromEnvironment(logger: logger);

  registerSingleton<AppLogger>(logger);
  registerSingleton<AppConfig>(config);

  logger.i(
    'App started in ${config.environment.name.toUpperCase()} mode',
  );

  if (config.environment != AppEnvironment.development &&
      !config.hasSupabaseConfig) {
    logger.e(
      'Supabase configuration missing for non-development environment '
      '(APP_ENV=${config.environment.name}).',
    );
    throw StateError(
      'Supabase configuration is required for non-development environments. '
      'Please provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define.',
    );
  }

  if (config.hasSupabaseConfig) {
    await Supabase.initialize(
      url: config.supabaseUrl!,
      anonKey: config.supabaseAnonKey!,
    );
    registerSingleton<SupabaseService>(
      SupabaseService(logger: logger),
    );
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    logger.e(
      'FlutterError caught',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  runZonedGuarded(
    () => runApp(const MyApp()),
    (Object error, StackTrace stackTrace) {
      logger.e(
        'Uncaught zone error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

