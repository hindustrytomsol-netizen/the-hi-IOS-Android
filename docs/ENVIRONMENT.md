## Environment Stability Contract

This document captures the core environment and toolchain versions that this Flutter migration project depends on.  
Changes to these values must be deliberate, reviewed, and documented.

### Core SDKs

- **Flutter (pinned)**: `3.41.1` (stable)
- **Dart**: `3.11.0`

### Android toolchain (placeholders)

To be filled in as the migration stabilizes:

- **JDK version**: _TBD_
- **Gradle version**: _TBD_
- **Android Gradle Plugin (AGP)**: _TBD_
- **Kotlin version**: _TBD_
- **compileSdkVersion**: _TBD_
- **targetSdkVersion**: _TBD_
- **minSdkVersion**: _TBD_

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

