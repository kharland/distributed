import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/node/cross_platform_node.dart';
import 'package:distributed.node/src/connection/connection_controller.dart';

import 'src/node_test.dart' as node_test;

TestConnectionStrategy testConnectionStrategy;

Future setup() async {
  testConnectionStrategy = new TestConnectionStrategy();
}

Future teardown() async {}

Node createNode(
  String name, {
  Secret secret: Secret.acceptAny,
  bool isHidden: false,
}) {
  var node = new CrossPlatformNode(
    name,
    isHidden: isHidden,
    connectionStrategy: testConnectionStrategy,
  );

  testConnectionStrategy.registerNode(node);
  return node;
}

class TestConnectionStrategy implements ConnectionStrategy {
  final Map<String, Node> _nodeNameToConnection = <String, Node>{};

  @override
  Stream<Connection> connect(String localPeerName, String foreignPeerName) {
    assert(_nodeNameToConnection.containsKey(foreignPeerName));
    var localNode = _nodeNameToConnection[localPeerName];
    var foreignNode = _nodeNameToConnection[foreignPeerName];
    var connectionController = new ConnectionController(
      localNode.toPeer(),
      foreignNode.toPeer(),
    );
    foreignNode.addConnection(connectionController.foreign);

    return new Future(() => connectionController.foreign).asStream()
        as Stream<Connection>;
  }

  void registerNode(Node node) {
    _nodeNameToConnection[node.name] = node;
  }
}

void main() {
  node_test.main(setup: setup, teardown: teardown, createNode: createNode);
}
