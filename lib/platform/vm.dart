import 'dart:async';

import 'package:distributed/distributed.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/node/cross_platform_node.dart';
import 'package:distributed/src/node/remote_control/control_server.dart';
import 'package:distributed/src/node/remote_control/node_command.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.http/environment/vm_prod.dart' as http_vm_prod;
import 'package:distributed.http/environment/vm_testing.dart' as http_testing;

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
    var subs = <StreamSubscription>[];

    final asPeer = new Peer(name, HostMachine.localHost);

    var connectionManager = await VmConnectionManager.bind(
      HostMachine.localHost.address,
      await Ports.getUnusedPort(),
      peerVerifier: new PeerVerifier(asPeer, logger),
      logger: logger,
    );

    var controlServer = await ControlServer.bind(
      HostMachine.localHost.address,
      await Ports.getUnusedPort(),
    );

    var node = new CrossPlatformNode.fromPeer(
      asPeer,
      logger: logger,
      connectionManager: connectionManager,
    );

    subs.add(controlServer.commands.listen((NodeCommand cmd) {
      cmd.execute(node);
    }));

    node.onShutdown.then((_) {
      controlServer?.close();
      subs.forEach((s) => s.cancel());
    });

    return node;
  }
}
