import 'package:distributed.node/interfaces/node.dart';
import 'package:distributed.node/interfaces/peer.dart';

abstract class NodeProvider {
  Node create(String name, String hostname, String cookie,
      {int port, bool isHidden});

  Node createFromPeer(Peer peer, {String cookie: ''});
}

NodeProvider nodeProvider;

void setNodeProvider(NodeProvider provider) {
  if (nodeProvider != null) {
    throw new StateError('The platform is already initialized!');
  }
  nodeProvider = provider;
}
