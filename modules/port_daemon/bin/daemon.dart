import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';

import '../lib/daemon.dart';
import '../lib/src/http_server.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  var cookie = argResults['cookie'];

  var server = new DaemonServer(
    new Daemon(new NodeDatabase(new File('.node.db'))),
    port: port,
    cookie: cookie,
  );

  // spawn daemon
  server.start();
  String url = DaemonServer.url(server.hostname, server.port);
  print("Daemon listening at $url");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: DaemonServer.defaultPort.toString())
      ..addOption('cookie', defaultsTo: DaemonServer.defaultCookie))
    .parse(args);
