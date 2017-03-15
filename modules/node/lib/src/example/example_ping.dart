import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';

Future main(List<String> args, [String message]) async {
  enableLogging = false;
  var node = await VmNode.spawn(name: ping.name, logger: new Logger('ping'));
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
