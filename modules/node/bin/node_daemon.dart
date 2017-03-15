import 'dart:async';
import 'dart:isolate';

import 'package:distributed.node/platform/vm.dart';
import 'package:resource/resource.dart';

/// A daemon for orchestrating user-interaction with nodes on this host machine.
Future main() async {
  var debugPort = new ReceivePort()..listen(print);

  var node = await VmNode.spawn(
      name: 'creator', logger: createNodeFileLogger('creator'));

  node.receive('spawn').forEach((Message message) async {
    SpawnRequest request = deserialize(message.payload, SpawnRequest);
    var uri = await Isolate.resolvePackageUri(new Resource(request.uri).uri);
    var isolate = await spawnNode(request.nodeName, uri);
    isolate.addErrorListener(debugPort.sendPort);
    isolate.addOnExitListener(debugPort.sendPort);
    print("Spawned node ${request.nodeName}");
    node.send(message.sender, 'spawned', "Spawned node ${request.nodeName}");
  });

  node.receive('kill').forEach((Message message) async {
//    KillRequest request = deserialize(message.payload, KillRequest);
  });

  print("Daemon running...");
}

Future<Isolate> spawnNode(
  String name,
  Uri uri, {
  List<String> args: const [],
  String message: '',
}) async {
  var isolate = await Isolate.spawnUri(uri, args, message, checked: true);
  var errPort = new ReceivePort();
  var exitPort = new ReceivePort();
  isolate.addErrorListener(errPort.sendPort);
  isolate.addOnExitListener(exitPort.sendPort);
  errPort.forEach((msg) {
    print('ERROR: $msg');
  });
  exitPort.forEach((msg) {
    print('EXIT : $msg');
  });
  return isolate;
}
