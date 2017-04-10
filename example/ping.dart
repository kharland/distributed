import 'dart:async';

import 'package:distributed.objects/objects.dart';
import 'package:distributed/distributed.dart';
import 'package:distributed/platform/vm.dart';

import 'ping_pong_helper.dart';

Future main() async {
  configureDistributed();
  var node = await Node.spawn(ping.name);

  await node.connect(pong).then((connected) {
    if (!connected) {
      print("Waiting for connection...");
    }
  });

  node.receive('pong').listen((Message message) {
    int count = int.parse(message.contents);
    new Future.delayed(pingPongDelay, () {
      node.send(pong, 'ping', '${++count}');
    });
  });

  node.onConnect.listen((Peer peer) {
    node.send(pong, 'ping', '1');
  });
}
