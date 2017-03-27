import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/node/node.dart';
import 'package:meta/meta.dart';

abstract class NodeProvider {
  Future<Node> spawn(String name, {@required Logger logger});
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
