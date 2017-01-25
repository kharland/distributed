import 'dart:async';

import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.node/testing/test_channels_connection.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:test/test.dart';

import 'src/connection_strategy_test.dart' as connection_strategy_test;

_TestNodeFinder testNodeFinder;
int peerPort = 0;

void main() {
  group('$SearchForNode', () {
    Future<ConnectionStrategy<String>> setup() async {
      testNodeFinder = new _TestNodeFinder();
      peerPort = 0;
      return new SearchForNode<String>(
          testNodeFinder, new TestConnectionChannelsProvider());
    }

    connection_strategy_test.main(
        setup: setup,
        teardown: () => new Future.value(),
        addPeersToNetwork: addPeersToNetwork);
  });
}

Future addPeersToNetwork(List<Peer> peers) async {
  peers.forEach((peer) {
    testNodeFinder.addNodeInfo(peer.name, peer.address, peerPort++);
  });
}

class _TestNodeFinder implements NodeFinder {
  final Map<String, _NodeInfo> _nodeInfoCache = <String, _NodeInfo>{};

  void addNodeInfo(String name, String address, int port) {
    _nodeInfoCache[name] = new _NodeInfo(address, port);
  }

  @override
  Future<String> findNodeAddress(String nodeName) =>
      new Future<String>.value(_nodeInfoCache[nodeName]?.address ?? '');

  @override
  Future<int> findNodePort(String nodeName) => new Future<int>.value(
      _nodeInfoCache[nodeName]?.port ?? Ports.invalidPort.toInt());
}

class _NodeInfo {
  final String address;
  final int port;

  const _NodeInfo(this.address, this.port);
}
