import 'dart:io';
import 'package:logging/logging.dart';

var logLevelMap = {
  'all': Level.ALL,
  'finest': Level.FINEST,
  'finer': Level.FINER,
  'fine': Level.FINE,
  'config': Level.CONFIG,
  'info': Level.INFO,
  'warning': Level.WARNING,
  'severe': Level.SEVERE,
  'shout': Level.SHOUT,
  'off': Level.OFF
};

bool _runAlready = false;
void _runOnce() {
  if (_runAlready) return;
  _runAlready = true;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

Logger createLogger(String name) {
  _runOnce();
  var specifiedLogLevel = Platform.environment['log'];

  var logger = new Logger(name);
  Logger.root.level = Level.FINEST;

  if (logLevelMap[specifiedLogLevel] == null) {
    logger.warning('Invalid log level $specifiedLogLevel.');
  }
  return logger;
}
