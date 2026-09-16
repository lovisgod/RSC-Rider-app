# Running Different Environments

The environment is selected by two things together:

- `--flavor` — picks the Android product flavor (app id, app name, google-services.json)
- `--dart-define=ENVIRONMENT=...` — picks the `AppConfig` (base URL) inside Dart

Always pass both, and keep them matching.

## Development (default)

```bash
flutter run \
  --flavor development \
  --dart-define=ENVIRONMENT=development
```

## Staging (for QA)

```bash
flutter run \
  --flavor staging \
  --dart-define=ENVIRONMENT=staging
```

## Production

```bash
flutter run \
  --flavor production \
  --dart-define=ENVIRONMENT=production
```

## Build APK for QA (staging)

```bash
flutter build apk \
  --flavor staging \
  --dart-define=ENVIRONMENT=staging \
  --release
```

## Build APK for production

```bash
flutter build apk \
  --flavor production \
  --dart-define=ENVIRONMENT=production \
  --release
```

## Notes

- Running without `--dart-define` falls back to `development`
  (see `AppConfig.fromEnvironment`).
- All base URLs live in `lib/core/config/app_config.dart` — no URLs in
  `.env` files or anywhere else in Dart.
- `.env.<environment>` files still exist but carry secrets only
  (`GOOGLE_MAPS_API_KEY` for the Directions API).
- Each Android flavor loads its own
  `android/app/src/<flavor>/google-services.json`. The dev/staging copies
  currently reuse the production Firebase app with the suffixed package
  name patched in — register `com.rsc.rsc_rider.dev` /
  `com.rsc.rsc_rider.staging` as Android apps in the Firebase console and
  replace those files when you want per-environment FCM.
- iOS schemes are not set up yet — see `ios/FLAVOR_SETUP.md`.
