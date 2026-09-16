# iOS Flavor Setup Required

Open Xcode → `ios/Runner.xcworkspace`

Create 3 schemes (each with its own build configuration set):

1. **development**
   - Bundle ID: `com.rsc.rscRider.dev`
   - Display Name: RSC Rider Dev

2. **staging**
   - Bundle ID: `com.rsc.rscRider.staging`
   - Display Name: RSC Rider Staging

3. **production**
   - Bundle ID: `com.rsc.rscRider`
   - Display Name: RSC Rider

Each scheme is run with the matching dart-define:

```bash
flutter run --flavor development --dart-define=ENVIRONMENT=development
flutter run --flavor staging     --dart-define=ENVIRONMENT=staging
flutter run --flavor production  --dart-define=ENVIRONMENT=production
```

For now iOS uses the `defaultValue: 'development'` fallback from
`AppConfig.fromEnvironment()` until the schemes are configured in Xcode —
passing `--dart-define=ENVIRONMENT=...` already selects the right base URL
even without schemes; the schemes only add per-environment bundle IDs and
display names.
