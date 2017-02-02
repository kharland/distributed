import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import 'package:distributed.net/secret.dart';
import 'package:distributed.port_daemon/src/daemon_server_info.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/src/request_authenticator.dart';
import 'package:distributed.utils/logging.dart';
import 'package:distributed.port_daemon/daemon_server.dart';
import 'package:fixnum/fixnum.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = Int64.parseInt(argResults['port']);
  var secret = new Secret(argResults['secret']);

  configureLogging();

  var server = new DaemonServer(
    portDaemon: new PortDaemon(new NodeDatabase(new File('.node.db'))),
    serverInfo: new DaemonServerInfo(port: port),
    requestAuthenticator: new SecretAuthenticator(secret),
  );

  // spawn daemon
  server.start();
  print("Daemon listening at ${server.url}");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: DaemonServer.defaultPort.toString())
      ..addOption('secret'))
    .parse(args);
