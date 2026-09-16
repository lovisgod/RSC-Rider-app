import 'package:cookie_jar/cookie_jar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rsc_rider/core/config/app_config.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/services/background_location_service.dart';
import 'package:rsc_rider/core/services/notification_service.dart';
import 'package:rsc_rider/core/services/socket_event_handler.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/core/theme/app_theme.dart';
import 'package:rsc_rider/core/theme/dark_theme.dart';
import 'package:rsc_rider/di.dart';
import 'package:rsc_rider/firebase_options.dart';

// ── Flavors ────────────────────────────────────────────────────────────────────
// See ENVIRONMENTS.md — e.g.
// flutter run --flavor development --dart-define=ENVIRONMENT=development

// Lets SessionInterceptor show the "session expired" snackbar from outside
// the widget tree. Navigation uses AppRouter.rootNavigatorKey, which is
// already wired into GoRouter.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AppConfig appConfig = AppConfig.fromEnvironment();
  debugPrint('[DineOut NG Rider] Environment: ${appConfig.environment}');
  debugPrint('[DineOut NG Rider] Base URL: ${appConfig.baseUrl}');

  // .env only carries secrets (GOOGLE_MAPS_API_KEY) — all URLs come from
  // AppConfig now.
  await dotenv.load(fileName: '.env.${appConfig.environment}');

  // Firebase init never crashes the app — FCM notifications are a nice-to-have,
  // not a hard dependency for a rider to keep delivering.
  var firebaseAvailable = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseAvailable = true;
    debugPrint('[DineOut NG Rider] Firebase initialized');
  } catch (e) {
    debugPrint('[DineOut NG Rider] Firebase init failed — FCM disabled. ($e)');
  }

  // Disk-backed so the rider's session cookie survives an app restart.
  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage('${appDocDir.path}/.cookies/'),
  );

  await BackgroundLocationService.initialize();
  await setupDependencies(
    appConfig,
    cookieJar: cookieJar,
    firebaseAvailable: firebaseAvailable,
    scaffoldMessengerKey: scaffoldMessengerKey,
  );

  if (firebaseAvailable) {
    try {
      await getIt<NotificationService>().initialize();
    } catch (e) {
      debugPrint('[DineOut NG Rider] Notification setup failed: $e');
    }
  }

  // Rider is already logged in from a previous session — reconnect the
  // realtime socket immediately rather than waiting for a fresh login.
  try {
    final riderId = await getIt<LocalStorage>().getRiderId();
    if (riderId != null) {
      getIt<SocketService>().connect();
      getIt<SocketService>().subscribeToRoom('rider:$riderId');
      getIt<SocketEventHandler>().initialize();
      debugPrint('[DineOut NG Rider Socket] Resumed session for rider:$riderId');
    }
  } catch (e) {
    debugPrint('[DineOut NG Rider Socket] Startup socket connect failed: $e');
  }

  // AppRouter is created inside setupDependencies — SessionInterceptor needs
  // the GoRouter instance before DioClient can be built.
  runApp(RiderApp(router: getIt<AppRouter>()));
}

class RiderApp extends StatelessWidget {
  const RiderApp({super.key, required this.router});

  final AppRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'DineOut NG Rider',
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: DarkTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: router.router,
      );
}
