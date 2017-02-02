import 'dart:async';

import 'dart:io';
import 'package:distributed.port_daemon/daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';

abstract class NodeFinder {
  Future<InternetAddress> findNodeAddress(String nodeName);

  Future<int> findNodePort(String nodeName);
}

class DaemonBasedNodeFinder implements NodeFinder {
  final DaemonClient _client;

  DaemonBasedNodeFinder(this._client);

  @override
  Future<InternetAddress> findNodeAddress(String nodeName) async =>
      await findNodePort(nodeName) == Ports.invalidPort.toInt()
          ? null
          : _client.serverInfo.address;

  @override
  Future<int> findNodePort(String nodeName) =>
      _client.lookupNode(nodeName).then((Int64 port) => port.toInt());
}
