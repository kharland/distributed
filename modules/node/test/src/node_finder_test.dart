import 'dart:async';
import 'package:distributed.node/src/node_finder.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

typedef NodeFinder NodeFinderFactory();

void main({
  Future<NodeFinder> setup(),
  Future teardown(),
  Future<Map<String, Int64>> registerNodes(Set<String> nodeNames),
}) {
  NodeFinder finder;

  setUp(() async {
    finder = await setup();
  });

  tearDown(() async => teardown());

  group('findNodeUrl', () {
    test('should return the address for an existing node', () async {
      const peer = const Peer('registered', 'localhost');
      await registerNodes([peer.name].toSet());
      expect(await finder.findNodeAddress(peer.name), peer.address);
    });

    test("should return the empty string if the node doesn't exist", () async {
      expect(await finder.findNodeAddress('unregistered'), isEmpty);
    });
  });

  group('findNodePort', () {
    test('should return the port an existing node', () async {
      const peer = const Peer('registered', 'localhost');
      var peerPort = (await registerNodes([peer.name].toSet()))[peer.name];
      expect(await finder.findNodePort(peer.name), peerPort);
    });

    test("should return ${Ports.invalidPort} if the node doesn't exist",
        () async {
      expect(
          await finder.findNodePort('unregistered'), Ports.invalidPort.toInt());
    });
  });
}
