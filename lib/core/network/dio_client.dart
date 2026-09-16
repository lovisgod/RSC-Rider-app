import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:rsc_rider/core/config/app_config.dart';
import 'package:rsc_rider/core/network/error_interceptor.dart';
import 'package:rsc_rider/core/network/session_interceptor.dart';

class DioClient {
  DioClient({
    required AppConfig appConfig,
    required SessionInterceptor sessionInterceptor,
    required ErrorInterceptor errorInterceptor,
    required CookieJar cookieJar,
  }) {
    const timeout = Duration(seconds: 30);

    _dio = Dio(
      BaseOptions(
        // apiBaseUrl carries /api/v1 — ApiEndpoints paths are relative to it.
        baseUrl: appConfig.apiBaseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      // Captures Set-Cookie on responses and attaches Cookie on requests —
      // the rider auth session is carried entirely via HttpOnly cookies.
      // Never set a cookie or Authorization header manually — this is the
      // only place a session is attached.
      CookieManager(cookieJar),
      // Before ErrorInterceptor — it must see the raw 401 status, and
      // ErrorInterceptor's handler.reject() would stop the chain before it.
      sessionInterceptor,
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (log) => debugPrint(log.toString()),
        ),
      errorInterceptor,
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
