import 'dart:async';

import 'package:distributed/src/port_daemon/http_server.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.objects/objects.dart';

class PortDaemon {
  final NodeDatabase _nodeDatabase;
  final PortDaemonHttpServer _httpServer;
  final Logger _logger;

  static Future<PortDaemon> spawn(Logger logger) async {
    var db = new NodeDatabase();
    var httpServer = await PortDaemonHttpServer.bind(
      HostMachine.localHost.address,
      HostMachine.localHost.daemonPort,
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

  /// Stops listening for new connections.
  void stop() {
    _httpServer.stop();
  }
}
