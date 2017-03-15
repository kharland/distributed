import 'dart:async';

import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:distributed.port_daemon/src/express_server.dart';
import 'package:distributed.port_daemon/src/node_database.dart';
import 'package:distributed.port_daemon/src/web_server.dart';

class PortDaemon {
  final NodeDatabase _nodeDatabase;
  final WebServer _webServer;

  static Future<PortDaemon> spawn({HostMachine hostMachine}) async {
    hostMachine ??= $hostMachine('localhost', Ports.defaultDaemonPort);
    var nodeDatabase = new NodeDatabase();
    var webServer = await ExpressServer.start(
      hostMachine: hostMachine,
      nodeDatabase: nodeDatabase,
    );
    return new PortDaemon._(nodeDatabase, webServer);
  }

  PortDaemon._(this._nodeDatabase, this._webServer);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _nodeDatabase.nodes;

  /// The url for connecting to this daemon.
  String get url => _webServer.url;

  /// Signals to this daemon that [nodeName] is still available.
  void keepAlive(String nodeName) => _nodeDatabase.keepAlive(nodeName);

  /// Stops listening for new connections.
  void stop() {
    _webServer.stop();
  }

  /// Assigns a port to a new [nodeName].
  ///
  /// Returns a future that completes with the port number or [Ports.error] if
  /// [nodeName] could not be registered.
  Future<Registration> registerNode(String nodeName) =>
      _nodeDatabase.registerNode(nodeName);

  /// Frees the port held by node [nodeName] and forgets [nodeName] exists.
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String nodeName) =>
      _nodeDatabase.deregisterNode(nodeName);

  /// Returns the port for [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> getPort(String nodeName) => _nodeDatabase.getPort(nodeName);
}
