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
  void log(message);

  /// Logs [error] as an error.
  void error(error);

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
  void log(message) {
    stdout.writeln('[$prefix] $message');
  }

  @override
  void error(error) {
    stderr.writeln('[$prefix] $error');
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
  void error(error) {}

  @override
  void log(message) {}

  @override
  void popPrefix() {}

  @override
  void pushPrefix(String newPrefix) {}
}
