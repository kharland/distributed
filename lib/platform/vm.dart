import 'dart:async';

import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/node/control_server/server.dart';
import 'package:distributed/src/node/cross_platform_node.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/port_daemon/client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.objects/public.dart';
import 'package:meta/meta.dart';

void configureDistributed() {
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Future<Node> spawn(String name, Logger logger) async {
    final hostMachine = HostMachine.localHost;
    final daemonClient = new PortDaemonClient(hostMachine.portDaemonUrl);

    int nodePort;
    int controlServerPort;

    final ports = await daemonClient.registerNode(name);
    if (ports.any((port) => port == Ports.error)) {
      throw new Exception('Failed to register node');
    } else {
      nodePort = ports.first;
      controlServerPort = ports.last;
      logger.log('Registered $name to port $nodePort');
      logger.log('Registered control server to port $controlServerPort');
    }

    final node = await spawnNode(name, hostMachine, nodePort, logger);
    final controlServer =
        await bindControlServer(hostMachine.address, controlServerPort, node);

    logger.log(
        "Server listening at ${controlServer.address.host}:${controlServer.port}");
    node.onShutdown.then((_) {
      controlServer?.close(force: true);
      daemonClient.deregisterNode(name);
    });

    return node;
  }

  @visibleForTesting
  Future<Node> spawnNode(
    String name,
    HostMachine hostMachine,
    int port,
    Logger logger,
  ) async {
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
}
