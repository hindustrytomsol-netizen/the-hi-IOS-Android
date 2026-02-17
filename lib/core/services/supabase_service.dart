import 'package:supabase_flutter/supabase_flutter.dart';

import '../logging/app_logger.dart';

/// Thin wrapper around the global [SupabaseClient] instance.
class SupabaseService {
  SupabaseService({required AppLogger logger})
      : _logger = logger,
        _client = Supabase.instance.client;

  final AppLogger _logger;
  final SupabaseClient _client;

  SupabaseClient get client => _client;

  Session? get session => _client.auth.currentSession;

  bool get isSignedIn => session != null;

  /// Minimal health check against the `profiles` table.
  ///
  /// Returns up to one row with a small subset of columns, if present.
  Future<List<Map<String, dynamic>>> healthCheckProfiles() async {
    try {
      final dynamic response =
          await _client.from('profiles').select('id, display_name').limit(1);

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }

      return const <Map<String, dynamic>>[];
    } catch (error, stackTrace) {
      _logger.e(
        'Supabase profiles health check failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw StateError('Supabase health check failed: $error');
    }
  }
}

