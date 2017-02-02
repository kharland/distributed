import 'dart:async';

import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

typedef NodeFinder NodeFinderFactory();

void main({
  Future<NodeFinder> setup([List<String> findablePeerNames]),
  Future teardown(),
  Future<Map<String, Int64>> registerNodes(Set<String> nodeNames),
}) {
  NodeFinder finder;

  tearDown(() async => teardown());

  group('findNodeUrl', () {
    test('should return the address for an existing node', () async {
      var peerName = 'registered';
      finder = await setup([peerName]);
      expect((await finder.findNodeAddress(peerName)).address, isNotEmpty);
    });

    test("should return the empty string if the node doesn't exist", () async {
      finder = await setup();
      expect(await finder.findNodeAddress('unregistered'), isNull);
    });
  });

  group('findNodePort', () {
    test('should return the port an existing node', () async {
      finder = await setup(['registered']);
      expect(await finder.findNodePort('registered'), greaterThan(-1));
    });

    test("should return ${Ports.invalidPort} if the node doesn't exist",
        () async {
      expect(
          await finder.findNodePort('unregistered'), Ports.invalidPort.toInt());
    });
  });
}
