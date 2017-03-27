import 'dart:async';

import 'package:args/args.dart';
import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/ports.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  await PortDaemon.spawn(port, new Logger('port_daemon'));
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: '${Ports.defaultPortDaemonPort}'))
    .parse(args);
