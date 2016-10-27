import 'dart:async';
import 'package:distributed/interfaces/node.dart';

typedef Future<Node> NodeProvider(String name, String hostname, String cookie,
    {int port, bool hidden});

NodeProvider _nodeProvider;

void setNodeProvider(NodeProvider nodeProvider) {
  if (_nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  _nodeProvider = nodeProvider;
}

Future<Node> createNode(String name, String hostname, String cookie,
        {int port, bool hidden}) =>
    _nodeProvider(name, hostname, cookie, port: port, hidden: hidden);
