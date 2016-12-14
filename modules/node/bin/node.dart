import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/io.dart';
import 'package:distributed.port_mapping_daemon/daemon.dart';
import 'package:distributed.port_mapping_daemon/client.dart';

Future main(List<String> args) async {
  configureDistributed();

  var argResults = _parseArgs(args);
  var nodeName = args.first;

  DaemonClient daemonClient;
  var daemonInfo = new DaemonHandle(
    PortMappingDaemon.defaultHost,
    PortMappingDaemon.defaultPort,
    PortMappingDaemon.defaultCookie,
  );

  if (!await DaemonClient.isDaemonRunning(daemonInfo)) {
    print('No PortMappingDaemon detected. Starting new daemon...');
    var daemonProcess = await DaemonClient.spawnDaemon(daemonInfo);
    if (daemonProcess.pid > 0) {
      print('Port mapping daemon is listening at ${daemonInfo.url}');
      print('Kill it with `kill ${daemonProcess.pid}`');
    }
  }

  daemonClient = await DaemonClient.connect(daemonInfo);
  var registrationResult = await daemonClient.registerNode(nodeName);
  if (registrationResult.failed) {
    stderr.writeln('Unable to register node $nodeName');
    exit(0);
  } else {
    print('Registered $nodeName with daemon at ${daemonInfo.url}');
  }

  new Node(
    registrationResult.name,
    'localhost',
    argResults['cookie'],
    port: registrationResult.port,
  );
}

ArgResults _parseArgs(List<String> args) =>
    (new ArgParser()..addOption('cookie', defaultsTo: Node.defaultCookie))
        .parse(args);
