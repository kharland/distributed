import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';
import 'package:test/test.dart';

void main() {
  group(DatagramSocket, () {
    const testAddress = '127.0.0.1';
    const testPort = 9090;

    DatagramSocket localSocket;
    DatagramSocket foreignSocket;

    RawUdpSocket rawLocalSocket;
    RawUdpSocket rawForeignSocket;

    setUp(() async {
      rawLocalSocket = await RawUdpSocket.bind(testAddress, 9090);
      rawForeignSocket = await RawUdpSocket.bind(testAddress, 9091);

      localSocket = new DatagramSocket(rawLocalSocket);
      foreignSocket = new DatagramSocket(rawForeignSocket);
    });

    tearDown(() async {
      localSocket.close();
      foreignSocket.close();
    });

    test('should emit an event when a datagram is received', () {
      localSocket.onEvent(expectAsync1((Datagram datagram) {
        expect(datagram.type, DatagramType.ACK);
        expect(datagram.address, testAddress);
        expect(datagram.port, testPort);
      }));

      foreignSocket.add(new Datagram(
        DatagramType.ACK,
        localSocket.address,
        localSocket.port,
      ));
    });

    test(
        'should throw exception without emitting event if a datagram has an '
        'uncrecognized type', () {
      final testRawSocket = new TestRawUdpSocket();
      localSocket = new DatagramSocket(testRawSocket);
      localSocket.onEvent((_) {
        fail('should not reach here');
      });

      try {
        testRawSocket.emit(utf8Encode([
              1234567,
              '$testAddress',
              '$testPort',
            ].join(':') +
            ':'));
      } catch (e) {
        expect(e, new isInstanceOf<DatagramTypeException>());
      }
    });
  });
}

class TestRawUdpSocket extends EventSource<List<int>> implements RawUdpSocket {
  String get address => null;

  int get port => null;

  @override
  void add(List<int> data, String address, int port) {}

  @override
  void close() {}
}
