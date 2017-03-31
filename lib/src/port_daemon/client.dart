import 'dart:async';

import 'package:distributed/src/port_daemon/client_api.dart' as api;
import 'package:distributed/src/port_daemon/port_daemon.dart';

/// A wrapper for the [PortDaemon] client api.
class PortDaemonClient {
  final String daemonUrl;

  PortDaemonClient(this.daemonUrl);

  Future<bool> pingDaemon([String nodeName = '']) =>
      api.pingDaemon(daemonUrl, nodeName);

  Future<String> getNodeUrl(String nodeName) =>
      api.getNodeUrl(daemonUrl, nodeName);

  Future<String> getNodeServer(String nodeName) =>
      api.getNodeServer(daemonUrl, nodeName);

  Future<int> registerNode(String nodeName) =>
      api.registerNode(daemonUrl, nodeName);

  Future<int> registerRIServer(String nodeName) =>
      api.registerRIServer(daemonUrl, nodeName);

  Future<bool> deregisterNode(String nodeName) =>
      api.deregisterNode(daemonUrl, nodeName);
}
