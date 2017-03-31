import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/port_daemon/http_server.dart';
import 'package:distributed/src/port_daemon/node_database.dart';
import 'package:distributed/src/port_daemon/web_server.dart';

class PortDaemon {
  final NodeDatabase _nodeDatabase;
  final WebServer _webServer;
  final Logger _logger;

  static Future<PortDaemon> spawn(Logger logger) async {
    var nodeDatabase = new NodeDatabase();
    var webServer = await ExpressServer.start(
      hostMachine: HostMachine.localHost,
      nodeDatabase: nodeDatabase,
      logger: logger,
    );
    return new PortDaemon._(nodeDatabase, webServer, logger);
  }

  String get url => _webServer.url;

  PortDaemon._(this._nodeDatabase, this._webServer, this._logger) {
    _nodeDatabase.onDeregistered.forEach((String name) {
      _logger.log('Deregistered $name');
    });
  }

  /// Stops listening for new connections.
  void stop() {
    _webServer.stop();
  }
}
