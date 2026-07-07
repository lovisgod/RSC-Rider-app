import 'package:cookie_jar/cookie_jar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/services/background_location_service.dart';
import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/core/theme/app_theme.dart';
import 'package:rsc_rider/core/theme/dark_theme.dart';
import 'package:rsc_rider/di.dart';
import 'package:rsc_rider/firebase_options.dart';

// ── Flavors ────────────────────────────────────────────────────────────────────
// Development : flutter run  --dart-define=FLAVOR=development
// Production  : flutter build --dart-define=FLAVOR=production

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'development');
  await dotenv.load(fileName: '.env.$flavor');

  // Firebase init never crashes the app — FCM notifications are a nice-to-have,
  // not a hard dependency for a rider to keep delivering.
  var firebaseAvailable = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseAvailable = true;
    debugPrint('[RSC Rider] Firebase initialized');
  } catch (e) {
    debugPrint('[RSC Rider] Firebase init failed — FCM disabled. ($e)');
  }

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

  if (firebaseAvailable) {
    try {
      await getIt<NotificationService>().initialize();
    } catch (e) {
      debugPrint('[RSC Rider] Notification setup failed: $e');
    }
  }

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
