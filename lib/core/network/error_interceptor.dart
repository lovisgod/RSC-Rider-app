import 'package:dio/dio.dart';
import 'package:rsc_rider/core/network/api_response.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _map(err),
      ),
    );
  }

  ApiFailure<Never> _map(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const ApiFailure(
          message: 'Connection timed out. Please try again.',
        ),
      DioExceptionType.connectionError => const ApiFailure(
          message: 'No internet connection.',
        ),
      DioExceptionType.badResponse => _fromResponse(err.response),
      _ => ApiFailure(
          message: err.message ?? 'An unexpected error occurred.',
        ),
    };
  }

  ApiFailure<Never> _fromResponse(Response<dynamic>? response) {
    final code = response?.statusCode;
    final message = _extractMessage(response) ?? _defaultMessage(code);
    return ApiFailure(message: message, statusCode: code);
  }

  String? _extractMessage(Response<dynamic>? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? data['error'] as String?;
      }
    } catch (_) {}
    return null;
  }

  String _defaultMessage(int? code) {
    if (code == null) return 'Something went wrong.';
    return switch (code) {
      400 => 'Bad request.',
      401 => 'Unauthorised.',
      403 => 'Access denied.',
      404 => 'Resource not found.',
      422 => 'Validation failed.',
      429 => 'Too many requests. Please slow down.',
      >= 500 => 'Server error. Please try again later.',
      _ => 'Something went wrong.',
    };
  }
}
