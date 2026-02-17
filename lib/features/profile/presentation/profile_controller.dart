import 'package:flutter/foundation.dart';

import '../../../app/di/service_locator.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/profile_entity.dart';

/// Controller for managing the current user's profile state.
class ProfileController extends ChangeNotifier {
  ProfileController({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? getIt<SupabaseService>();

  final SupabaseService _supabaseService;

  bool _isLoading = false;
  ProfileEntity? _profile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  ProfileEntity? get profile => _profile;
  String? get errorMessage => _errorMessage;
  bool get hasProfile => _profile != null;

  /// Load the current user's profile.
  Future<void> loadMyProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ProfileEntity? loaded = await _supabaseService.fetchMyProfile();
      _profile = loaded;
      _errorMessage = null;
    } catch (error) {
      _profile = null;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the profile (e.g., on sign-out).
  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
