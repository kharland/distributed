import 'package:distributed.node/node.dart';

abstract class NodeProvider {
  Node create(
    String name, {
    String hostname,
    bool isHidden,
  });
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
