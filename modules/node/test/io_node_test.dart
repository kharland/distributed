import 'dart:async';
import 'package:distributed.node/src/io/node.dart';
import 'package:distributed.node/platform/io.dart';
import 'package:test/test.dart';

void main() {
  configureDistributed();

  group('$IONode', () {
    int testPort;
    List<IONode> testNodes = <IONode>[];

    Future<IONode> createNode(String name,
        {String cookie: 'test', bool isHidden: false}) async {
      testNodes.add(new IONode(
          name: name,
          hostname: 'localhost',
          port: testPort++,
          cookie: cookie,
          isHidden: isHidden));
      await testNodes.last.onStartup;
      return testNodes.last;
    }

    setUp(() async {
      testPort = 8080;
      testNodes.clear();
    });

    tearDown(() async {
      for (var node in testNodes) {
        node.shutdown();
        await node.onShutdown;
      }
    });

    test('should reject a connection if the provided cookie does not match',
        () async {
      var a = await createNode('a');
      var b = await createNode('b', cookie: 'different');

      Future.wait([a.onConnectFailed.first, b.onConnectFailed.first]).then(
          expectAsync1((_) async {
        expect(a.peers, isEmpty);
        expect(b.peers, isEmpty);
      }));

      a.connect(b);
    });

    test('should accept a connection if the provided cookie matches', () async {
      var a = await createNode('a');
      var b = await createNode('b');

      Future.wait([a.onConnect.first, b.onConnect.first]).then(
          expectAsync1((_) async {
        expect(a.peers.contains(b), isTrue);
        expect(b.peers.contains(a), isTrue);
      }));
      a.connect(b);
    });

    test("should connect to a new Peer's peers if it is not hidden", () async {
      var a = await createNode('a');
      var b = await createNode('b');
      var c = await createNode('c');

      Future.wait([
        a.onConnect.take(2).last,
        b.onConnect.take(2).last,
        c.onConnect.take(2).last,
      ]).then(expectAsync1((_) async {
        expect(a.peers, unorderedEquals([b, c]));
        expect(b.peers, unorderedEquals([a, c]));
        expect(c.peers, unorderedEquals([a, b]));
      }));

      a.connect(c);
      await a.onConnect.first;
      a.connect(b);
    });

    test("should not connect to a new Peer's peers if it is hidden", () async {
      var a = await createNode('a');
      var b = await createNode('b', isHidden: true);
      var c = await createNode('c');

      Future.wait([
        a.onConnect.take(2).last,
        b.onConnect.first,
        c.onConnect.first
      ]).then(expectAsync1((_) {
        expect(a.peers, unorderedEquals([c, b]));
        expect(b.peers, unorderedEquals([a]));
        expect(c.peers, unorderedEquals([a]));
      }));

      a.connect(c);
      await a.onConnect.first;
      b.connect(a);
    });

    test('should update its list of peers when a node is disconnnected.',
        () async {
      var a = await createNode('a');
      var b = await createNode('b');

      a.connect(b);
      await Future.wait([a.onConnect.first, b.onConnect.first]);
      a.disconnect(b);
      await Future.wait([a.onDisconnect.first, b.onDisconnect.first]);

      expect(a.peers, isEmpty);
      expect(b.peers, isEmpty);
    });
  });
}
