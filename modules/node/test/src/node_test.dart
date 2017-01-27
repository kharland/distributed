import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/platform/vm.dart';
import 'package:test/test.dart';

void main({
  Future setup(),
  Future teardown(),
  Node createNode(String name, {Secret secret, bool isHidden}),
}) {
  configureDistributed();

  setUp(() => setup());

  tearDown(() => teardown());

  test('should reject a connection if the provided secret does not match',
      () async {
    var a = await createNode('a');
    var b = await createNode('b', secret: new Secret('different'));

    await a.connect(b.toPeer());
    expect(a.peers, isEmpty);
    expect(b.peers, isEmpty);
  });

  test('should accept a connection if the provided secret matches', () async {
    var a = await createNode('a');
    var b = await createNode('b');

    await a.connect(b.toPeer());
    expect(a.peers.contains(b.toPeer()), isTrue);
    expect(b.peers.contains(a.toPeer()), isTrue);
    a.connect(b.toPeer());
  });

  test("should connect to a new Peer's peers if it is not hidden", () async {
    var a = await createNode('a');
    var b = await createNode('b');
    var c = await createNode('c');

    await a.connect(c.toPeer());
    await a.connect(b.toPeer());

    expect(a.peers, unorderedEquals([b.toPeer(), c.toPeer()]));
    expect(b.peers, unorderedEquals([a.toPeer(), c.toPeer()]));
    expect(c.peers, unorderedEquals([a.toPeer(), b.toPeer()]));
  });

  test("should not connect to a new Peer's peers if it is hidden", () async {
    var a = await createNode('a');
    var b = await createNode('b', isHidden: true);
    var c = await createNode('c');

    await a.connect(c.toPeer());
    await b.connect(a.toPeer());

    expect(a.peers, unorderedEquals([c.toPeer(), b.toPeer()]));
    expect(b.peers, unorderedEquals([a.toPeer()]));
    expect(c.peers, unorderedEquals([a.toPeer()]));
  });

  test('should update its list of peers when a node is disconnnected.',
      () async {
    var a = await createNode('a');
    var b = await createNode('b');

    await a.connect(b.toPeer());
    a.disconnect(b.toPeer());
    await Future.wait([a.onDisconnect.first, b.onDisconnect.first]);

    expect(a.peers, isEmpty);
    expect(b.peers, isEmpty);
  });
}
