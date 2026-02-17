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

### iOS toolchain (placeholders)

To be filled in as the migration stabilizes:

- **Xcode version**: _TBD_
- **CocoaPods version**: _TBD_
- **Ruby version / manager**: _TBD_
- **iOS deployment target**: _TBD_

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


