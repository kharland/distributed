import 'dart:async';
import 'package:distributed.net/secret.dart';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:distributed.node/testing/socket_controller.dart';
import 'package:test/test.dart';

void main() {
  Socket socket;
  Socket testSocket;
  SocketController controller;

  group('$Socket', () {
    setUp(() async {
      controller = new SocketController.broadcast();
      testSocket = controller.foreign;
    });

    tearDown(() => Future.wait([testSocket.close(), socket.close()]));

    test('should receive a connection', () async {
      Socket
          .receive(controller.local, controller.local)
          .then(expectAsync1((Socket s) {
        socket = s;
      }));
      testSocket.add(Secret.acceptAny.toString());
    });

    test('should initiate a connection', () async {
      Socket.connect(controller.local, controller.local).then((Socket s) {
        socket = s;
      });
      testSocket.add('cookie_acc');
    });

    test("should reject a connection if the provided secret doesn't match",
        () async {
      var receiveFuture = Socket.receive(controller.local, controller.local,
          secret: new Secret('correct'));
      var connectionFuture = Socket.connect(testSocket, testSocket,
          secret: new Secret('incorrect'));

      expect(receiveFuture, throws);
      expect(connectionFuture, throws);
    });

    test('should throw a $SocketException if the secret is rejected', () async {
      var connectionFuture = Socket.connect(controller.local, controller.local,
          secret: new Secret('incorrect'));
      testSocket.add('cookie_rej');
      expect(connectionFuture, throws);
    });

    test('should send and recieve data', () async {
      socket = new Socket(controller.local, controller.local);

      testSocket.listen(expectAsync1((String data) {
        expect(data, 'A');
      }));
      socket.listen(expectAsync1((String data) {
        expect(data, 'B');
      }));

      socket.add('A');
      testSocket.add('B');
    });

    // TODO: Enable when seltzer supports address.
    //test('address should be the socket host address', () async {
    //  socket = new Socket(controller.local, controller.local);
    //  expect(socket.address, 'localhost');
    //});
  });
}
