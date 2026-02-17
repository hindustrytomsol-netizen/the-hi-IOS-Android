import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/di/service_locator.dart';
import '../../core/config/app_config.dart';
import '../../core/config/app_environment.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/supabase_service.dart';

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
  bool _showErrorDetails = false;

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
      _showErrorDetails = false;
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

  Future<void> _copyRunCommand() async {
    const String template =
        'fvm flutter run \\\n'
        '  --dart-define=APP_ENV=development \\\n'
        '  --dart-define=SUPABASE_URL=https://your-project.supabase.co \\\n'
        '  --dart-define=SUPABASE_ANON_KEY=your_anon_key';
    await Clipboard.setData(const ClipboardData(text: template));
    setState(() {
      _statusMessage = 'Run command template copied to clipboard.';
    });
  }

  void _clearResult() {
    setState(() {
      _isChecking = false;
      _statusMessage = null;
      _errorMessage = null;
      _rows = null;
      _showErrorDetails = false;
    });
  }

  Future<void> _signOut() async {
    if (!_supabaseConfigured || !_supabase!.isSignedIn) {
      return;
    }
    try {
      await _supabase!.client.auth.signOut();
      setState(() {
        _statusMessage = 'Signed out successfully.';
      });
    } catch (error, stackTrace) {
      _logger.e(
        'Sign out failed',
        error: error,
        stackTrace: stackTrace,
      );
      setState(() {
        _errorMessage = 'Sign out failed: $error';
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
            _buildConfigSummaryCard(theme),
            const SizedBox(height: 16),
            if (_supabaseConfigured)
              ElevatedButton(
                onPressed: _isChecking ? null : _runHealthCheck,
                child: Text(_isChecking ? 'Running…' : 'Run health check'),
              )
            else
              _buildSupabaseNotConfigured(isDev, theme),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _copyRunCommand,
                  child: const Text('Copy run command'),
                ),
                OutlinedButton(
                  onPressed: _clearResult,
                  child: const Text('Clear result'),
                ),
                if (_supabaseConfigured && _supabase!.isSignedIn)
                  OutlinedButton(
                    onPressed: _signOut,
                    child: const Text('Sign out'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.green[700]),
              ),
            if (_errorMessage != null) ...[
              Text(
                'Health check failed',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.error),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showErrorDetails = !_showErrorDetails;
                  });
                },
                child: Text(_showErrorDetails ? 'Hide details' : 'Show details'),
              ),
              if (_showErrorDetails)
                SelectableText(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall,
                ),
            ],
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

  Widget _buildConfigSummaryCard(ThemeData theme) {
    final Uri? supabaseUri =
        _config.supabaseUrl != null && _config.supabaseUrl!.isNotEmpty
            ? Uri.tryParse(_config.supabaseUrl!)
            : null;
    final String hostLabel = supabaseUri?.host ?? 'N/A';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Config summary',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Environment: ${_config.environment.name.toUpperCase()}'),
            Text('Supabase configured: $_supabaseConfigured'),
            Text('Signed in: $_signedInLabel'),
            Text('Supabase host: $hostLabel'),
          ],
        ),
      ),
    );
  }
}

