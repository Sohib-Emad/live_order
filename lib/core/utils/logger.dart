import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String tag, String message) {
    _log('INFO', tag, message);
  }

  static void warning(String tag, String message) {
    _log('WARN', tag, message);
  }

  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    _log('ERROR', tag, message, error, stack);
  }

  static void _log(String level, String tag, String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint('[$level][$tag] $message${error != null ? ' | $error' : ''}');
      if (stack != null) {
        debugPrint('Stack: $stack');
      }
    }
  }
}
