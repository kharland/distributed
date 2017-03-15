import 'package:distributed.node/platform/vm.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void main() {
  PortDaemon daemon;
  VmNode ping;
  VmNode pong;

  group('VmNode', () {
    setUp(() async {
      daemon = await PortDaemon.spawn();
      ping = await VmNode.spawn(name: 'ping');
      pong = await VmNode.spawn(name: 'pong');
    });

    tearDown(() async {
      await ping.shutdown();
      await pong.shutdown();
      daemon.stop();
    });

    test('should register when a connection is made', () async {
      expect(pong.onConnect, emits(ping.toPeer()));
      expect(ping.onConnect, emits(pong.toPeer()));
      await ping.connect(pong.toPeer());
      expect(ping.peers, [pong.toPeer()]);
      expect(pong.peers, [ping.toPeer()]);
    });

    test('should send and receive messages', () async {
      await ping.connect(pong.toPeer());

      pong.receive('ping').listen(expectAsync1((Message message) {
        expect(message, createMessage('ping', 'ping-message', ping.toPeer()));
        pong.send(ping.toPeer(), 'pong', 'pong-message');
      }));
      ping.receive('pong').listen(expectAsync1((Message message) {
        expect(message, createMessage('pong', 'pong-message', pong.toPeer()));
      }));
      ping.send(pong.toPeer(), 'ping', 'ping-message');
    });

    test('should register when a node has disconnected', () async {
      await ping.connect(pong.toPeer());
      expect(ping.onDisconnect, emits(pong.toPeer()));
      expect(pong.onDisconnect, emits(ping.toPeer()));
      await ping.disconnect(pong.toPeer());
      await pong.onDisconnect.first;
      expect(ping.peers, isEmpty);
      expect(pong.peers, isEmpty);
    });
  });
}
