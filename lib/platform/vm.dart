import 'dart:async';

import 'package:distributed.http/vm.dart';
import 'package:distributed/distributed.dart';
import 'package:distributed.http/environment/vm_testing.dart' as http_testing;
import 'package:distributed.http/environment/vm_prod.dart' as http_vm_prod;
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/node/cross_platform_node.dart';
import 'package:distributed/src/node/remote_interaction/server.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:meta/meta.dart';

void configureDistributed({bool testing: false}) {
  if (testing) {
    http_testing.configureHttp();
  } else {
    http_vm_prod.configureHttp();
  }
  setNodeProvider(new _VmNodeProvider());
}

class _VmNodeProvider implements NodeProvider {
  @override
  Future<Node> spawn(
    String name,
    Logger logger, {
    bool supportRemoteInteraction: false,
  }) async {
    final daemonClient = new PortDaemonClient(
        name, HostMachine.localHost, new Logger('port_daemon_client'));
    final node = await spawnNode(name, logger, daemonClient);

    HttpServer remoteInteractionServer;
    if (supportRemoteInteraction) {
      remoteInteractionServer = await spawnServer(node, logger, daemonClient);
    }

    node.onShutdown.then((_) {
      remoteInteractionServer?.close();
      daemonClient.deregister();
    });

    return node;
  }

  @visibleForTesting
  Future<Node> spawnNode(
      String name, Logger logger, PortDaemonClient daemonClient) async {
    final port = await daemonClient.registerNode();
    if (port == Ports.error) {
      throw new Exception('Failed to register node');
    } else {
      logger
          .log('Registered $name at ${daemonClient.daemonHost.portDaemonUrl}');
    }

    final asPeer = new Peer(name, daemonClient.daemonHost);
    return new CrossPlatformNode.fromPeer(asPeer,
        logger: logger,
        connectionManager: await VmConnectionManager.bind(
          daemonClient.daemonHost.address,
          port,
          peerVerifier: new PeerVerifier(asPeer, logger),
          logger: logger,
        ));
  }

  Future<HttpServer> spawnServer(
      Node node, Logger logger, PortDaemonClient daemonClient) async {
    final port = await daemonClient.registerServer();
    if (port == Ports.error) {
      throw new Exception('Failed to register node server');
    } else {
      logger
          .log('Registered server at ${daemonClient.daemonHost.portDaemonUrl}');
    }
    return await bindServer(daemonClient.daemonHost.address, port, node);
  }
}
