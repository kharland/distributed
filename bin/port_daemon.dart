import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/platform/vm.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';

Future main(List<String> args) async {
  configureDistributed();
  await PortDaemon.spawn(new Logger('port_daemon'));
}
