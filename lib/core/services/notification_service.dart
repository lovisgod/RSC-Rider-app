import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rsc_rider/core/utils/logger.dart';

// Must be top-level — Firebase runs this in a separate isolate.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  appLogger.i(
    '[FCM] Background message: ${message.notification?.title}',
  );
}

class NotificationService {
  NotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  Future<void> initialize() async {
    await _requestPermissions();
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    _setupForegroundHandler();
    _setupOpenedAppHandler();
  }

  // Returns the FCM token. Register this with the backend after login.
  Future<String?> getToken() => _messaging.getToken();

  // Emits whenever FCM rotates the token — re-register with backend.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  // Emits messages received while the app is open (foreground).
  Stream<RemoteMessage> get onForegroundMessage =>
      FirebaseMessaging.onMessage;

  // Emits when the user taps a notification and opens the app from background.
  Stream<RemoteMessage> get onNotificationTap =>
      FirebaseMessaging.onMessageOpenedApp;

  // Returns the message that launched the app from a terminated state.
  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    appLogger.i(
      '[FCM] Permission: ${settings.authorizationStatus}',
    );
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) {
      appLogger.i(
        '[FCM] Foreground: ${message.notification?.title} — ${message.notification?.body}',
      );
    });
  }

  void _setupOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      appLogger.i('[FCM] Opened from background tap: ${message.messageId}');
    });
  }
}
