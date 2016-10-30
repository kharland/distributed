import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/platform/io.dart';

Peer greeter = new Peer('greeter', 'localhost', port: 8081);
Peer greetee = new Peer('greetee', 'localhost', port: 8082);

Future main(List<String> args) async {
  configureDistributed();

  void usage() {
    print('Usage: dart io_node_demo.dart [${greeter.name}|${greetee.name}]');
  }

  if (args.isEmpty) {
    usage();
  } else {
    if (args.first == greeter.name) {
      greeterNode();
    } else if (args.first == greetee.name) {
      greeteeNode();
    } else {
      usage();
    }
  }
}

Future greeterNode() async {
  var node = await createNode(greeter.name, greeter.hostname, 'cookie',
      port: greeter.port);

  node.receive('greet').listen((Message message) {
    print("Saying Hello! to ${message.sender}");
    node.send(message.sender, 'greetings', 'Hello!');
  });
}

Future greeteeNode() async {
  var node = await createNode(greetee.name, greetee.hostname, 'cookie',
      port: greetee.port);

  node.receive('greetings').listen((Message message) {
    print("${message.sender} says: '${message.data}'");
  });

  node.connectTo(greeter);
  await node.onConnect.first;
  node.send(greeter, 'greet', '');
}
