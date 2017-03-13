import 'dart:io';
import 'package:distributed.monitoring/file_system.dart';
import 'package:distributed.monitoring/logging.dart';

void main() {}

Logger createLogger(String nodeName) {
  OperatingSystem os;
  if (Platform.isWindows) {
    os = OperatingSystem.windows;
  } else if (Platform.isLinux) {
    os = OperatingSystem.linux;
  } else if (Platform.isMacOS) {
    os = OperatingSystem.macOS;
  } else {
    throw new UnsupportedError('The current platform is unsupported');
  }
  var fileSystem =
      new FileSystem(FileSystem.homeDirectory(os, Platform.environment));
  return new Logger.file(fileSystem.getNodeLog(nodeName));
}
