sealed class ApiResponse<T> {
  const ApiResponse();

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, int? statusCode) failure,
  }) =>
      switch (this) {
        ApiSuccess<T>(:final data) => success(data),
        ApiFailure<T>(:final message, :final statusCode) =>
          failure(message, statusCode),
      };

  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(String message, int? statusCode)? failure,
  }) =>
      switch (this) {
        ApiSuccess<T>(:final data) => success?.call(data),
        ApiFailure<T>(:final message, :final statusCode) =>
          failure?.call(message, statusCode),
      };
}

final class ApiSuccess<T> extends ApiResponse<T> {
  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<T> extends ApiResponse<T> {
  const ApiFailure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorised => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  ApiFailure<R> cast<R>() => ApiFailure<R>(
        message: message,
        statusCode: statusCode,
      );
}
