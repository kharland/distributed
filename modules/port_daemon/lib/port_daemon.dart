import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:distributed.port_daemon/src/express_server.dart';
import 'package:distributed.port_daemon/src/node_database.dart';
import 'package:distributed.port_daemon/src/port_daemon_impl.dart';

abstract class PortDaemon {
  static Future<PortDaemon> spawn({HostMachine hostMachine}) async {
    hostMachine ??= createHostMachine('localhost', Ports.defaultDaemonPort);
    var nodeDatabase = new NodeDatabase(new Logger('node database'));
    var webServer = await ExpressServer.start(
      hostMachine: hostMachine,
      nodeDatabase: nodeDatabase,
    );
    return new PortDaemonImpl(nodeDatabase, webServer);
  }

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes;

  /// The url for connecting to this daemon.
  String get url;

  /// Signals to this daemon that [nodeName] is still available.
  void keepAlive(String nodeName);

  /// Stops listening for new connections.
  void stop();

  /// Assigns a port to a new [nodeName].
  ///
  /// Returns a future that completes with the port number or [Ports.error] if
  /// [nodeName] could not be registered.
  Future<int> registerNode(String nodeName);

  /// Frees the port held by node [nodeName] and forgets [nodeName] exists.
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String nodeName);

  /// Returns the port for [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> getPort(String nodeName);
}
