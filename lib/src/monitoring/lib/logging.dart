import 'dart:io';

abstract class Logger {
  String _oldPrefix;

  String get prefix;
  set prefix(String value);

  Logger._(this._oldPrefix) {
    prefix = _oldPrefix;
  }

  factory Logger(String prefix) = _ShellLogger;

  factory Logger.disabled() = _NoOpLogger;

  /// Logs [message].
  void log(String message);

  /// Logs [message] as an error.
  void error(String message);

  void pushPrefix(String newPrefix) {
    _oldPrefix = prefix;
    prefix = '$prefix.$newPrefix';
  }

  void popPrefix() {
    assert(_oldPrefix != null);
    prefix = _oldPrefix;
  }
}

class _ShellLogger extends Logger {
  @override
  String prefix;

  _ShellLogger(this.prefix) : super._(prefix);

  @override
  void log(String message) {
    stdout.writeln('[$prefix] $message');
  }

  @override
  void error(String message) {
    stderr.writeln('[$prefix] $message');
  }

  @override
  void popPrefix() {
    super.popPrefix();
  }

  @override
  void pushPrefix(String newPrefix) {
    super.pushPrefix(newPrefix);
  }
}

class _NoOpLogger extends Logger {
  _NoOpLogger() : super._('');

  @override
  String prefix;

  @override
  void error(String message) {}

  @override
  void log(String message) {}

  @override
  void popPrefix() {}

  @override
  void pushPrefix(String newPrefix) {}
}
