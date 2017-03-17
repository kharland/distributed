import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';

abstract class NodeProvider {
  Future<Node> spawn(String name, {Logger logger});
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
