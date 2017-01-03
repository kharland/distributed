import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/io.dart';
import 'package:distributed.port_daemon/client.dart';
import 'package:distributed.port_daemon/src/http_server.dart';
import 'package:fixnum/fixnum.dart';
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

  if (!await daemonClient.pingDaemon(nodeName)) {
    print('No port mapping daemon detected. Start the daemon and try again.');
    exit(0);
  }

  Int64 port;
  await daemonClient.deregisterNode(nodeName);
  if ((port = await daemonClient.lookupNode(nodeName)) < 0) {
    if ((port = await daemonClient.registerNode(nodeName)) < 0) {
      print('Unable to register node $nodeName');
      exit(0);
    }
  }
  print('$nodeName registered to port $port with daemon at $serverUrl');

  var node = new Node(
    nodeName,
    hostname: 'localhost',
    port: port.toInt(),
    cookie: argResults['cookie'],
    daemonClient: daemonClient,
  );

  ProcessSignal.SIGINT.watch().listen((_) async {
    print("Received ${ProcessSignal.SIGINT}. Shutting down node...");
    await node.shutdown();
    exit(0);
  });

  print('$nodeName listening at ${node.url}');
}

void usage() {
  print("Usage: <todo>");
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('name', defaultsTo: '')
      ..addOption('cookie', defaultsTo: Node.defaultCookie))
    .parse(args);
