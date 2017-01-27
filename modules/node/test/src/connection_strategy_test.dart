import 'dart:async';

import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:test/test.dart';

void main({
  ConnectionStrategy setup([List<String> inNetworkNodes]),
  Future teardown(),
  void addNodeToNetwork(String name),
}) {
  ConnectionStrategy connectionStrategy;

  tearDown(() => teardown());

  test('connect should return a stream of connections', () async {
    connectionStrategy = setup(['remote']);
    expect(connectionStrategy.connect('local', 'remote').first, completes);
  });

  test('connect should throw an exception if the connection fails', () async {
    connectionStrategy = setup();
    expect(connectionStrategy.connect('local', 'unknown').first, throws);
  });
}
