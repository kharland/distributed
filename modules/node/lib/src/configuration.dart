import 'package:distributed.objects/secret.dart';
import 'package:distributed.node/node.dart';

abstract class NodeProvider {
  Node create(
    String name, {
    String hostname,
    Secret secret,
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
