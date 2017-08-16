import 'dart:io';

import 'package:distributed.ipc/src/io_socket.dart';
import 'package:distributed.ipc/src/testing/socket_parrot.dart';
import 'package:test/test.dart';

void main() {
  group(IoSocket, () {
    IoSocket socket;
    SocketParrot parrot;

    setUp(() async {
      parrot = await SocketParrot.bind(InternetAddress.ANY_IP_V4, 9000);
      socket = await IoSocket.connect(InternetAddress.ANY_IP_V4, 9000);
    });

    tearDown(() async {
      parrot.close();
      socket.close();
    });

    test('should send and receive data', () {
      expect(socket, emits('Hello world!'));
      socket.add('Hello world!');
    });
  });

  group(IoDatagramSocket, () {
    IoDatagramSocket socket;
    RawSocketParrot parrot;

    setUp(() async {
      parrot = await RawSocketParrot.bind(InternetAddress.ANY_IP_V4, 9000);
      socket = await IoDatagramSocket.connect(InternetAddress.ANY_IP_V4, 9000);
    });

    tearDown(() async {
      parrot.close();
      socket.close();
    });

    test('should send and receive data', () {
      expect(socket, emits('Hello world!'.codeUnits));
      socket.add('Hello world!'.codeUnits);
    });
  });
}
