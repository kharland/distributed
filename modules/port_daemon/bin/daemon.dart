import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'package:distributed.net/secret.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.utils/logging.dart';
import 'package:distributed.port_daemon/daemon_server.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  var secret = new Secret(argResults['secret']);

  configureLogging();

  var server = new DaemonServer.withDaemon(
    new PortDaemon(new NodeDatabase(new File('.node.db'))),
    port: port,
    secret: secret,
  );

  // spawn daemon
  server.start();
  String url = DaemonServer.url(server.hostname, server.port);
  print("Daemon listening at $url");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: DaemonServer.defaultPort.toString())
      ..addOption('secret'))
    .parse(args);
