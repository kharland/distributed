import 'dart:async';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:test/test.dart';

void main({
  Future<ConnectionStrategy> setup(),
  Future teardown(),
  Future addPeersToNetwork(List<Peer> peers),
}) {
  ConnectionStrategy connectionStrategy;

  setUp(() async {
    connectionStrategy = await setup();
  });

  tearDown(() => teardown());

  test('connect should return a connection', () async {
    const remotePeer = const Peer('remote', 'localhost');

    await addPeersToNetwork([remotePeer]);
    var connection = await connectionStrategy.connect(
      'local',
      remotePeer.name,
    );
    expect(connection.peer, remotePeer);
  });

  test('connect should throw an exception if the connection fails', () async {
    expect(connectionStrategy.connect('local', 'unknown'), throws);
  });
}

class TestConnection implements Connection {
  @override
  ConnectionChannels<Message> get channels => null;

  // TODO: implement peer
  @override
  Peer get peer => null;
}
