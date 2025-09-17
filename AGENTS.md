# Repository Guidelines

## Project Structure & Modules
- `lib/`: Dart sources. Entry `main.dart`; screens/utilities like `sc*`, services like `db.dart`, `helper.dart`. Shared internals in `lib/src/` (e.g., `nettskjema.dart`).
- `assets/`: bundled runtime assets. `assets_src/`: asset sources (e.g., app icon).
- `test/`: tests and small utilities (e.g., `upload_saved_files.dart`).
- `android/`, `ios/`: platform projects. `tools/`: R helpers for evaluation.
- Flutter version pinned via FVM (`.fvmrc`).

## Build, Test, and Development
- Install deps: `fvm flutter pub get`
- Format: `fvm dart format --fix .`
- Static analysis: `fvm dart analyze`
- Run app: `fvm flutter run -d <device>`
- Unit/widget tests: `fvm flutter test`
- Coverage (optional): `fvm flutter test --coverage`
- Release builds: `fvm flutter build apk --release` and `fvm flutter build ios --release`
- Utility upload script example: `fvm dart test/upload_saved_files.dart <form_id> <dir> <prefix>`

## Coding Style & Naming
- Dart/Flutter defaults: 2‑space indent, 80–100 col soft wrap.
- Files: `snake_case.dart` (e.g., `scsettings.dart` already present; prefer `sc_settings.dart` for new files).
- Types/Widgets: UpperCamelCase; methods/vars: lowerCamelCase; private members prefix `_`.
- Always run formatter and analyzer before pushing.

## Testing Guidelines
- Framework: `flutter_test` in `test/`, name files `*_test.dart`.
- Prefer fast, isolated tests; mock network (`http.Client`) for `lib/src/nettskjema.dart` calls.
- Keep widget tests deterministic; avoid real timers/network.

## Commit & Pull Request Guidelines
- Commits: short, imperative subject (e.g., “Fix draw latency”), optional emoji/tag; group related changes.
- PRs: include purpose, screenshots for UI changes, steps to test, and any platform notes. Link issues.
- Require green `analyze` and `test` locally; update docs (`README.md`, this file) when behavior changes.

## Security & Configuration Tips
- Do not commit secrets or personal data. Nettskjema form IDs should be provided at runtime.
- iOS file sharing requires `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` in Info.plist (see README).
- Android saved files path example: `/sdcard/Android/data/<appid>/files/`.
