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
  var node = new Node.fromPeer(greeter, cookie: 'cookie');

  node.receive('greet').listen((Message message) {
    print("Saying Hello! to ${message.sender}");
    node.send(message.sender, 'greetings', 'Hello!');
  });
}

Future greeteeNode() async {
  var node = new Node.fromPeer(greetee, cookie: 'cookie');

  node.receive('greetings').listen((Message message) {
    print("${message.sender} says: '${message.data}'");
  });

  node.connect(greeter);
  await node.onConnect.first;
  node.send(greeter, 'greet', '');
}
