import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/src/http_server.dart';

Future main(List<String> args) async {
  var argResults = _parseArgs(args);
  var port = int.parse(argResults['port']);
  var cookie = argResults['cookie'];

  var server = (new DaemonServerBuilder()
        ..setPort(port)
        ..setCookie(cookie)
        ..setDaemon(new Daemon(new NodeDatabase(new File('.node.db')))))
      .build();

  // spawn daemon
  server.start();
  String url = DaemonServer.url(server.hostname, server.port);
  print("Daemon listening at $url");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('port', defaultsTo: DaemonServer.defaultPort.toString())
      ..addOption('cookie', defaultsTo: DaemonServer.defaultCookie))
    .parse(args);
