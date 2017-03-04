import 'dart:async';

import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void main() {
  PortDaemon daemon;
  VmNode ping;
  VmNode pong;

  group('VmNode', () {
    setUp(() async {
      daemon = new PortDaemon();
      await daemon.start();
      ping = await VmNode.spawn(name: 'ping');
      pong = await VmNode.spawn(name: 'pong');
    });

    tearDown(() async {
      await ping.shutdown();
      await pong.shutdown();
      daemon.stop();
    });

    test('should register when a connection is made', () async {
      ping.connect(pong.toPeer());

      return _onConnection(ping, pong, (peers) {
        expect(peers.first, pong.toPeer());
        expect(peers.last, ping.toPeer());
      });
    });

    test('should send and receive messages', () async {
      ping.connect(pong.toPeer());

      return _onConnection(ping, pong, (peers) {
        pong.receive('ping').listen(expectAsync1((Message message) {
          expect(message, createMessage('ping', 'ping-message'));
          pong.send(ping.toPeer(), 'pong', 'pong-message');
        }));
        ping.receive('pong').listen(expectAsync1((Message message) {
          expect(message, createMessage('pong', 'pong-message'));
        }));
        ping.send(pong.toPeer(), 'ping', 'ping-message');
      });
    });

    test('should register when a node has disconnected', () async {
      ping.connect(pong.toPeer());

      return _onConnection(ping, pong, (peers) {
        _onDisconnection(
            ping,
            pong,
            ((_) {
              expect(ping.peers, isEmpty);
              expect(pong.peers, isEmpty);
            }));
        pong.disconnect(ping.toPeer());
      });
    });
  });
}

Future<List<Peer>> _onConnection(
  Node a,
  Node b,
  Future<Null> callback(List<Peer> peers),
) =>
    Future.wait([
      a.onConnect.first,
      b.onConnect.first,
    ]).then(expectAsync1(callback));

Future<List<Peer>> _onDisconnection(
  Node a,
  Node b,
  Future<Null> callback(List<Peer> peers),
) =>
    Future.wait([
      a.onDisconnect.first,
      b.onDisconnect.first,
    ]).then(expectAsync1(callback));
