import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/config/app_environment.dart';
import '../../core/logging/app_logger.dart';
import '../di/service_locator.dart';

class MisconfigurationApp extends StatelessWidget {
  const MisconfigurationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Configuration error',
      home: const MisconfigurationScreen(),
    );
  }
}

class MisconfigurationScreen extends StatelessWidget {
  const MisconfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppConfig config = getIt<AppConfig>();
    final AppLogger logger = getIt<AppLogger>();

    logger.e(
      'Application started in ${config.environment.name.toUpperCase()} '
      'without required Supabase configuration.',
    );

    final bool isDev =
        config.environment == AppEnvironment.development;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration error'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment: ${config.environment.name.toUpperCase()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Supabase configuration is required for this environment but is '
              'currently missing.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Expected dart-defines:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              '- SUPABASE_URL\n'
              '- SUPABASE_ANON_KEY',
            ),
            const SizedBox(height: 16),
            if (isDev)
              Text(
                'Tip: In development you can also run without Supabase config '
                'by not setting APP_ENV or setting it to "development".',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}

