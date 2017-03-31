import 'dart:async';
import 'dart:io';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/node/cross_platform_node.dart';
import 'package:distributed/src/node/remote_interaction/server.dart';
import 'package:distributed/src/port_daemon/client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:meta/meta.dart';

void configureDistributed() {
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Future<Node> spawn(
    String name,
    Logger logger, {
    bool supportRemoteInteraction: false,
  }) async {
    final hostMachine = HostMachine.localHost;
    final daemonClient = new PortDaemonClient(hostMachine.portDaemonUrl);
    final node = await spawnNode(name, logger, daemonClient, hostMachine);

    HttpServer remoteInteractionServer;
    if (supportRemoteInteraction) {
      remoteInteractionServer =
          await spawnServer(node, logger, daemonClient, hostMachine);
    }

    node.onShutdown.then((_) {
      remoteInteractionServer?.close(force: true);
      daemonClient.deregisterNode(name);
    });

    return node;
  }

  @visibleForTesting
  Future<Node> spawnNode(String name, Logger logger,
      PortDaemonClient daemonClient, HostMachine hostMachine) async {
    final port = await daemonClient.registerNode(name);
    if (port == Ports.error) {
      throw new Exception('Failed to register node');
    } else {
      logger.log('Registered $name at ${daemonClient.daemonUrl}');
    }

    final asPeer = new Peer(name, hostMachine);
    return new CrossPlatformNode.fromPeer(asPeer,
        logger: logger,
        connectionManager: await VmConnectionManager.bind(
          hostMachine.address,
          port,
          peerVerifier: new PeerVerifier(asPeer),
          logger: logger,
        ));
  }

  Future<HttpServer> spawnServer(Node node, Logger logger,
      PortDaemonClient daemonClient, HostMachine hostMachine) async {
    final port = await daemonClient.registerRIServer(node.name);
    if (port == Ports.error) {
      throw new Exception('Failed to register node server');
    } else {
      logger.log('Registered server at ${daemonClient.daemonUrl}');
    }
    return await bindServer(hostMachine.address, port, node);
  }
}
