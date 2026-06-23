import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rsc_rider/core/network/auth_interceptor.dart';
import 'package:rsc_rider/core/network/error_interceptor.dart';

class DioClient {
  DioClient({
    required AuthInterceptor authInterceptor,
    required ErrorInterceptor errorInterceptor,
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
      authInterceptor,
      errorInterceptor,
      if (kDebugMode)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  // Convenience factory for a plain Dio used by AuthInterceptor's refresh calls.
  // Has no interceptors — only base options — so refresh never triggers itself.
  static Dio buildRefreshDio() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    final timeoutSecs =
        int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30;
    final timeout = Duration(seconds: timeoutSecs);

    return Dio(
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
  }
}
