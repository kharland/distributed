// TODO: move this to a common package
import 'dart:io';

bool enableLogging = true;

Logger get globalLogger => enableLogging ? _logger : _disabledLogger;

final _logger = new Logger('distributed');
final _disabledLogger = new Logger.disabled();

abstract class Logger {
  factory Logger(String prefix) = _ShellLogger;

  factory Logger.disabled() = _NoOpLogger;

  /// Logs [message].
  void log(String message);

  /// Logs [message] as an error.
  void error(String message);

  /// Changes the log message prefix used by this logger
  set prefix(String value);
}

class _ShellLogger implements Logger {
  String _prefix;

  _ShellLogger(this._prefix);

  @override
  void log(String message) {
    stdout.writeln('[$_prefix] $message');
  }

  @override
  void error(String message) {
    stderr.writeln('[$_prefix] $message');
  }

  @override
  set prefix(String value) {
    _prefix = value;
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
