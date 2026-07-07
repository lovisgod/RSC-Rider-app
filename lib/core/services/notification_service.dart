import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/network/dio_client.dart';
import 'package:rsc_rider/core/router/app_router.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/utils/logger.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_order_entity.dart';
import 'package:rsc_rider/features/delivery/domain/entities/assigned_outlet_entity.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';
import 'package:rsc_rider/firebase_options.dart';

const AndroidNotificationChannel _ordersChannel = AndroidNotificationChannel(
  'rsc_rider_orders',
  'Order Assignments',
  description:
      'Notifications for new delivery assignments and order updates',
  // Max importance — a rider must never miss a new order assignment.
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
  enableLights: true,
);

// Must be top-level — Firebase runs this in a separate isolate.
@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Full logging — payload shape isn't finalized yet, so this is how we see
  // exactly what the backend sends while the rider's app is backgrounded.
  debugPrint('[RSC Rider] 🌙 Background message:');
  debugPrint('  title: ${message.notification?.title}');
  debugPrint('  body: ${message.notification?.body}');
  debugPrint('  data: ${message.data}');
}

class NotificationService {
  NotificationService(this._messaging, this._dioClient);

  final FirebaseMessaging _messaging;
  final DioClient _dioClient;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    await _requestPermissions();
    await _setupLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    await refreshAndSaveToken();
    _messaging.onTokenRefresh.listen(_saveTokenToBackend);
  }

  // Re-fetches the current FCM token and registers it with the backend.
  // Call again right after login so the token is associated with the
  // newly authenticated rider session.
  Future<void> refreshAndSaveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        appLogger.i('[FCM] Token: $token');
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      appLogger.w('[FCM] Failed to get token.', error: e);
    }
  }

  Future<void> _saveTokenToBackend(String token) async {
    try {
      await _dioClient.dio.post<void>(
        ApiEndpoints.deviceToken,
        data: {'token': token},
      );
    } catch (e) {
      // Never crash the app over a failed token registration — it will be
      // retried on the next token refresh or app launch.
      appLogger.w('[FCM] Failed to save token to backend.', error: e);
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    appLogger.i('[FCM] Permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_ordersChannel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Full logging — the backend payload shape isn't finalized yet, so this
    // is intentional: it's how we discover exactly what arrives. Trim the
    // verbosity once the real payload shape is confirmed.
    debugPrint('[RSC Rider] 🔔 Foreground notification:');
    debugPrint('  title: ${message.notification?.title}');
    debugPrint('  body: ${message.notification?.body}');
    debugPrint('  data: ${message.data}');

    _showLocalNotification(message);
    _handleNotificationData(message.data);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final title = message.notification?.title ??
        _getTitleFromData(message.data) ??
        'RSC Rider';
    final body = message.notification?.body ??
        _getBodyFromData(message.data) ??
        'You have a new notification';

    try {
      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _ordersChannel.id,
            _ordersChannel.name,
            channelDescription: _ordersChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      appLogger.w('[FCM] Failed to show local notification.', error: e);
    }
  }

  String? _getTitleFromData(Map<String, dynamic> data) =>
      data['title'] as String? ?? data['notification_title'] as String?;

  String? _getBodyFromData(Map<String, dynamic> data) =>
      data['body'] as String? ??
      data['message'] as String? ??
      data['notification_body'] as String?;

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      _navigateToDashboard();
      return;
    }
    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _handleNotificationData(data);
    } catch (e) {
      appLogger.w('[FCM] Failed to parse notification payload.', error: e);
      _navigateToDashboard();
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[RSC Rider] 👆 Notification tapped:');
    debugPrint('  data: ${message.data}');
    _handleNotificationData(message.data);
  }

  // Single entry point for reacting to a notification's data payload —
  // called from the foreground handler, a background/terminated tap, and a
  // tap on a locally-shown notification. The backend payload shape isn't
  // finalized, so this checks several plausible key/value spellings and
  // falls back gracefully for anything it doesn't recognise yet.
  void _handleNotificationData(Map<String, dynamic> data) {
    debugPrint('[RSC Rider] 📦 Notification data: $data');

    final type = data['type'] as String? ??
        data['notificationType'] as String? ??
        data['event'] as String?;
    debugPrint('[RSC Rider] Type: $type');

    switch (type?.toUpperCase()) {
      case 'ORDER_ASSIGNMENT':
      case 'NEW_ORDER':
      case 'DISPATCH':
        debugPrint('[RSC Rider] New order assigned!');
        _onNewOrderAssigned(data);
      case 'ORDER_STATUS':
      case 'ORDER_UPDATE':
        debugPrint('[RSC Rider] Order status update');
        _onOrderStatusUpdate(data);
      default:
        debugPrint('[RSC Rider] Unknown type: $type');
        debugPrint('[RSC Rider] Full data: $data');
        _onGenericNotification();
    }
  }

  // Builds the AssignedOrderEntity directly from the notification payload —
  // no API call needed, so the order appears on the dashboard instantly.
  // dropOff and outlets arrive as JSON-encoded strings, not nested
  // objects/arrays, so they must be jsonDecode()'d before use.
  void _onNewOrderAssigned(Map<String, dynamic> data) {
    try {
      final masterOrderId = data['masterOrderId'] as String;
      debugPrint('[RSC Rider] Order ID: $masterOrderId');

      final dropOff =
          jsonDecode(data['dropOff'] as String) as Map<String, dynamic>;
      final deliveryAddress = dropOff['address'] as String? ?? '';
      final deliveryLat = (dropOff['latitude'] as num).toDouble();
      final deliveryLng = (dropOff['longitude'] as num).toDouble();

      final outletsList =
          jsonDecode(data['outlets'] as String) as List<dynamic>;
      final outlets = outletsList.map((o) {
        final outlet = o as Map<String, dynamic>;
        return AssignedOutletEntity(
          subOrderId: outlet['subOrderId'] as String,
          outletId: outlet['outletId'] as String,
          outletName: outlet['name'] as String,
          pickupAddress: outlet['address'] as String?,
          pickupLatitude: (outlet['latitude'] as num).toDouble(),
          pickupLongitude: (outlet['longitude'] as num).toDouble(),
          pickupCode: outlet['pickupCode'] as String,
          status: 'READY',
          // Not in the notification payload — loaded on demand from
          // GET /riders/me/assigned-orders when the rider starts delivery.
          items: const [],
        );
      }).toList();

      final order = AssignedOrderEntity(
        orderId: masterOrderId,
        status: 'READY',
        deliveryCodeRequired: true,
        deliveryAddress: deliveryAddress,
        deliveryLatitude: deliveryLat,
        deliveryLongitude: deliveryLng,
        customerId: '',
        riderId: '',
        outlets: outlets,
      );

      GetIt.instance<ActiveOrdersCubit>().addOrderFromNotification(order);
      _navigateToDashboard();
    } catch (e) {
      debugPrint('[RSC Rider] Failed to parse notification order: $e');
      // Fallback — reload from the API so the order still shows up.
      try {
        GetIt.instance<ActiveOrdersCubit>().loadAssignedOrders();
      } catch (e2) {
        debugPrint('[RSC Rider] Could not reload orders: $e2');
      }
      _navigateToDashboard();
    }
  }

  void _onOrderStatusUpdate(Map<String, dynamic> data) {
    final orderId =
        data['orderId'] as String? ?? data['masterOrderId'] as String?;
    final status = data['status'] as String?;
    debugPrint('[RSC Rider] Status update: $orderId → $status');

    try {
      GetIt.instance<ActiveOrdersCubit>().loadAssignedOrders();
    } catch (e) {
      debugPrint('[RSC Rider] Could not reload: $e');
    }
  }

  void _onGenericNotification() {
    // Unknown type — just take the rider to the dashboard so they can see
    // whatever changed.
    _navigateToDashboard();
  }

  void _navigateToDashboard() {
    try {
      AppRouter.rootNavigatorKey.currentContext?.go(RouteNames.dashboard);
    } catch (e) {
      appLogger.w('[FCM] Failed to navigate on notification tap.', error: e);
    }
  }
}
