import 'dart:async';

import 'dart:io' hide Socket;
import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.monitoring/file_system.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.node/src/node/cross_platform_node.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:meta/meta.dart';

Logger createNodeFileLogger(String nodeName) {
  OperatingSystem os;
  if (Platform.isWindows) {
    os = OperatingSystem.windows;
  } else if (Platform.isLinux) {
    os = OperatingSystem.linux;
  } else if (Platform.isMacOS) {
    os = OperatingSystem.macOS;
  } else {
    throw new UnsupportedError('The current platform is unsupported');
  }
  var fileSystem =
      new FileSystem(FileSystem.homeDirectory(os, Platform.environment));
  return new Logger.file(fileSystem.getNodeLog(nodeName));
}

/// A node that runs on the Dart VM.
class VmNode extends DelegatingNode {
  final PortDaemonClient _daemonClient;
  final SocketServer _server;

  static Future<VmNode> spawn({
    @required String name,
    Logger logger,
    HostMachine hostMachine,
  }) async {
    hostMachine ??= $hostMachine('localhost', Ports.defaultDaemonPort);
    logger ??= new Logger(name);

    var daemonClient = new PortDaemonClient(
        name: name, daemonHostMachine: hostMachine, logger: logger);
    int port = await daemonClient.register();
    if (port == Ports.error) {
      throw new Exception('Failed to register node');
    }

    var socketServer = await SocketServer.bind(hostMachine.address, port);
    var delegate = new CrossPlatformNode(
        hostMachine: hostMachine, name: name, logger: logger);

    var incomingConnector = new OneShotConnector();
    socketServer.onSocket.forEach((Socket socket) async {
      final connectionResult =
          await incomingConnector.receiveSocket(delegate.toPeer(), socket);
      delegate.addConnection(
          connectionResult.connection, connectionResult.sender);
    });

    return new VmNode(daemonClient, socketServer, delegate, logger);
  }

  VmNode(this._daemonClient, this._server, Node delegate, Logger logger)
      : super(delegate) {
    logger.log('Registered $name at ${hostMachine.daemonUrl}');
  }

  @override
  Future shutdown() async {
    await super.shutdown();
    await _server.close(force: true);
    await _daemonClient.deregister();
  }
}
