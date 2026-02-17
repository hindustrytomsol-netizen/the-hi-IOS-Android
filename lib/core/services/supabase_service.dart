import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/domain/profile_entity.dart';
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

  /// Stream of auth state changes from Supabase.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password.
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error, stackTrace) {
      _logger.e(
        'Supabase sign in failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error, stackTrace) {
      _logger.e(
        'Supabase sign out failed',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Fetch the current user's profile from the `profiles` table.
  ///
  /// Returns `null` if no user is signed in.
  /// Tries to select common profile columns, falls back to `id` only if columns are missing.
  Future<ProfileEntity?> fetchMyProfile() async {
    final User? user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    // First attempt: select common profile columns.
    try {
      final dynamic response = await _client
          .from('profiles')
          .select('id, display_name, username, avatar_url, created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (response is Map<String, dynamic>) {
        return ProfileEntity.fromMap(response);
      }
      return null;
    } catch (error, stackTrace) {
      _logger.w(
        'Supabase fetchMyProfile (full columns) failed, falling back to id-only query',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // Fallback: select only `id`.
    try {
      final dynamic response = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (response is Map<String, dynamic>) {
        return ProfileEntity.fromMap(response);
      }
      return null;
    } catch (error, stackTrace) {
      _logger.e(
        'Supabase fetchMyProfile (id-only) failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw StateError('Failed to fetch profile: $error');
    }
  }

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


