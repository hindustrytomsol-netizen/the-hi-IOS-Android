import 'dart:async';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/di/service_locator.dart';
import 'core/config/app_config.dart';
import 'core/logging/app_logger.dart';

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

