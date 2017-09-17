import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/udp/data_channel.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_rewriter.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group(FastChannel, () {
    const address = '127.0.0.1';

    FastChannel localChannel;
    FastChannel foreignChannel;
    DatagramSocket localSocket;
    DatagramSocket foreignSocket;

    setUp(() async {
      localSocket = await DatagramSocket.bind(address, 9090);
      localChannel = new FastChannel(
        new ConnectionConfig(remoteAddress: address, remotePort: 9091),
        localSocket,
      );

      foreignSocket = await DatagramSocket.bind(address, 9091);
      foreignChannel = new FastChannel(
        new ConnectionConfig(remoteAddress: address, remotePort: 9090),
        foreignSocket,
      );
    });

    tearDown(() {
      localSocket.close();
      foreignSocket.close();
    });

    test('should send and receive a datagram', () {
      const _dgRewriter = const DatagramRewriter();
      final data = [1, 2, 3];

      foreignChannel.onEvent(expectAsync1((Datagram datagram) {
        final expectedDg = _dgRewriter.rewrite(
          datagram,
          address: address,
          port: foreignChannel.remotePort,
        );
        expect(datagram, expectedDg);
      }, count: 2)); // END Packet sent after DATA packet.

      localChannel.add(data);
    });

    test('should emit each datagram followed by an end datagram', () {
      final expectedDatagrams = <Datagram>[];
      for (int i = 0; i < 2; i++) {
        expectedDatagrams
          ..add(new DataDatagram(address, localChannel.remotePort, [i], 1))
          ..add(new Datagram(
            DatagramType.END,
            address,
            localChannel.remotePort,
          ));
      }

      final receivedDatagrams = <Datagram>[];
      foreignChannel.onEvent(receivedDatagrams.add);

      expectedDatagrams
          .where((dg) => dg.type == DatagramType.DATA)
          .forEach(foreignChannel.emit);

      expect(receivedDatagrams, expectedDatagrams);
    });
  });
}

class MockDatagramSocket extends Mock implements DatagramSocket {}
