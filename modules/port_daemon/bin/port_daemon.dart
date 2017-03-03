import 'dart:async';

import 'package:args/args.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/ports.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  var daemon = new PortDaemon(hostMachine: createHostMachine('localhost', port))
    ..start();

  print("Daemon listening at ${daemon.url}");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: '${Ports.defaultDaemonPort}'))
    .parse(args);
