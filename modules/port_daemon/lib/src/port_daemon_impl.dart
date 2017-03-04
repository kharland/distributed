import 'dart:async';

import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/node_database.dart';
import 'package:distributed.port_daemon/src/web_server.dart';

class PortDaemonImpl implements PortDaemon {
  final NodeDatabase _nodeDatabase;
  final WebServer _webServer;

  PortDaemonImpl(this._nodeDatabase, this._webServer);

  @override
  Future deregisterNode(String nodeName) =>
      _nodeDatabase.deregisterNode(nodeName);

  @override
  Future<int> getPort(String nodeName) => _nodeDatabase.getPort(nodeName);

  @override
  void keepAlive(String nodeName) => _nodeDatabase.keepAlive(nodeName);

  @override
  Set<String> get nodes => _nodeDatabase.nodes;

  @override
  Future<int> registerNode(String nodeName) =>
      _nodeDatabase.registerNode(nodeName);

  @override
  void stop() {
    _webServer.stop();
  }

  @override
  String get url => _webServer.url;
}
