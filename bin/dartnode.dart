import 'dart:async';
import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.port_daemon/ports.dart';

Future main(List<String> args) async {
  String nodeName = args.first;
  String uri = args.last;

  var node = await VmNode.spawn(name: 'cli');
  var nodeDaemon = createPeer(
      'creator', createHostMachine('localhost', Ports.defaultDaemonPort));

  await node.connect(nodeDaemon);

  node.send(
      nodeDaemon,
      'spawn',
      serialize(
          new SpawnRequest((b) => b
            ..nodeName = nodeName
            ..uri = uri),
          SpawnRequest));

  node.receive('spawned').first.then((Message message) {
    print(message.payload);
    node.disconnect(nodeDaemon);
    node.shutdown();
  });
}
