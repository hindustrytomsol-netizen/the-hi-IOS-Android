import 'package:flutter/foundation.dart';

/// Simple application-wide logger abstraction.
abstract class AppLogger {
  void d(String message, {Object? error, StackTrace? stackTrace});

  void i(String message, {Object? error, StackTrace? stackTrace});

  void w(String message, {Object? error, StackTrace? stackTrace});

  void e(String message, {Object? error, StackTrace? stackTrace});
}

/// Default implementation that delegates to [debugPrint].
class DebugPrintAppLogger implements AppLogger {
  const DebugPrintAppLogger();

  @override
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint(_format('DEBUG', message, error, stackTrace));
    }
  }

  @override
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint(_format('INFO', message, error, stackTrace));
    }
  }

  @override
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint(_format('WARN', message, error, stackTrace));
  }

  @override
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    debugPrint(_format('ERROR', message, error, stackTrace));
  }

  String _format(
    String level,
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer('[$level] $message');
    if (error != null) {
      buffer.write(' | error: $error');
    }
    if (stackTrace != null) {
      buffer.write(' | stackTrace: $stackTrace');
    }
    return buffer.toString();
  }
}

