import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/io.dart';
import 'package:distributed.port_mapping_daemon/src/daemon_handle.dart';
import 'package:distributed.port_mapping_daemon/src/http_client.dart';
import 'package:path/path.dart';
import 'package:seltzer/platform/vm.dart';

Future main(List<String> args) async {
  configureDistributed();

  var argResults = _parseArgs(args);
  var client =
      new DaemonClient(DaemonServerHandle.Default, new VmSeltzerHttp());

  var nodeName = args.first;
  if (nodeName.isEmpty) {
    usage();
    exit(0);
  }

  if (!await client.isDaemonRunning()) {
    print('No PortMappingDaemon detected. Starting new daemon...');
    var daemonProcess = await spawnDaemon(client);
    if (daemonProcess.pid > 0) {
      var serverUrl = client.serverHandle.serverUrl;
      print('Port mapping daemon is listening at $serverUrl');
      print('Kill it with `kill ${daemonProcess.pid}`');
    }
  }

  int port;
  if ((port = await client.registerNode(nodeName)) < 0) {
    print('Unable to register node $nodeName');
    exit(0);
  } else {
    var serverUrl = client.serverHandle.serverUrl;
    print('Registered $nodeName with daemon at $serverUrl');
  }

  new Node(nodeName, 'localhost', argResults['cookie'], port: port);
}

void usage() {
  print("Usage: <todo>");
}

Future<Process> spawnDaemon(DaemonClient client) async {
  assert(!await client.isDaemonRunning());
  var dart = _findDart();
  if (dart.isEmpty) {
    throw new Exception('Could not find dart.  Make sure it is on your path '
        'and try again.');
  }

  var daemonProcess = await Process.start(
      dart,
      [
        '-c',
        'bin/daemon.dart',
        '--hostname="localhost"',
        '--port=${client.serverHandle.port}',
        '--cookie=${client.serverHandle.cookie}'
      ],
      mode: ProcessStartMode.DETACHED_WITH_STDIO);
  await daemonProcess.stdout.first;

  if (!await client.isDaemonRunning()) {
    throw new StateError("Unable to start daemon");
  }

  return daemonProcess;
}

String _findDart() {
  var envPath = Platform.environment['PATH'];
  var paths = envPath.split(':').where((path) =>
      path.toLowerCase().contains('dart') &&
      path.endsWith('${Platform.pathSeparator}bin'));

  for (String path in paths) {
    path = absolute(path.replaceAll('~', Platform.environment['HOME']));
    var directory = new Directory(path);
    if (!directory.existsSync()) {
      continue;
    }

    var files = directory.listSync();
    var dartVmBinary = files.firstWhere(
        (FileSystemEntity entity) => entity.path.endsWith('dart'),
        orElse: () => null);

    if (dartVmBinary?.existsSync() == true) {
      return dartVmBinary.path;
    }
  }

  return '';
}

ArgResults _parseArgs(List<String> args) => (new ArgParser()
      ..addOption('name', defaultsTo: '')
      ..addOption('cookie', defaultsTo: Node.defaultCookie))
    .parse(args);
