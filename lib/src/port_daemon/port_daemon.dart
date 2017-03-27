import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed/src/port_daemon/http_server.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/web_server.dart';
import 'package:meta/meta.dart';

class PortDaemon {
  final NodeDatabase _nodeDatabase;
  final WebServer _webServer;
  final Logger _logger;

  static Future<PortDaemon> spawn({
    int port: Ports.defaultPortDaemonPort,
    @required Logger logger,
  }) async {
    var nodeDatabase = new NodeDatabase();
    var webServer = await ExpressServer.start(
      hostMachine: $hostMachine('localhost', port),
      nodeDatabase: nodeDatabase,
      logger: logger,
    );
    return new PortDaemon._(nodeDatabase, webServer, logger);
  }

  PortDaemon._(this._nodeDatabase, this._webServer, this._logger) {
    _nodeDatabase.onDeregistered.forEach((String name) {
      _logger.log('Deregistered $name');
    });
  }

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
  Future<Registration> registerNode(String nodeName) async {
    var registration = await _nodeDatabase.registerNode(nodeName);
    if (registration.port == Ports.error) {
      _logger.log('Failed to register $nodeName');
    } else {
      _logger.log('Registered $nodeName to ${registration.port}');
    }
    return registration;
  }

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
