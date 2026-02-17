import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_hi_ios_android/core/config/app_environment.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';
import 'core/services/supabase_service.dart';
import 'app/screens/misconfiguration_screen.dart';

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

  final bool needsSupabase =
      config.environment != AppEnvironment.development;
  final bool misconfigured = needsSupabase && !config.hasSupabaseConfig;

  if (!misconfigured && config.hasSupabaseConfig) {
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

  final Widget root = misconfigured
      ? const MisconfigurationApp()
      : const MyApp();

  runZonedGuarded(
    () => runApp(root),
    (Object error, StackTrace stackTrace) {
      logger.e(
        'Uncaught zone error',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

