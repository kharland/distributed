import 'dart:async';

import 'package:args/args.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/ports.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  var daemon =
      await PortDaemon.spawn(hostMachine: createHostMachine('localhost', port));

  print("Daemon listening at ${daemon.url}");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: '${Ports.defaultDaemonPort}'))
    .parse(args);
