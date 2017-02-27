import 'dart:io' hide Socket;

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.node/src/logging.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void main() {
  const daemonPort = 9000;
  final hostMachine =
      createHostMachine(InternetAddress.LOOPBACK_IP_V4, daemonPort);

  Peer createTestPeer(String name) => createPeer(name, hostMachine);

  group('$OneShotConnector', () {
    final senderPeer = createTestPeer('sender');
    final receiverPeer = createTestPeer('receiver');

    OneShotConnector connector;
    PortDaemon portDaemon;
    SocketServer receiverServer;

    setUp(() async {
      connector = new OneShotConnector(new Logger.disabled());

      portDaemon = new PortDaemon(hostMachine: hostMachine);
      await portDaemon.start();
      var senderPort = await portDaemon.registerNode(senderPeer.name);
      var receiverPort = await portDaemon.registerNode(receiverPeer.name);

      await SocketServer.bind(hostMachine.address, senderPort);
      receiverServer =
          await SocketServer.bind(hostMachine.address, receiverPort);
    });

    tearDown(() async {
      portDaemon.clearDatabase();
      return portDaemon.stop();
    });

    group('connect', () {
      void expectResult(ConnectionResult result) {
        expect(result.sender, senderPeer);
        expect(result.receiver, receiverPeer);
        expect(result.connection, isNotNull);
        expect(result.error, isEmpty);
      }

      test('should connect two peers', () async {
        receiverServer.onSocket.listen(expectAsync1((Socket socket) async {
          expectResult(await connector.receiveSocket(receiverPeer, socket));
        }));
        expectResult(await connector.connect(senderPeer, receiverPeer).first);
      });
    });
  });
}
