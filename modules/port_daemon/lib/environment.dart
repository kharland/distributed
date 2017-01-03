import 'dart:io';
import 'package:logging/logging.dart';

void configureLogging({bool testing: false}) {
  Logger.root.level = testing ? Level.SEVERE : Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) {
    if (record.level > Logger.root.level) {
      if (record.level >= Level.WARNING) {
        stderr.writeln(record.message);
      } else {
        stdout.writeln(record.message);
      }
    }
  });
}
