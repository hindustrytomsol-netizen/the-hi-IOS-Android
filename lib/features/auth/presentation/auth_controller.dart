import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/di/service_locator.dart';
import '../../../core/services/supabase_service.dart';

/// Single source of truth for authentication state.
class AuthController extends ChangeNotifier {
  AuthController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? getIt<SupabaseService>();

  final SupabaseService _supabaseService;
  StreamSubscription<AuthState>? _authSubscription;

  Session? _session;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Session? get session => _session;
  User? get user => _user;
  bool get isSignedIn => _session != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize the auth controller and subscribe to auth state changes.
  Future<void> init() async {
    _updateFromCurrentSession();

    _authSubscription = _supabaseService.authStateChanges.listen(
      (AuthState state) {
        _updateFromAuthState(state);
      },
    );
  }

  void _updateFromCurrentSession() {
    _session = _supabaseService.session;
    _user = _session?.user;
    _errorMessage = null;
    notifyListeners();
  }

  void _updateFromAuthState(AuthState state) {
    _session = state.session;
    _user = state.session?.user;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sign in with email and password.
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signInWithPassword(
        email: email,
        password: password,
      );
      // Auth state will be updated via the stream listener.
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signOut();
      // Auth state will be updated via the stream listener.
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
