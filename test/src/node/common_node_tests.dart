import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/node/node.dart';
import 'package:distributed.objects/public.dart';
import 'package:distributed.objects/private.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void runNodeTests() {
  PortDaemon daemon;
  Node ping;
  Node pong;

  group('$Node', () {
    setUp(() async {
      daemon = await PortDaemon.spawn(new Logger('port_daemon'));
      ping = await Node.spawn('ping', logger: new Logger('ping'));
      pong = await Node.spawn('pong', logger: new Logger('pong'));
    });

    tearDown(() async {
      await ping.shutdown();
      await pong.shutdown();
      daemon.stop();
    });

    test('should register when a connection is made', () async {
      var expectedPing = new Peer(ping.name,
          new HostMachine('127.0.0.1', ping.hostMachine.portDaemonPort));
      var expectedPong = new Peer(pong.name,
          new HostMachine('127.0.0.1', pong.hostMachine.portDaemonPort));
      expect(pong.onConnect, emits(expectedPing));
      expect(ping.onConnect, emits(expectedPong));
      await ping.connect(pong.toPeer());
    });

    test('should register when a disconnection occurs', () async {
      await ping.connect(pong.toPeer());
      expect(pong.onDisconnect, emits(ping.toPeer()));
      expect(ping.onDisconnect, emits(pong.toPeer()));
      ping.disconnect(pong.toPeer());
    });

    test('should update its list of peers when a connection is made', () async {
      await ping.connect(pong.toPeer());
      expect(ping.peers, [pong.toPeer()]);
      expect(pong.peers, [ping.toPeer()]);
    });

    test('should update its list of peers when a disconnection is made',
        () async {
      await ping.connect(pong.toPeer());
      ping.disconnect(pong.toPeer());
      await ping.onDisconnect.first;
      expect(ping.peers, isEmpty);
      await pong.onDisconnect.first;
      expect(pong.peers, isEmpty);
    });

    test('should send and receive messages', () async {
      await ping.connect(pong.toPeer());

      pong.receive('ping').listen(expectAsync1((Message message) {
        expect(message, $message('ping', 'ping-message', ping.toPeer()));
        pong.send(ping.toPeer(), 'pong', 'pong-message');
      }));
      ping.receive('pong').listen(expectAsync1((Message message) {
        expect(message, $message('pong', 'pong-message', pong.toPeer()));
      }));
      ping.send(pong.toPeer(), 'ping', 'ping-message');
    });

    test('should register when a node has disconnected', () async {
      await ping.connect(pong.toPeer());
      expect(ping.onDisconnect, emits(pong.toPeer()));
      expect(pong.onDisconnect, emits(ping.toPeer()));
      ping.disconnect(pong.toPeer());
      await pong.onDisconnect.first;
      expect(ping.peers, isEmpty);
      expect(pong.peers, isEmpty);
    });
  });
}
