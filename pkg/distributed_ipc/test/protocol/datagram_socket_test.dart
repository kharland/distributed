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

    DatagramSocket socket;
    MockUdpSocket mockUdpSocket;

    void commonSetUp([List<Datagram> incomingDatagrams = const []]) {
      mockUdpSocket = new MockUdpSocket();
      socket = new DatagramSocket(mockUdpSocket);
    }

    test('should not call any callback if a datagram has an uncrecognized type',
        () {
      final recordedDatagrams = <Datagram>[];
      final datagram = new Datagram(
        [1, 2, 3],
        testAddress,
        testPort,
        999,
      );

      commonSetUp([datagram]);

      socket.onEvent(recordedDatagrams.add);
      try {
        mockUdpSocket.emit(const DatagramCodec().encode(datagram));
      } catch (e) {
        expect(e, new isInstanceOf<DatagramTypeException>());
      }

      expect(recordedDatagrams, isEmpty);
    });
  });
}

class MockUdpSocket extends EventSource<List<int>> implements RawUdpSocket {
  @override
  void emit(List<int> event) {
    super.emit(event);
  }

  @override
  void add(List<int> data, String address, int port) {}
  @override
  void close() {}
}
