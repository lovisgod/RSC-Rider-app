import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rsc_rider/core/network/error_interceptor.dart';

class DioClient {
  DioClient({
    required ErrorInterceptor errorInterceptor,
    required CookieJar cookieJar,
  }) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final timeoutSecs =
        int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    final timeout = Duration(seconds: timeoutSecs);

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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
