import 'package:flutter/foundation.dart';

final AppLogger appLogger = AppLogger._();

class AppLogger {
  AppLogger._();

  void i(String message) => debugPrint('[RSC] $message');

  void w(String message, {Object? error}) =>
      debugPrint('⚠️ [RSC] $message${error != null ? ': $error' : ''}');

  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      debugPrint('❌ [RSC] $message${error != null ? ': $error' : ''}');

  void d(String message) => debugPrint('🔍 [RSC] $message');
}
