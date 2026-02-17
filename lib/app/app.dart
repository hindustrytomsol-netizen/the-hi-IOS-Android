import 'package:flutter/material.dart';

import '../app/di/service_locator.dart';
import '../core/config/app_config.dart';
import '../core/services/supabase_service.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_screen.dart';
import '../features/profile/presentation/profile_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'screens/health_check_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthController? _authController;
  ProfileController? _profileController;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final AppConfig config = getIt<AppConfig>();

    if (config.hasSupabaseConfig) {
      try {
        final SupabaseService supabaseService = getIt<SupabaseService>();
        final AuthController controller = AuthController(
          supabaseService: supabaseService,
        );
        await controller.init();
        registerSingleton<AuthController>(controller);

        // Create ProfileController and load profile if signed in.
        final ProfileController profileController = ProfileController(
          supabaseService: supabaseService,
        );
        registerSingleton<ProfileController>(profileController);

        // Load profile if user is already signed in.
        if (controller.isSignedIn) {
          await profileController.loadMyProfile();
        }

        // Listen to auth state changes to load profile on sign-in.
        controller.addListener(() {
          if (controller.isSignedIn && !profileController.isLoading) {
            profileController.loadMyProfile();
          } else if (!controller.isSignedIn) {
            // Clear profile on sign-out.
            profileController.clearProfile();
          }
        });

        if (mounted) {
          setState(() {
            _authController = controller;
            _profileController = profileController;
            _isInitializing = false;
          });
        }
      } catch (error) {
        // If SupabaseService is not registered, show Health Check in instruction mode.
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authController?.dispose();
    _profileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return MaterialApp(
        title: 'the-hi (Flutter migration)',
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final AppConfig config = getIt<AppConfig>();

    // If Supabase is not configured, show Health Check in instruction mode.
    if (!config.hasSupabaseConfig) {
      return MaterialApp(
        title: 'the-hi (Flutter migration)',
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const HealthCheckScreen(),
      );
    }

    // If Supabase is configured, route based on auth state.
    if (_authController == null) {
      // Fallback: show Health Check if auth controller failed to initialize.
      return MaterialApp(
        title: 'the-hi (Flutter migration)',
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const HealthCheckScreen(),
      );
    }

    return MaterialApp(
      title: 'the-hi (Flutter migration)',
      theme: AppTheme.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: ListenableBuilder(
        listenable: _authController!,
        builder: (BuildContext context, Widget? child) {
          if (_authController!.isSignedIn) {
            return HealthCheckScreen(profileController: _profileController);
          }

          return const AuthScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

