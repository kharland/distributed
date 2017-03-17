import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/platform/vm.dart';

import 'example_helper.dart';
import 'package:distributed.objects/objects.dart';

Future main(List<String> args, [String message]) async {
  var node = await VmNode.spawn(name: pong.name, logger: new Logger('pong'));
  var pongCounter = 0;

  node
    ..connect(ping)
    ..receive('ping').listen((Message message) {
      print('received ping ${message.payload}');
      new Future.delayed(pingDuration, () {
        node.send(ping, 'pong', '${++pongCounter}');
      });
    })
    ..onConnect.first.then((Peer peer) {
      print('Connected to ${peer.displayName}');
    });
}
