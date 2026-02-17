## Environment Stability Contract

This document captures the core environment and toolchain versions that this Flutter migration project depends on.  
Changes to these values must be deliberate, reviewed, and documented.

### Core SDKs

- **Flutter (pinned)**: `3.41.1` (stable)
- **Dart**: `3.11.0`

### Android toolchain (placeholders)

Pinned values for this project:

- **JDK version**: `17` (see `android/app/build.gradle.kts` `JavaVersion.VERSION_17`)
- **Gradle version (wrapper)**: `8.14` (see `android/gradle/wrapper/gradle-wrapper.properties`)
- **Android Gradle Plugin (AGP)**: `8.11.1` (see `android/settings.gradle.kts`)
- **Kotlin version (Gradle plugin)**: `2.2.20` (see `android/settings.gradle.kts`)
- **compileSdkVersion**: managed by the Flutter Gradle plugin via `flutter.compileSdkVersion` for Flutter `3.41.1`
- **targetSdkVersion**: managed by the Flutter Gradle plugin via `flutter.targetSdkVersion` for Flutter `3.41.1`
- **minSdkVersion**: managed by the Flutter Gradle plugin via `flutter.minSdkVersion` for Flutter `3.41.1`

### iOS toolchain

Pinned expectations and placeholders for local setup:

- **Xcode version**: _TBD_ (e.g. Xcode 16.x)
- **CocoaPods version**: _TBD_ (e.g. 1.15.x)
- **Ruby version / manager**: _TBD_ (system Ruby / rbenv / asdf, etc.)
- **iOS deployment target**: `13.0` (see `ios/Podfile` and `ios/Runner.xcodeproj/project.pbxproj`)

### Update policy

- Do **not** upgrade **Flutter**, **Dart**, **AGP**, **Kotlin**, **Xcode**, or other core toolchain components casually.
- Any upgrade **must**:
  - Be motivated by a clear **reason** (e.g. security fix, SDK deprecation, new platform requirement).
  - Be documented in this repository (include the **old** and **new** versions).
  - Include the **exact commands** and steps used to perform the upgrade.
  - Include a **verification checklist** (see below) that was run successfully after the upgrade.
- Unexpected breakages related to SDK/toolchain upgrades should be logged in `docs/SDK_ISSUES.md`.

### Verification checklist (commands only)

When validating an environment or after any upgrade, run these commands (do not modify them here):

- `fvm flutter --version`
- `fvm flutter doctor -v`
- `fvm flutter pub get`
- `fvm flutter analyze`
- `fvm flutter test`

### Android build verification (commands only)

Use these commands to verify that the pinned Android toolchain and SDK levels still build correctly:

- `fvm flutter doctor -v`
- `fvm flutter build apk --debug`
- `fvm flutter build apk --release`  <!-- build-only; may use debug signing config -->

### iOS build verification (commands only)

Use these commands on macOS with Xcode installed to verify the iOS toolchain:

- `fvm flutter doctor -v`
- `cd ios && pod repo update && pod install`
- `cd .. && fvm flutter build ios --no-codesign`
- `fvm flutter run -d <ios device>`  <!-- requires a connected iOS device or simulator -->


### Supabase configuration (via dart-define)

Supabase configuration is provided at runtime via Dart environment defines and is **never** committed to the repository.

- **SUPABASE_URL**: Supabase project URL (e.g. `https://your-project.supabase.co`)
- **SUPABASE_ANON_KEY**: Supabase anonymous public key for client-side use
- **APP_ENV**: One of `development`, `staging`, or `production` (defaults to `development`)

Verification (commands only):

- Run the app without Supabase config (development fallback):
  - `fvm flutter run`
- Run the app with Supabase config (health check enabled):
  - `fvm flutter run --dart-define=APP_ENV=development --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_anon_key`
- Use the in-app Health Check screen to verify:
  - Environment label
  - Supabase configured flag
  - Health check result for the `profiles` table


