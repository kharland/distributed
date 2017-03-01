// TODO: move this to a common package
import 'dart:io';

import 'package:logging/logging.dart' as l;

final logger = new Logger('distributed');

abstract class Logger {
  factory Logger(String prefix) = _LoggingLogger;

  factory Logger.disabled() = _NoOpLogger;

  /// Logs [message].
  void log(String message);

  /// Logs [message] as an error.
  void error(String message);

  /// Changes the log message prefix used by this logger
  set prefix(String value);
}

class _LoggingLogger implements Logger {
  static bool _isConfigured = false;
  l.Logger _logger;

  _LoggingLogger._(String prefix) : _logger = new l.Logger(prefix);

  factory _LoggingLogger(String prefix) {
    if (!_isConfigured) {
      _isConfigured = true;
      l.Logger.root.level = l.Level.ALL;
      l.Logger.root.onRecord.listen((l.LogRecord record) {
        if (record.level >= l.Logger.root.level) {
          if (record.level >= l.Level.WARNING) {
            stderr.writeln(record.message);
          } else {
            stdout.writeln(record.message);
          }
        }
      });
    }
    return new _LoggingLogger._(prefix);
  }

  @override
  void log(String message) {
    _logger.info(message);
  }

  @override
  void error(String message) {
    _logger.severe(message);
  }

  @override
  set prefix(String value) {
    _logger = new l.Logger(value);
  }
}

class _NoOpLogger implements Logger {
  @override
  void error(String message) {}

  @override
  void log(String message) {}

  @override
  set prefix(String value) {}
}
