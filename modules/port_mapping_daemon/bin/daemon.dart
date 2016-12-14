import 'dart:async';
import 'package:args/args.dart';
import 'package:distributed.port_mapping_daemon/daemon.dart';

/// Starts a pmd on the default port.
Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var hostname = argResults['hostname'];
  var port = int.parse(argResults['port']);
  var cookie = argResults['cookie'];

  var daemon =
      new PortMappingDaemon(hostname: hostname, port: port, cookie: cookie);
  await daemon.start();
  print("Daemon listening at ${daemon.url}");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('hostname', defaultsTo: PortMappingDaemon.defaultHost)
      ..addOption('port', defaultsTo: PortMappingDaemon.defaultPort.toString())
      ..addOption('cookie', defaultsTo: PortMappingDaemon.defaultCookie))
    .parse(args);
