import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void main() {
  const daemonPort = 9000;
  final hostMachine = createHostMachine('localhost', daemonPort);

  Peer createTestPeer(String name) => createPeer(name, hostMachine);

  group('$OneShotConnector', () {
    final senderPeer = createTestPeer('sender');
    final receiverPeer = createTestPeer('receiver');

    OneShotConnector connector;
    PortDaemon portDaemon;
    SocketServer receiverServer;

    setUp(() async {
      connector = new OneShotConnector();
      portDaemon = await PortDaemon.spawn(hostMachine: hostMachine);

      var senderPort = await portDaemon.registerNode(senderPeer.name);
      var receiverPort = await portDaemon.registerNode(receiverPeer.name);

      await SocketServer.bind(hostMachine.address, senderPort);
      receiverServer =
          await SocketServer.bind(hostMachine.address, receiverPort);
    });

    tearDown(() async {
      return portDaemon.stop();
    });

    group('connect', () {
      void expectResult(ConnectionResult result) {
        expect(result.error, '');
        expect(result.sender, senderPeer);
        expect(result.receiver, receiverPeer);
        expect(result.connection, isNotNull);
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
