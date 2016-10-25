import 'dart:async';
import 'dart:io';
import 'package:distributed/src/io/node.dart';
import 'package:distributed/platform/io.dart';
import 'package:test/test.dart';
import 'package:stack_trace/stack_trace.dart';

void main() {
  configureDistributed();

  group('$IONode', () {
    IONode node;

    setUp(() async {
      node = await IONode.create(
          name: 'TestNode',
          hostname: 'localhost',
          port: 8080,
          cookie: 'A',
          isHidden: false);
    });

    tearDown(() => node.shutdown());

//    test('should start listening for connections upon creation', () async {
//      var webSocket = await WebSocket.connect(node.toPeer().url);
//      expect(webSocket.readyState, WebSocket.OPEN);
//      await webSocket.close();
//    });
//
//    test('should reject a connection if the provided cookie does not match',
//        () async {
//      var remoteNode = await IONode.create(
//          name: 'A',
//          hostname: 'localhost',
//          port: node.toPeer().port + 1,
//          cookie: 'different-${node.cookie}',
//          isHidden: false);
//      remoteNode.createConnection(node.toPeer());
//      await remoteNode.onDisconnect.first;
//      expect(remoteNode.peers.contains(node.toPeer()), isFalse);
//      expect(node.peers.contains(remoteNode.toPeer()), isFalse);
//      await remoteNode.shutdown();
//    });
//
//    test('should accept a connection if the provided cookie matches', () async {
//      var remoteNode = await IONode.create(
//          name: 'A',
//          hostname: 'localhost',
//          port: node.toPeer().port + 1,
//          cookie: node.cookie,
//          isHidden: false);
//      Future.wait([remoteNode.onConnect.first, node.onConnect.first])
//          // ignore: strong_mode_down_cast_composite
//          .then(expectAsync((_) async {
//        expect(remoteNode.peers.contains(node.toPeer()), isTrue);
//        expect(node.peers.contains(remoteNode.toPeer()), isTrue);
//        await remoteNode.shutdown();
//      }));
//      remoteNode.createConnection(node.toPeer());
//    });
//
//    test("should connect to a new Peer's peers if it is not hidden", () async {
//      var remoteNodeA = await IONode.create(
//          name: 'A',
//          hostname: 'localhost',
//          port: node.toPeer().port + 1,
//          cookie: node.cookie,
//          isHidden: false);
//      var remoteNodeB = await IONode.create(
//          name: 'B',
//          hostname: 'localhost',
//          port: remoteNodeA.toPeer().port + 1,
//          cookie: node.cookie,
//          isHidden: false);
//      Future.wait([
//        node.onConnect.take(2).last,
//        remoteNodeB.onConnect.take(2).last,
//        remoteNodeA.onConnect.take(2).last,
//        // ignore: strong_mode_down_cast_composite
//      ]).then(expectAsync((_) async {
//        expect(remoteNodeA.peers,
//            unorderedEquals([node.toPeer(), remoteNodeB.toPeer()]));
//        expect(remoteNodeB.peers,
//            unorderedEquals([node.toPeer(), remoteNodeA.toPeer()]));
//        expect(node.peers,
//            unorderedEquals([remoteNodeA.toPeer(), remoteNodeB.toPeer()]));
//        await remoteNodeA.shutdown();
//        await remoteNodeB.shutdown();
//      }, count: 1));
//      await remoteNodeA.createConnection(node.toPeer());
//      await remoteNodeB.createConnection(remoteNodeA.toPeer());
//    });
//
//    test("should not connect to a new Peer's peers if it is not hidden",
//        () async {
//      var remoteNodeA = await IONode.create(
//          name: 'A',
//          hostname: 'localhost',
//          port: node.toPeer().port + 1,
//          cookie: node.cookie,
//          isHidden: true);
//      var remoteNodeB = await IONode.create(
//          name: 'B',
//          hostname: 'localhost',
//          port: remoteNodeA.toPeer().port + 1,
//          cookie: node.cookie,
//          isHidden: false);
//      Future.wait([
//        node.onConnect.take(1).last,
//        remoteNodeB.onConnect.take(1).last,
//        remoteNodeA.onConnect.take(2).last,
//        // ignore: strong_mode_down_cast_composite
//      ]).then(expectAsync((_) async {
//        expect(remoteNodeA.peers,
//            unorderedEquals([node.toPeer(), remoteNodeB.toPeer()]));
//        expect(remoteNodeB.peers, unorderedEquals([remoteNodeA.toPeer()]));
//        expect(node.peers, unorderedEquals([remoteNodeA.toPeer()]));
//        await remoteNodeA.shutdown();
//        await remoteNodeB.shutdown();
//      }, count: 1));
//      await remoteNodeA.createConnection(node.toPeer());
//      await remoteNodeB.createConnection(remoteNodeA.toPeer());
//    });

    test('should update its list of peers when a node is disconnnected.',
        () async {
      var remoteNodeA = await IONode.create(
          name: 'A',
          hostname: 'localhost',
          port: node.toPeer().port + 1,
          cookie: node.cookie,
          isHidden: false);
      var remoteNodeB = await IONode.create(
          name: 'B',
          hostname: 'localhost',
          port: remoteNodeA.toPeer().port + 1,
          cookie: node.cookie,
          isHidden: false);
      Future.wait([
        node.onDisconnect.take(2).last,
        remoteNodeA.onDisconnect.first,
        remoteNodeB.onDisconnect.first,
        // ignore: strong_mode_down_cast_composite
      ]).then(expectAsync((_) async {
        expect(remoteNodeA.peers, unorderedEquals([remoteNodeB.toPeer()]));
        expect(remoteNodeB.peers, unorderedEquals([remoteNodeA.toPeer()]));
        expect(node.peers, isEmpty);
        await remoteNodeA.shutdown();
        await remoteNodeB.shutdown();
      }, count: 1));

      Future.wait([
        node.onConnect.take(2).last,
        remoteNodeA.onConnect.take(2).last,
        remoteNodeB.onConnect.take(2).last
      ]).then((_) {
        node.disconnect(remoteNodeA.toPeer());
        node.disconnect(remoteNodeB.toPeer());
      });
      remoteNodeA.createConnection(node.toPeer());
      remoteNodeB.createConnection(node.toPeer());
    });
  });
}
