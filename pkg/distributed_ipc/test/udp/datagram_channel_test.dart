import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group(FastDatagramChannel, () {
    const address = '127.0.0.1';
    const datagramCount = 3;
    final testDatagrams = new List<Datagram>.unmodifiable(new List.generate(
      datagramCount,
      (i) => new DataDatagram(address, 2, [i], 1),
    ));

    FastDatagramChannel channel;

    commonSetUp(MockDatagramSocket socket) {
      channel = new FastDatagramChannel(
        new ConnectionConfig(
            localAddress: address,
            localPort: 1,
            remoteAddress: address,
            remotePort: 2),
        socket,
      );
    }

    test('should send all datagrams', () {
      final socket = new MockDatagramSocket();
      commonSetUp(socket);

      channel.addAll(testDatagrams);
      for (var datagram in testDatagrams) {
        verify(socket.add(datagram));
      }
    });

    test('should emit each datagram followed by an end datagram', () {
      commonSetUp(new MockDatagramSocket());

      final expectedDatagrams = <Datagram>[];
      testDatagrams.forEach((p) {
        expectedDatagrams
          ..add(p)
          ..add(new Datagram(DatagramType.END, p.address, p.port));
      });

      final receivedDatagrams = <Datagram>[];
      channel.onEvent(receivedDatagrams.add);
      testDatagrams.forEach(channel.emit);

      expect(receivedDatagrams, expectedDatagrams);
    });
  });
}

class MockDatagramSocket extends Mock implements DatagramSocket {}
