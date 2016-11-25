import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/io/node.dart';
import 'package:seltzer/platform/server.dart';

void configureDistributed() {
  useSeltzerInTheServer();
  setNodeProvider(new _IONodeProvider());
}

class _IONodeProvider implements NodeProvider {
  @override
  IONode create(String name, String hostname, String cookie,
          {int port: 9095, bool isHidden: false}) =>
      new IONode(
          name: name,
          hostname: hostname,
          port: port,
          cookie: cookie,
          isHidden: isHidden);

  @override
  IONode createFromPeer(Peer peer, {String cookie: ''}) =>
      new IONode.fromPeer(peer, cookie: cookie);
}
