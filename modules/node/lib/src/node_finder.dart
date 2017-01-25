import 'dart:async';

import 'package:distributed.port_daemon/daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';

abstract class NodeFinder {
  Future<String> findNodeAddress(String nodeName);

  Future<int> findNodePort(String nodeName);
}

class DaemonBasedNodeFinder implements NodeFinder {
  final DaemonClient _client;

  DaemonBasedNodeFinder(this._client);

  @override
  Future<String> findNodeAddress(String nodeName) async =>
      await findNodePort(nodeName) == Ports.invalidPort.toInt()
          ? ''
          : _client.address;

  @override
  Future<int> findNodePort(String nodeName) =>
      _client.lookupNode(nodeName).then((Int64 port) => port.toInt());
}
