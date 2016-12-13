import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed/distributed.dart';
import 'package:distributed/platform/io.dart';
import 'package:distributed/src/port_mapping_daemon/daemon.dart';
import 'package:distributed/src/port_mapping_daemon/handle.dart';
import 'package:distributed/src/port_mapping_daemon/info.dart';

Future main(List<String> args) async {
  configureDistributed();

  DaemonHandle localDaemon;
  var argResults = _parseArgs(args);
  var nodeName = args.first;
  var localDaemonInfo = new DaemonInfo(
    PortMappingDaemon.defaultHost,
    PortMappingDaemon.defaultPort,
    PortMappingDaemon.defaultCookie,
  );

  if (!await DaemonHandle.isDaemonRunning(localDaemonInfo)) {
    print('No PortMappingDaemon detected. Starting new daemon...');
    var daemonProcess = await DaemonHandle.spawnDaemon(localDaemonInfo);
    if (daemonProcess.pid > 0) {
      print('Port mapping daemon is running at ${localDaemonInfo.url}');
      print('Kill it with `kill ${daemonProcess.pid}`');
    }
  }

  localDaemon = await DaemonHandle.connect(localDaemonInfo);
  var registrationResult = await localDaemon.registerNode(nodeName);
  if (registrationResult.failed) {
    stderr.writeln('Unable to register node $nodeName');
    exit(0);
  } else {
    print('Registered $nodeName with daemon at ${localDaemonInfo.url}');
  }

  new Node(
    registrationResult.name,
    'localhost',
    argResults['node-cookie'],
    port: registrationResult.port,
  );
}

ArgResults _parseArgs(List<String> args) =>
    (new ArgParser()..addOption('cookie', defaultsTo: Node.defaultCookie))
        .parse(args);
