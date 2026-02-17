## SDK / Toolchain Issues Log

Use this document to record any problems related to the Flutter SDK, Dart, Android/iOS toolchains, or related build tooling.  
Each entry should be appended to this file using the template below.

### Issue template

Copy and fill in this template for each issue:

```markdown
#### Issue: <short title>

- **Date**: <!-- YYYY-MM-DD -->
- **Symptom (full error)**:
  - ```text
    <paste the full error output here>
    ```
- **Environment**:
  - Flutter: `<output of "fvm flutter --version">`
  - Dart: `<from flutter --version or dart --version>`
  - OS: `<e.g. macOS 15.x / Ubuntu 24.04 / Windows 11>`
  - Android: `<SDK / emulator / device info, if relevant>`
  - iOS: `<Xcode version / simulator / device info, if relevant>`
- **Root cause**:
  - `<what actually went wrong>`
- **Fix steps**:
  1. `<step one>`
  2. `<step two>`
  3. `<etc>`
- **Verified by (commands)**:
  - `fvm flutter doctor -v`
  - `fvm flutter pub get`
  - `fvm flutter analyze`
  - `fvm flutter test`
  - `<any additional verification commands>`
- **Notes / links (optional)**:
  - `<internal docs, tickets, release notes, etc.>`
```

