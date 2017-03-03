import 'dart:async';

import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';

Future main(List<String> args) async {
  var node = await VmNode.spawn(name: pong.name);
  var pongCounter = 0;

  node
    ..connect(ping)
    ..receive('ping').listen((Message message) {
      print('recieved ping ${message.payload}');
      new Future.delayed(pingDuration, () {
        node.send(ping, 'pong', '${++pongCounter}');
      });
    })
    ..onConnect.first.then((Peer peer) {
      print('Connected to ${peer.displayName}');
    });
}
