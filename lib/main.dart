import 'package:cookie_jar/cookie_jar.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/background_location_service.dart';
import 'package:rsc_rider/core/theme/app_theme.dart';
import 'package:rsc_rider/core/theme/dark_theme.dart';
import 'package:rsc_rider/di.dart';

// ── Flavors ────────────────────────────────────────────────────────────────────
// Development : flutter run  --dart-define=FLAVOR=development
// Production  : flutter build --dart-define=FLAVOR=production
//
// ── Firebase ───────────────────────────────────────────────────────────────────
// Run `flutterfire configure` to generate lib/firebase_options.dart, then:
//   1. Add: import 'package:rsc_rider/firebase_options.dart';
//   2. Change Firebase.initializeApp() to:
//      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'development');
  await dotenv.load(fileName: '.env.$flavor');

  // Firebase disabled for now — commented out until flutterfire configure is run.
  // var firebaseAvailable = false;
  // try {
  //   await Firebase.initializeApp();
  //   firebaseAvailable = true;
  // } catch (e) {
  //   debugPrint(
  //     '[RSC] Firebase not configured — run `flutterfire configure` '
  //     'and add google-services.json. FCM notifications disabled. ($e)',
  //   );
  // }
  const firebaseAvailable = false;

  // Disk-backed so the rider's session cookie survives an app restart.
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage('${appDocDir.path}/.cookies/'),
  );

  await BackgroundLocationService.initialize();
  await setupDependencies(
    cookieJar: cookieJar,
    firebaseAvailable: firebaseAvailable,
  );

  runApp(RiderApp(router: AppRouter(getIt<AuthNotifier>())));
}

class RiderApp extends StatelessWidget {
  const RiderApp({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'RSC Rider',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: DarkTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router.router,
      );
}
