# Pull Request

## Title
fix: initialize sqflite ffi on startup and add web-friendly prefs fallback

## Body
This PR initializes sqflite_common_ffi on app startup (non-web platforms) so the sqflite global databaseFactory is set prior to any database access. It also adds a web-safe SharedPreferences fallback for cached documents in LocalStorageService to avoid runtime errors on web. See RECOMMENDED_PUBSPEC_CHANGE.md for a suggested pubspec change to add sqflite_common_ffi. Changes:
- lib/main.dart (initialize sqflite ffi)
- lib/services/local_storage_service.dart (prefs fallback on web)

## Testing Notes
- Run `flutter pub get` after adding sqflite_common_ffi to pubspec.yaml.
- Web: cached documents use SharedPreferences.
- Desktop: ensure sqflite_common_ffi is added so the DB factory initializes.

## Date Created
2026-01-15 17:57:08