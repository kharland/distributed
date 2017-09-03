import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/raw_udp_socket.dart';
import 'package:test/test.dart';

void main() {
  group(DatagramSocket, () {
    const testAddress = '127.0.0.1';
    const testPort = 9090;

    DatagramSocket socket;
    MockRawUdpSocket mockUdpSocket;
    final codec = const Utf8DatagramCodec();

    void commonSetUp() {
      mockUdpSocket = new MockRawUdpSocket();
      socket = new DatagramSocket(mockUdpSocket);
    }

    test('should emit an event when a datagram is received', () {
      commonSetUp();

      final eventData = codec.encode(new Datagram(
        DatagramType.ACK,
        testAddress,
        testPort,
      ));

      socket.onEvent(expectAsync1((Datagram datagram) {
        expect(datagram.type, DatagramType.ACK);
        expect(datagram.address, testAddress);
        expect(datagram.port, testPort);
      }));

      mockUdpSocket.emit(eventData);
    });

    test(
        'should throw exception without emitting event if a datagram has an '
        'uncrecognized type', () {
      final recordedDatagrams = <Datagram>[];
      final invalidType = 123456789;
      final datagramData = utf8Encode([
            invalidType,
            '$testAddress',
            '$testPort',
          ].join(':') +
          ':');

      commonSetUp();
      socket.onEvent(recordedDatagrams.add);

      try {
        mockUdpSocket.emit(datagramData);
      } catch (e) {
        expect(e, new isInstanceOf<DatagramTypeException>());
      }

      expect(recordedDatagrams, isEmpty);
    });
  });
}

class MockRawUdpSocket extends EventSource<List<int>> implements RawUdpSocket {
  String get address => null;

  int get port => null;

  @override
  void add(List<int> data, String address, int port) {
    throw new UnimplementedError();
  }

  @override
  void close() {
    throw new UnimplementedError();
  }
}
