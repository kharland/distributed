import 'package:distributed.node/interfaces/node.dart';
import 'package:distributed.node/interfaces/peer.dart';
import 'package:distributed.port_daemon/client.dart';

abstract class NodeProvider {
  Node create(
    String name, {
    String hostname,
    String cookie,
    int port,
    bool isHidden,
    DaemonClient daemonClient,
  });
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
