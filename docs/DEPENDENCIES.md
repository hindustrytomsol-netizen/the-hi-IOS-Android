## Dependency and Pinning Policy

This document describes how we manage dependencies in this Flutter migration project to keep builds reproducible and stable.

### Why we pin

- Avoid SDK/toolchain drift that can silently break builds or tests.
- Ensure that all developers and CI use the **same** dependency graph.
- Make upgrades intentional, reviewable, and easy to roll back.

### Current state

- This repository currently uses the default Flutter scaffold dependencies.
- The Flutter/Dart SDK versions are pinned via FVM:
  - Flutter: `3.41.1` (stable)
  - Dart: `3.11.0`
- `pubspec.lock` is committed to allow reproducible application builds.

### Rules

- **Scaffold dependencies**
  - Keep the initial scaffold dependencies as generated, unless a change is required for:
    - Bug/security fixes, or
    - Compatibility with our pinned Flutter/Dart SDKs.

- **Future critical packages** (examples: Supabase, router, state management, notifications, media):
  - Prefer **explicit versions** for core, critical dependencies.
  - Avoid overly broad version ranges for those core packages.
  - Group upgrades for a given package (or small set of related packages) into a **single, focused PR**.
  - Each dependency change should include:
    - A short rationale (why we are upgrading/adding).
    - A summary of any breaking changes addressed.
    - A list of verification commands run (see below).

- **SDK / toolchain upgrades**
  - Do **not** upgrade Flutter, AGP, Kotlin, Xcode, or other core toolchain components “just because”.
  - Any SDK/toolchain upgrade must follow the **Environment Stability Contract** in `[docs/ENVIRONMENT.md](mdc:docs/ENVIRONMENT.md)` and be documented there.

### Helpful commands

- Show which dependencies are outdated:
  - `fvm flutter pub outdated`
- Upgrade dependencies (use intentionally, in dedicated PRs):
  - `fvm flutter pub upgrade`
- Refresh lockfile and fetch dependencies:
  - `fvm flutter pub get`

### Verification checklist for dependency changes

After changing `pubspec.yaml` or updating the lockfile, run at least:

- `fvm flutter pub get`
- `fvm flutter analyze`
- `fvm flutter test`

