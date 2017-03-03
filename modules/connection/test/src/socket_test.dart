import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket/socket_controller.dart';
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

    test('should send and receive data', () async {
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
