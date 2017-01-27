import 'dart:async';

import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.port_daemon/daemon_client.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'src/node_finder_test.dart' as node_finder_test;

void main() {
  group('$DaemonBasedNodeFinder', () {
    node_finder_test.main(
      setup: setup,
      teardown: teardown,
    );
  });
}

Future<NodeFinder> setup([List<String> inNetworkPeers = const []]) async =>
    new DaemonBasedNodeFinder(new MockDaemonClient(inNetworkPeers));

Future teardown() async {}

class MockDaemonClient extends Mock implements DaemonClient {
  final List<String> _inNetworkPeers;
  final Map<String, Int64> _peerNameToPort = <String, Int64>{};

  @override
  Int64 port = Int64.ONE;

  MockDaemonClient([this._inNetworkPeers = const []]);

  @override
  String get address => 'localhost';

  @override
  Future<Int64> lookupNode(String nodeName) async {
    if (_inNetworkPeers.contains(nodeName)) {
      return _peerNameToPort.putIfAbsent(nodeName, () => port++);
    } else {
      return Ports.invalidPort;
    }
  }
}
