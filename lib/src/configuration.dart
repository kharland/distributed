import 'dart:async';

import 'package:distributed/interfaces/node.dart';

abstract class NodeProvider {
  /// Creates a new [Node] identified by [name] and [hostname].
  Future<Node> create(String name, String hostname, String cookie,
      {int port, bool hidden});
}

NodeProvider _nodeProvider;

void setNodeProvider(NodeProvider nodeProvider) {
  if (_nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  _nodeProvider = nodeProvider;
}

Future<Node> createNode(String name, String hostname, String cookie,
        {int port, bool hidden}) =>
    _nodeProvider.create(name, hostname, cookie, port: port, hidden: hidden);
