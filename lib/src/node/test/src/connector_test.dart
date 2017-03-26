import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.node/src/connector.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:test/test.dart';

void main() {
  final hostMachine = BuiltHostMachine.localHost;

  group('$OneShotConnector', () {
    final senderPeer = $peer('sender', hostMachine);
    final receiverPeer = $peer('receiver', hostMachine);

    OneShotConnector connector;
    PortDaemon portDaemon;
    SocketServer receiverServer;

    setUp(() async {
      connector = new OneShotConnector();
      portDaemon = await PortDaemon.spawn();

      var senderReg = await portDaemon.registerNode(senderPeer.name);
      var receiverReg = await portDaemon.registerNode(receiverPeer.name);

      await SocketServer.bind(hostMachine.address, senderReg.port);
      receiverServer =
          await SocketServer.bind(hostMachine.address, receiverReg.port);
    });

    tearDown(() async {
      portDaemon.stop();
    });

    group('connect', () {
      void expectResult(ConnectionResult result) {
        expect(result.error, '');
        expect(result.sender, senderPeer);
        expect(result.receiver, receiverPeer);
        expect(result.socket, isNotNull);
      }

      test('should connect two peers', () async {
        receiverServer.onSocket.listen(expectAsync1((Socket socket) async {
          var result = await connector.receiveSocket(receiverPeer, socket);
          expectResult(result);
          result.socket.close();
        }));
        var result = await connector.connect(senderPeer, receiverPeer).first;
        expectResult(result);
        result.socket.close();
      });
    });
  });
}
