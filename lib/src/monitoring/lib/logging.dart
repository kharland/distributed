import 'dart:io';

abstract class Logger {
  factory Logger(String prefix) = _ShellLogger;

  factory Logger.file(File file) = _FileLogger;

  factory Logger.disabled() = _NoOpLogger;

  /// Logs [message].
  void log(String message);

  /// Logs [message] as an error.
  void error(String message);
}

class _FileLogger implements Logger {
  final File _file;

  _FileLogger(this._file);

  @override
  void error(String message) {
    _file.writeAsStringSync(message);
  }

  @override
  void log(String message) {
    _file.writeAsStringSync(message);
  }
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
}

class _NoOpLogger implements Logger {
  @override
  void error(String message) {}

  @override
  void log(String message) {}
}
