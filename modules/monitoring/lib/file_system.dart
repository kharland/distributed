/// Methods for working with the file system.abstract

import 'dart:io';
import 'package:quiver/time.dart';

enum OperatingSystem {
  windows,
  macOS,
  linux,
}

/// A helper class to make logging easier.
class FileSystem {
  final String root;
  final Clock _clock;

  /// The path the current user's home directory.
  static String homeDirectory(OperatingSystem os, Map<String, String> env) {
    switch (os) {
      case OperatingSystem.windows:
        return env['USERPROFILE'];
      case OperatingSystem.macOS:
      case OperatingSystem.linux:
        return env['HOME'];
      default:
        throw new UnsupportedError('$os');
    }
  }

  FileSystem(this.root, [Clock clock]) : _clock = clock ?? new Clock();

  /// Returns a [File] representing [node]'s log.
  ///
  /// The file may not exist.  It is up to the client to perform this check.
  File getNodeLog(String node) => new File('$_logPath/$node.$_time.log');

  /// Returns a [File] representing the current host machine's port daemon log.
  ///
  /// The file may not exist. It is up to the client to perform this check.
  File getDaemonLog() => new File('$_logPath/port_daemon.$_time.log');

  String get _logPath => '$root/logs';

  String get _time => _clock.now().toString();
}
