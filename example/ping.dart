import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';

Future main() async {
  configureDistributed();
  var node = await Node.spawn(ping.name);

  await node.connect(pong).then((result) {
    if (result.error.isNotEmpty) {
      print("(${result.error}. Waiting for connection...");
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
