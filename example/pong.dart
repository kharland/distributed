import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/platform/vm.dart';

import 'example_helper.dart';

Future main() async {
  configureDistributed();
  var node = await Node.spawn(pong.name);

  await node.connect(ping).then((connected) {
    if (!connected) {
      print("Waiting for connection...");
    }
  });

  node.receive('ping').listen((Message message) {
    int count = int.parse(message.contents);
    new Future.delayed(pingPongDelay, () {
      node.send(ping, 'pong', '${++count}');
    });
  });
}
