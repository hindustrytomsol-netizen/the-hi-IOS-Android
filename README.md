## the-hi (Flutter migration)

Flutter migration target for **the-hi**, replacing the existing Next.js-based native iOS/Android apps with a single Flutter codebase.

This repository contains the Flutter application scaffold and tooling configuration that will serve as the migration target for the-hi’s mobile clients.

### Prerequisites

- **git** installed
- **FVM** installed (Flutter Version Management)
- Platform tooling for your target(s):
  - **Android**: Android Studio / Android SDK
  - **iOS** (macOS only): Xcode, CocoaPods

### FVM-only policy

This repository is **FVM-first**. Do **not** call `flutter` directly.

- Always run in a fresh clone:
  - `fvm install`
  - `fvm use -f`
- Always use FVM for all Flutter commands:
  - `fvm flutter ...`

### Quickstart

From the repository root:

```bash
fvm install
fvm use -f
fvm flutter pub get
fvm flutter run
```

### Common commands

- Fetch dependencies: `fvm flutter pub get`
- Run tests: `fvm flutter test`
- Static analysis: `fvm flutter analyze`
- Clean build artifacts: `fvm flutter clean`

### Quality gates

Before opening a PR or merging changes, run:

- Format code: `fvm flutter format .`
- Static analysis: `fvm flutter analyze`
- Tests: `fvm flutter test`

These commands will later be enforced in CI to keep the codebase healthy during the migration.

### Architecture: Foundation (3.1)

- `lib/app/` – application bootstrap, root `MyApp` widget, theme (`app_theme.dart`), and router placeholder (`app_router.dart`).
- `lib/core/` – cross-cutting utilities such as configuration (`app_config.dart`) and logging (`app_logger.dart`).
- `lib/features/` – placeholder for upcoming vertical slices (auth, chat, feed, media, etc.).
- App startup is centralized in `lib/main.dart`, which:
  - Configures a small service locator for core singletons (config, logger).
  - Wraps `runApp` in a guarded zone (`runZonedGuarded`) and hooks `FlutterError.onError` so uncaught errors are routed through the shared logger.

### Environment Variables (dart-define)

Runtime environment and secret values are provided via `--dart-define` and are **not** committed to this repository.

Example run command:

```bash
fvm flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Notes:

- Defaults:
  - `APP_ENV` defaults to `development` if not provided.
  - `SUPABASE_URL` and `SUPABASE_ANON_KEY` are optional for now and may be `null` in development.
- Secrets are **never** committed to the repo; CI and deployment environments must provide the appropriate `--dart-define` values.

### Supabase bootstrap (3.3)

- Core dependency: `supabase_flutter` (pinned in `pubspec.yaml`).
- Configuration:
  - `SUPABASE_URL` and `SUPABASE_ANON_KEY` must be provided via `--dart-define` for non-development environments.
  - In **development**, Supabase config is optional; the app will show a “Supabase not configured” message and instructions on the Health Check screen.
- Behavior:
  - In **staging/production**, if Supabase config is missing, the app fails fast during bootstrap with a clear error to avoid shipping a broken build.
  - When configured, a `SupabaseService` is initialized and registered in the service locator, and the Health Check screen can run a minimal `profiles` table query.

### SDK binaries and version control

Do **not** commit SDK binaries.

- FVM-managed SDK directories must remain ignored:
  - `.fvm/flutter_sdk`
  - `.fvm/versions`

Only FVM configuration files (such as `.fvmrc` and `.fvm/fvm_config.json`) should be committed to version control, not the SDK binaries themselves.

