import 'dart:async';
import 'package:distributed/src/io/node.dart';
import 'package:distributed/platform/io.dart';
import 'package:test/test.dart';

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

    tearDown(() async {
      node.shutdown();
      await node.onShutdown;
    });

    test('should reject a connection if the provided cookie does not match',
        () async {
      var remoteNode = await IONode.create(
          name: 'A',
          hostname: 'localhost',
          port: node.toPeer().port + 1,
          cookie: 'different-${node.cookie}',
          isHidden: false);
      remoteNode.createConnection(node.toPeer());
      await remoteNode.onDisconnect.first;
      expect(remoteNode.peers.contains(node.toPeer()), isFalse);
      expect(node.peers.contains(remoteNode.toPeer()), isFalse);
      remoteNode.shutdown();
      return remoteNode.onShutdown;
    });

    test('should accept a connection if the provided cookie matches', () async {
      var remoteNode = await IONode.create(
          name: 'A',
          hostname: 'localhost',
          port: node.toPeer().port + 1,
          cookie: node.cookie,
          isHidden: false);

      Future.wait([remoteNode.onConnect.first, node.onConnect.first])
          // ignore: strong_mode_down_cast_composite
          .then(expectAsync((_) async {
        expect(remoteNode.peers.contains(node.toPeer()), isTrue);
        expect(node.peers.contains(remoteNode.toPeer()), isTrue);
        remoteNode.shutdown();
        await remoteNode.onShutdown;
      }));

      remoteNode.createConnection(node.toPeer());
    });

    test("should connect to a new Peer's peers if it is not hidden", () async {
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
        node.onConnect.take(2).last,
        remoteNodeB.onConnect.take(2).last,
        remoteNodeA.onConnect.take(2).last,
        // ignore: strong_mode_down_cast_composite
      ]).then(expectAsync((_) async {
        expect(remoteNodeA.peers,
            unorderedEquals([node.toPeer(), remoteNodeB.toPeer()]));
        expect(remoteNodeB.peers,
            unorderedEquals([node.toPeer(), remoteNodeA.toPeer()]));
        expect(node.peers,
            unorderedEquals([remoteNodeA.toPeer(), remoteNodeB.toPeer()]));
        remoteNodeA.shutdown();
        await remoteNodeA.onShutdown;
        remoteNodeB.shutdown();
        await remoteNodeB.onShutdown;
      }, count: 1));

      remoteNodeA.createConnection(node.toPeer());
      await remoteNodeA.onConnect.first;
      remoteNodeB.createConnection(remoteNodeA.toPeer());
    });

    test("should not connect to a new Peer's peers if it is not hidden",
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
          isHidden: true);

      Future.wait([
        node.onConnect.first,
        remoteNodeA.onConnect.take(2).last,
        remoteNodeB.onConnect.first
        // ignore: strong_mode_down_cast_composite
      ]).then(expectAsync((_) {
        expect(remoteNodeA.peers,
            unorderedEquals([node.toPeer(), remoteNodeB.toPeer()]));
        expect(remoteNodeB.peers, unorderedEquals([remoteNodeA.toPeer()]));
        expect(node.peers, unorderedEquals([remoteNodeA.toPeer()]));
        remoteNodeA.shutdown();
        remoteNodeB.shutdown();
        return Future.wait([
          remoteNodeA.onShutdown,
          remoteNodeB.onShutdown,
          node.onDisconnect.take(2).last
        ]);
      }));

      remoteNodeA.createConnection(node.toPeer());
      await remoteNodeA.onConnect.first;
      remoteNodeB.createConnection(remoteNodeA.toPeer());
    });

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

      Future.wait(<Future>[
        node.onConnect.take(2).last,
        remoteNodeA.onConnect.take(2).last,
        remoteNodeB.onConnect.take(2).last
        // ignore: strong_mode_down_cast_composite
      ]).then(expectAsync((_) {
        node.disconnect(remoteNodeA.toPeer());
        node.disconnect(remoteNodeB.toPeer());
        Future.wait(<Future>[
          node.onDisconnect.take(2).last,
          remoteNodeA.onDisconnect.first,
          remoteNodeB.onDisconnect.first,
          // ignore: strong_mode_down_cast_composite
        ]).then(expectAsync((_) async {
          expect(remoteNodeA.peers, unorderedEquals([remoteNodeB.toPeer()]));
          expect(remoteNodeB.peers, unorderedEquals([remoteNodeA.toPeer()]));
          expect(node.peers, isEmpty);
          remoteNodeA.shutdown();
          remoteNodeB.shutdown();
          await Future.wait([remoteNodeA.onShutdown, remoteNodeB.onShutdown]);
        }, count: 1));
      }));

      //await new Future.delayed(const Duration(seconds: 3));
      remoteNodeA.createConnection(node.toPeer());
      remoteNodeB.createConnection(node.toPeer());
    });
  });
}
