import 'dart:io';

import 'package:distributed.ipc/src/vm_socket.dart';
import 'package:distributed.ipc/src/testing/socket_parrot.dart';
import 'package:test/test.dart';

void main() {
  group(VmSocket, () {
    VmSocket socket;
    SocketParrot parrot;

    setUp(() async {
      parrot = await SocketParrot.bind(InternetAddress.ANY_IP_V4, 9000);
      socket = await VmSocket.connect(InternetAddress.ANY_IP_V4, 9000);
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

  group(DatagramSocket, () {
    DatagramSocket socket;
    RawSocketParrot parrot;

    setUp(() async {
      parrot = await RawSocketParrot.bind(InternetAddress.ANY_IP_V4, 9000);
      socket = await DatagramSocket.connect(InternetAddress.ANY_IP_V4, 9000);
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

  group(VmDatagramSocket, () {});
}
