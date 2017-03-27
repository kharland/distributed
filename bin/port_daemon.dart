import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';

Future main(List<String> args) async {
  await PortDaemon.spawn(new Logger('port_daemon'));
}
