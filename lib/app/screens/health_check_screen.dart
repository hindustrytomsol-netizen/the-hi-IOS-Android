import 'package:flutter/material.dart';

import '../../app/di/service_locator.dart';
import '../../core/config/app_config.dart';
import '../../core/services/supabase_service.dart';
import '../../core/logging/app_logger.dart';

class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({
    super.key,
    this.config,
    this.logger,
    this.supabaseService,
  });

  final AppConfig? config;
  final AppLogger? logger;
  final SupabaseService? supabaseService;

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  late final AppConfig _config;
  late final AppLogger _logger;
  late final SupabaseService? _supabase;

  bool _isChecking = false;
  String? _statusMessage;
  String? _errorMessage;
  List<Map<String, dynamic>>? _rows;

  @override
  void initState() {
    super.initState();
    _config = widget.config ?? getIt<AppConfig>();
    _logger = widget.logger ?? getIt<AppLogger>();

    _supabase = widget.supabaseService;
    if (_supabase == null && _config.hasSupabaseConfig) {
      try {
        _supabase = getIt<SupabaseService>();
      } on StateError {
        _supabase = null;
      }
    }
  }

  bool get _supabaseConfigured =>
      _config.hasSupabaseConfig && _supabase != null;

  String get _signedInLabel {
    if (!_supabaseConfigured) {
      return 'N/A';
    }
    return _supabase!.isSignedIn ? 'true' : 'false';
  }

  Future<void> _runHealthCheck() async {
    if (!_supabaseConfigured) {
      return;
    }

    setState(() {
      _isChecking = true;
      _statusMessage = null;
      _errorMessage = null;
      _rows = null;
    });

    try {
      final rows = await _supabase!.healthCheckProfiles();
      setState(() {
        _isChecking = false;
        _rows = rows;
        _statusMessage =
            'OK – received ${rows.length} row(s) from "profiles" table.';
      });
    } catch (error, stackTrace) {
      _logger.e(
        'Health check failed',
        error: error,
        stackTrace: stackTrace,
      );
      setState(() {
        _isChecking = false;
        _errorMessage = 'Health check failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDev =
        _config.environment == AppEnvironment.development;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Check'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Environment: ${_config.environment.name.toUpperCase()}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Supabase configured: $_supabaseConfigured'),
            const SizedBox(height: 4),
            Text('Signed in: $_signedInLabel'),
            const SizedBox(height: 16),
            if (_supabaseConfigured)
              ElevatedButton(
                onPressed: _isChecking ? null : _runHealthCheck,
                child: Text(_isChecking ? 'Running…' : 'Run health check'),
              )
            else
              _buildSupabaseNotConfigured(isDev, theme),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.green[700]),
              ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            const SizedBox(height: 16),
            if (_rows != null && _rows!.isNotEmpty)
              Text(
                'First row preview: ${_rows!.first}',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupabaseNotConfigured(bool isDev, ThemeData theme) {
    if (!isDev) {
      return Text(
        'Supabase configuration is missing. '
        'Non-development builds must provide SUPABASE_URL and SUPABASE_ANON_KEY.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supabase is not configured. To enable the health check, run the app with:',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SelectableText(
          'fvm flutter run \\\n'
          '  --dart-define=APP_ENV=development \\\n'
          '  --dart-define=SUPABASE_URL=https://your-project.supabase.co \\\n'
          '  --dart-define=SUPABASE_ANON_KEY=your_anon_key',
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

