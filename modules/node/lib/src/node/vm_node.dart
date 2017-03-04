import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.node/src/node/cross_platform_node.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:meta/meta.dart';

/// A node that runs on the Dart VM.
class VmNode extends DelegatingNode {
  final PortDaemonClient _daemonClient;
  final SocketServer _server;

  static Future<VmNode> spawn({
    @required String name,
    HostMachine hostMachine,
    PeerConnector incomingConnector,
  }) async {
    hostMachine ??= createHostMachine(
      'localhost',
      Ports.defaultDaemonPort,
    );

    var daemonClient = new PortDaemonClient(daemonHostMachine: hostMachine);
    int port = await daemonClient.register(name);
    if (port == Ports.error) {
      throw new Exception('Failed to register node');
    }

    var socketServer = await SocketServer.bind(hostMachine.address, port);
    var delegate = new CrossPlatformNode(hostMachine: hostMachine, name: name);

    incomingConnector ??= new OneShotConnector();
    socketServer.onSocket.forEach((Socket socket) async {
      final connectionResult =
          await incomingConnector.receiveSocket(delegate.toPeer(), socket);
      delegate.addConnection(
          connectionResult.connection, connectionResult.sender);
    });

    return new VmNode(daemonClient, socketServer, delegate);
  }

  VmNode(this._daemonClient, this._server, Node delegate) : super(delegate) {
    globalLogger.log('Registered $name at ${hostMachine.daemonUrl}');
  }

  @override
  Future shutdown() async {
    await super.shutdown();
    await _server.close(force: true);
    await _daemonClient.deregister(name);
  }
}
