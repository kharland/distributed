import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/node/cross_platform_node.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:meta/meta.dart';

void configureDistributed() {
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Future<Node> spawn(String name, {@required Logger logger}) async {
    final hostMachine = HostMachine.localHost;
    final daemonClient = new PortDaemonClient(
      name: name,
      daemonHost: hostMachine,
    );

    final port = await daemonClient.register();
    if (port == Ports.error) {
      throw new Exception('Failed to register node');
    } else {
      logger.log('Registered $name at ${hostMachine.portDaemonUrl}');
    }

    var asPeer = new Peer(name, hostMachine);
    return new CrossPlatformNode.fromPeer(
      asPeer,
      logger: logger,
      connectionManager: await VmConnectionManager.bind(
        hostMachine.address,
        port,
        peerVerifier: new PeerVerifier(asPeer),
        logger: logger,
      ),
    )
      ..onShutdown.then((_) async {
        daemonClient.deregister();
      });
  }
}
