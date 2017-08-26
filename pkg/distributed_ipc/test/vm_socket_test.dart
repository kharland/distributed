import 'dart:io' as io;

import 'package:distributed.ipc/src/testing/socket_parrot.dart';
import 'package:distributed.ipc/src/vm/vm_lockstep_socket.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';
import 'package:test/test.dart';

void main() {
  group(VmSocket, () {
    VmSocket socket;
    SocketParrot parrot;

    setUp(() async {
      parrot = await SocketParrot.bind(io.InternetAddress.ANY_IP_V4, 9000);
      socket = await VmSocket.connect(io.InternetAddress.ANY_IP_V4, 9000);
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
//
//  group(RawUdpSocket, () {
//    RawUdpSocket socket;
//    DatagramSocketParrot parrot;
//
//    setUp(() async {
//      parrot =
//          await DatagramSocketParrot.bind(io.InternetAddress.ANY_IP_V4, 9000);
//      socket = await RawUdpSocket.connect(io.InternetAddress.ANY_IP_V4, 9000);
//    });
//
//    tearDown(() async {
//      parrot.close();
//      socket.close();
//    });
//
//    test('should send and receive data', () {
//      expect(
//          socket,
//          emitsInOrder([
//            new GreetingDatagram(socket.localAddress, socket.localPort)
//                .toBytes(),
//            'Hello world!'.codeUnits,
//          ]));
//      socket.add('Hello world!'.codeUnits);
//    });
//  });
//
//  group(DatagramServerSocket, () {
//    DatagramServerSocket serverSocket;
//    RawUdpSocket connector;
//
//    setUp(() async {
//      serverSocket =
//          await DatagramServerSocket.bind(io.InternetAddress.ANY_IP_V4, 9000);
//    });
//
//    tearDown(() {
//      serverSocket.close();
//      connector.close();
//    });
//
//    test('should emit a $RawUdpSocket when a connection is attempted',
//        () async {
//      connector =
//          await RawUdpSocket.connect(io.InternetAddress.ANY_IP_V4, 9000);
//
//      serverSocket.first.then(expectAsync1((RawUdpSocket socket) {
//        expect(socket.remoteAddress, connector.localAddress);
//        expect(socket.remotePort, connector.localPort);
//      }));
//
//      connector.add(new GreetingDatagram(
//        connector.localAddress,
//        connector.localPort,
//      )
//          .toBytes());
//    });
//
//    test(
//        'should return an error if a connection request is recieved from an '
//        'existing peer',
//        () {},
//        skip: true);
//  });
//
//  group(LockstepCourier, () {
//    DatagramServerSocket server;
//    LockstepCourier sender;
//    LockstepCourier receiver;
//
//    setUp(() async {
//      server = await DatagramServerSocket.bind(
//        io.InternetAddress.ANY_IP_V4,
//        9000,
//      );
//
//      final setUpFuture = server.first.then((RawUdpSocket socket) {
//        receiver = new LockstepCourier.wrap(socket);
//      });
//
//      sender = new LockstepCourier.wrap(
//          await RawUdpSocket.connect(io.InternetAddress.ANY_IP_V4, 9000));
//
//      return setUpFuture;
//    });
//
//    tearDown(() {
//      sender.close();
//      receiver.close();
//      server.close();
//    });
//
//    group('add', () {
//      final millionAs = 'A' * 1000000;
//
//      test('should send and recieve messages', () async {
//        expect(receiver, emits('Hello, World!'));
//        sender.add('Hello, World!');
//      });
//
//      test('should send and receive messages longer than allowed datagram size',
//          () {
//        expect(receiver, emits(millionAs));
//        sender.add(millionAs);
//      });
//
//      test('should support adding one message while another is sending', () {
//        expect(
//            receiver,
//            emitsInOrder([
//              millionAs,
//              millionAs,
//            ]));
//
//        sender..add(millionAs)..add(millionAs);
//      });
//    });
//  });
}
