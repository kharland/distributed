import 'dart:async';

import 'package:distributed.http/src/testing/local_address.dart';
import 'package:distributed.http/src/testing/network_emulator.dart';
import 'package:distributed.http/vm.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:test/test.dart';

void main() {
  group('$NetworkEmulator', () {
    NetworkEmulator networkEmulator;
    const loopback = '127.0.0.1';

    setUp(() {
      networkEmulator = new NetworkEmulator(<NetworkAddress>[
        new NetworkAddress('127.0.0.1', new Logger('NetworkAddress')),
      ]);
    });

    group('listen', () {
      group('should throw', () {
        test('if the host is not found', () {
          expect(() => networkEmulator.listen('127.0.0.2'),
              throwsA(new isInstanceOf<SocketException>()));
        });

        test('if the port is already bound', () {
          networkEmulator.listen(loopback, 1);
          expect(() => networkEmulator.listen(loopback, 1),
              throwsA(new isInstanceOf<SocketException>()));
        });
      });
      test('should return a stream of Sockets', () {
        expect(networkEmulator.listen(loopback, 1),
            new isInstanceOf<Stream<Socket>>());
      });
    });

    group('connect', () {
      group('should throw', () {
        test('if no agent is listening at the source address', () {
          expect(() => networkEmulator.connect('127.0.0.2', 2, loopback, 1),
              throwsA(new isInstanceOf<SocketException>()));
        });

        test('if either address is not found', () {
          networkEmulator.listen(loopback, 1);
          expect(() => networkEmulator.connect('127.0.0.2', 2, loopback, 1),
              throwsA(new isInstanceOf<SocketException>()));
          expect(() => networkEmulator.connect(loopback, 3, '127.0.0.2', 1),
              throwsA(new isInstanceOf<SocketException>()));
          expect(() => networkEmulator.connect('127.0.0.2', 4, '127.0.0.3', 1),
              throwsA(new isInstanceOf<SocketException>()));
        });

        test('if the source port is occupied', () {
          networkEmulator.listen(loopback, 1);
          networkEmulator.listen(loopback, 2);
          expect(() => networkEmulator.connect(loopback, 1, loopback, 2),
              throwsA(new isInstanceOf<SocketException>()));
          expect(() => networkEmulator.connect(loopback, 2, loopback, 1),
              throwsA(new isInstanceOf<SocketException>()));
        });
      });

      test('should connect one address to another', () {
        var socketStream =
            networkEmulator.listen(loopback, 1).asBroadcastStream();
        Socket connectorSocket;
        socketStream.take(1).first.then(expectAsync1((Socket listenerSocket) {
          expect(connectorSocket.port, 2);
          expect(listenerSocket.port, 1);
          expect(listenerSocket, emits('HI!'));
          connectorSocket.add('HI!');
        }));
        connectorSocket = networkEmulator.connect(loopback, 2, loopback, 1);
      });
    });
  });
}
