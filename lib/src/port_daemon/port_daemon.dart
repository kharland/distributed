import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/http_server.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/ports.dart';

class PortDaemon {
  final NodeDatabase _nodeDatabase;
  final PortDaemonHttpServer _httpServer;
  final Logger _logger;

  static Future<PortDaemon> spawn(Logger logger) async {
    var db = new NodeDatabase();
    var httpServer = await PortDaemonHttpServer.start(
      hostMachine: HostMachine.localHost,
      db: db,
      logger: logger,
    );
    return new PortDaemon._(db, httpServer, logger);
  }

  PortDaemon._(this._nodeDatabase, this._httpServer, this._logger) {
    _logger.log("Port daemon listening at ${_httpServer.url}");
    _nodeDatabase.onDeregistered.forEach((String name) {
      _logger.log('Deregistered $name');
    });
  }

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _nodeDatabase.nodes;

  /// The url for connecting to this daemon.
  String get url => _httpServer.url;

  /// Signals to this daemon that [nodeName] is still available.
  void keepAlive(String nodeName) => _nodeDatabase.keepAlive(nodeName);

  /// Stops listening for new connections.
  void stop() {
    _httpServer.stop();
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
