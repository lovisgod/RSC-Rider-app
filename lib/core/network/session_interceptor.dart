import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:rsc_rider/core/constants/app_colors.dart';
import 'package:rsc_rider/core/constants/app_strings.dart';
import 'package:rsc_rider/core/router/route_guards.dart';
import 'package:rsc_rider/core/router/route_names.dart';
import 'package:rsc_rider/core/services/location_broadcasting_service.dart';
import 'package:rsc_rider/core/services/socket_service.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';
import 'package:rsc_rider/features/delivery/presentation/cubit/active_orders_cubit.dart';

// The single place session expiry is handled. Any authenticated endpoint
// returning 401 means the rider's session cookie is no longer valid — stop
// rider-specific services, wipe the session, and send them back to login.
// Individual repositories must NOT special-case 401 themselves.
class SessionInterceptor extends Interceptor {
  SessionInterceptor({
    required this._cookieJar,
    required this._localStorage,
    required this._scaffoldMessengerKey,
    required this._router,
  });

  final CookieJar _cookieJar;
  final LocalStorage _localStorage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;
  final GoRouter _router;

  // Prevents a burst of failing requests (e.g. poll + profile + notifications
  // all 401ing at once) from triggering multiple redirects/snackbars.
  bool _isHandlingExpiry = false;

  // Endpoints where a 401 must not trigger the expiry flow: login (wrong
  // credentials), change-password (wrong current password — the profile
  // repository maps that 401 to its own message), and logout (a 401 there
  // means the session is already gone and AuthBloc is doing the cleanup —
  // showing "session expired" during a deliberate logout would be wrong).
  static const List<String> _authPaths = [
    '/auth/login',
    '/auth/change-password',
    '/auth/logout',
  ];

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    final isAuthEndpoint = _authPaths.any(path.contains);

    if (statusCode == 401 && !isAuthEndpoint && !_isHandlingExpiry) {
      _isHandlingExpiry = true;
      _handleExpiry();
    }

    // Always pass the error along so ErrorInterceptor still maps it and the
    // calling repository surfaces a normal failure.
    handler.next(err);
  }

  Future<void> _handleExpiry() async {
    try {
      final riderId = await _localStorage.getRiderId();

      // No rider id means no session ever existed on this device — the 401
      // is not an expiry (e.g. a stray unauthenticated call). Do nothing.
      if (riderId == null) {
        debugPrint(
          '[DineOut NG Rider] 401 received but no rider session exists — '
          'skipping expiry handler',
        );
        _isHandlingExpiry = false;
        return;
      }

      // Stop the location timer first — never keep broadcasting against a
      // dead session.
      try {
        GetIt.instance<LocationBroadcastingService>().stopBroadcasting();
      } catch (e) {
        debugPrint('[DineOut NG Rider] Could not stop broadcasting: $e');
      }

      try {
        GetIt.instance<SocketService>().disconnect();
      } catch (e) {
        debugPrint('[DineOut NG Rider] Could not disconnect socket: $e');
      }

      // Same reason AuthBloc resets it on logout: the cubit is a singleton,
      // and the next rider to log in must not inherit stale orders or an
      // active delivery's masterOrderId.
      try {
        GetIt.instance<ActiveOrdersCubit>().reset();
      } catch (e) {
        debugPrint('[DineOut NG Rider] Could not reset active orders: $e');
      }

      await _cookieJar.deleteAll();
      await _localStorage.clearSession();

      // go_router's redirect is driven by AuthNotifier — without onLogout()
      // the guard still sees an authenticated rider and would bounce the
      // navigation below straight back to the dashboard.
      try {
        GetIt.instance<AuthNotifier>().onLogout();
      } catch (e) {
        debugPrint('[DineOut NG Rider] Could not notify auth state: $e');
      }

      try {
        _router.go(RouteNames.login);
      } catch (e) {
        debugPrint('[DineOut NG Rider] Navigation failed: $e');
      }

      // Small delay so the snackbar appears on the login screen, not on the
      // screen being torn down.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            AppStrings.sessionExpired,
            style: TextStyle(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      debugPrint(
        '[DineOut NG Rider] Session expired — logged out and redirected to login',
      );
    } catch (e) {
      debugPrint('[DineOut NG Rider] Session expiry handler failed: $e');
    } finally {
      // Keep the guard up briefly — in-flight requests fired before the
      // logout will still come back 401 and must not retrigger the flow.
      Future<void>.delayed(const Duration(seconds: 3), () {
        _isHandlingExpiry = false;
      });
    }
  }
}
