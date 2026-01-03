import 'package:flutter/foundation.dart';

/// Production-safe logging utility
/// Logs are only printed in debug mode to prevent sensitive data leakage in production
class AppLogger {
  static const String _prefix = '[ReChoice]';

  /// Log debug level messages
  /// Only visible in debug mode
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [DEBUG] $message');
    }
  }

  /// Log info level messages
  /// Only visible in debug mode
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log warning level messages
  /// Only visible in debug mode
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('$_prefix [WARNING] $message');
    }
  }

  /// Log error level messages with optional exception
  /// Only visible in debug mode
  static void error(String message, [Object? exception, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('$_prefix [ERROR] $message');
      if (exception != null) {
        debugPrint('  Exception: $exception');
      }
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    }
  }
}
