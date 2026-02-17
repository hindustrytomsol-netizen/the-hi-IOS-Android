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

### Dependency and lockfile policy

- This is an **application** repository, so `pubspec.lock` is committed to version control for reproducible builds.
- Always use FVM when modifying dependencies or refreshing the lockfile:
  - `fvm flutter pub get`
  - `fvm flutter pub upgrade` (only in intentional dependency-update work)
- Do **not** run plain `flutter pub ...` in this repo; always go through `fvm flutter ...`.

### Repository structure (high-level)

- `docs/` – environment / roadmap / SDK issue documentation
- `lib/` – Flutter application source code
- `android/` – Android project wrapper
- `ios/` – iOS project wrapper

### SDK binaries and version control

Do **not** commit SDK binaries.

- FVM-managed SDK directories must remain ignored:
  - `.fvm/flutter_sdk`
  - `.fvm/versions`

Only FVM configuration files (such as `.fvmrc` and `.fvm/fvm_config.json`) should be committed to version control, not the SDK binaries themselves.

