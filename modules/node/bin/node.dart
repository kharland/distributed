import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/io.dart';
import 'package:distributed.port_mapping_daemon/src/http_client.dart';
import 'package:distributed.port_mapping_daemon/src/http_server.dart';
import 'package:seltzer/platform/vm.dart';

Future main(List<String> args) async {
  configureDistributed();

  var argResults = _parseArgs(args);
  var daemonClient = new DaemonClient(
    new VmSeltzerHttp(),
    cookie: argResults['cookie'],
  );
  var serverUrl = DaemonServer.url(daemonClient.hostname, daemonClient.port);

  var nodeName = args.first;
  if (nodeName.isEmpty) {
    usage();
    exit(0);
  }

  if (!await daemonClient.isDaemonRunning()) {
    print('No port mapping daemon detected. Start the daemon and try again.');
    exit(0);
  }

  int port;
  if ((port = await daemonClient.lookupNode(nodeName)) < 0) {
    if ((port = await daemonClient.registerNode(nodeName)) < 0) {
      print('Unable to register node $nodeName');
      exit(0);
    }
  }

  print('Node $nodeName registered with port mapping daemon at $serverUrl');

  new Node(
    nodeName,
    hostname: 'localhost',
    port: port,
    cookie: argResults['cookie'],
  );
}

void usage() {
  print("Usage: <todo>");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('name', defaultsTo: '')
      ..addOption('cookie', defaultsTo: Node.defaultCookie))
    .parse(args);
