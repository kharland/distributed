import 'package:distributed.node/interfaces/peer.dart';
import 'package:distributed.node/src/configuration.dart';
import 'package:distributed.node/src/io/node.dart';
import 'package:distributed.port_daemon/client.dart';

void configureDistributed() {
  setNodeProvider(new _IONodeProvider());
  // TODO: replace websocketchannel with seltzer and init seltzer here.
}

class _IONodeProvider implements NodeProvider {
  @override
  IONode create(
    String name, {
    String hostname,
    String cookie,
    int port: 9095,
    bool isHidden: false,
    DaemonClient daemonClient,
  }) =>
      new IONode(
          name: name,
          hostname: hostname,
          port: port,
          cookie: cookie,
          isHidden: isHidden,
          daemonClient: daemonClient);

  @override
  IONode createFromPeer(Peer peer, {String cookie: ''}) =>
      new IONode.fromPeer(peer, cookie: cookie);
}
