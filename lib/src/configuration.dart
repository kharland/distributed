import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/node/node.dart';

/// A provider of [Node] instances.
abstract class NodeProvider {
  /// Spawns a [Node] on the local host machine.
  ///
  /// [name] is the name of the node. [logger] is the [Logger] the [Node] will
  /// use.  If [supportRemoteInteraction] is true, the node may be interacted
  /// with remotely via the node server api; The default is false.
  Future<Node> spawn(
    String name,
    Logger logger, {
    bool supportRemoteInteraction: false,
  });
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
