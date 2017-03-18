import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';

Future main(List<String> args, [String message]) async {
  configureDistributed();
  var node = await Node.spawn(pong.name);

  await node.connect(ping).then((result) {
    if (result.error.isNotEmpty) {
      print("(${result.error}. Waiting for connection...");
    }
  });

  node.receive('ping').listen((Message message) {
    int count = int.parse(message.contents);
    new Future.delayed(pingPongDelay, () {
      node.send(ping, 'pong', '${++count}');
    });
  });
}
