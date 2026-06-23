import 'dart:async';

import 'package:dio/dio.dart';
import 'package:rsc_rider/core/constants/api_endpoints.dart';
import 'package:rsc_rider/core/storage/local_storage.dart';

// _refreshDio is a plain Dio instance (no auth interceptor) used exclusively
// for the token-refresh call and retries, preventing infinite-loop 401s.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._refreshDio);

  final LocalStorage _storage;
  final Dio _refreshDio;

  bool _isRefreshing = false;
  final List<
      ({
        RequestOptions options,
        Completer<Response<dynamic>> completer,
      })> _queue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final isRefreshPath =
        err.requestOptions.path.contains(ApiEndpoints.refreshToken);

    if (!is401 || isRefreshPath) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<Response<dynamic>>();
      _queue.add((options: err.requestOptions, completer: completer));
      try {
        handler.resolve(await completer.future);
      } catch (_) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;
    try {
      final stored = await _storage.getRefreshToken();
      if (stored == null) throw Exception('No refresh token stored');

      final res = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': stored},
      );

      final newAccess = res.data!['access_token'] as String;
      final newRefresh = res.data!['refresh_token'] as String? ?? stored;

      await _storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      // Resolve all queued requests with the new token
      for (final pending in _queue) {
        unawaited(
          _retry(pending.options, newAccess)
              .then(pending.completer.complete)
              .catchError(pending.completer.completeError),
        );
      }
      _queue.clear();

      handler.resolve(await _retry(err.requestOptions, newAccess));
    } catch (_) {
      await _storage.clearSession();
      for (final pending in _queue) {
        pending.completer.completeError(err);
      }
      _queue.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) =>
      _refreshDio.request<dynamic>(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: Options(
          method: options.method,
          headers: {
            ...options.headers,
            'Authorization': 'Bearer $token',
          },
          extra: options.extra,
        ),
      );
}
