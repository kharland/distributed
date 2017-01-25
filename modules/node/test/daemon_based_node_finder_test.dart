import 'dart:async';

import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.port_daemon/daemon_client.dart';
import 'package:distributed.port_daemon/daemon_server.dart';
import 'package:fixnum/fixnum.dart';

import 'package:test/test.dart';
import 'src/node_finder_test.dart' as node_finder_test;

DaemonServer server;
DaemonClient client;

void main() {
  group('$DaemonBasedNodeFinder', () {
    node_finder_test.main(
      setup: setup,
      teardown: teardown,
      registerNodes: registerNodes,
    );
  });
}

Future<NodeFinder> setup() async {
  client = new DaemonClient('testClient');
  var finder = new DaemonBasedNodeFinder(client);
  server = await (new DaemonServer())..start();
  assert(await client.pingDaemon());
  return finder;
}

Future teardown() async {
  server.clearDatabase();
  server.stop();
}

Future<Map<String, Int64>> registerNodes(Set<String> nodeNames) async {
  var nodeNameToId = <String, Int64>{};
  for (int i = 0; i < nodeNames.length; i++) {
    nodeNameToId[nodeNames.elementAt(i)] =
        await client.registerNode(nodeNames.elementAt(i));
  }
  return nodeNameToId;
}
