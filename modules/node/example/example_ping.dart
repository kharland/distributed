import 'dart:async';

import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';
import '../../monitoring/lib/logging.dart';

Future main(List<String> args) async {
  enableLogging = false;
  var node = await VmNode.spawn(name: ping.name);
  var pingCounter = 0;

  void _ping() {
    node.send(pong, 'ping', '${++pingCounter}');
  }

  node
    ..connect(pong).then((result) {
      if (result.error.isNotEmpty) {
        print("(${result.error}. Waiting for connection...");
      }
    })
    ..receive('pong').listen((Message message) {
      print('received pong ${message.payload}');
      new Future.delayed(pingDuration, _ping);
    })
    ..onConnect.listen((Peer peer) {
      print('Connected to ${peer.displayName}');
      _ping();
    });
}
