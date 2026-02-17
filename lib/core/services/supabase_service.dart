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
  /// Tries a `select('*')` with `limit(1)`, and if that fails, falls back to
  /// selecting only the `id` column. Always returns a list of maps.
  Future<List<Map<String, dynamic>>> healthCheckProfiles() async {
    // First attempt: select all columns with limit 1.
    try {
      final dynamic response =
          await _client.from('profiles').select().limit(1);

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
    } catch (error, stackTrace) {
      _logger.w(
        'Supabase profiles health check (select *) failed, falling back to id-only query',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Fallback: select only `id` with limit 1.
    try {
      final dynamic response =
          await _client.from('profiles').select('id').limit(1);

      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }

      return const <Map<String, dynamic>>[];
    } catch (error, stackTrace) {
      _logger.e(
        'Supabase profiles health check fallback (id-only) failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw StateError('Supabase health check failed: $error');
    }
  }
}


