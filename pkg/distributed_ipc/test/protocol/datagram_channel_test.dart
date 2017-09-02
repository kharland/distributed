import 'package:collection/collection.dart';
import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';
import 'package:distributed.ipc/src/udp/datagram_socket.dart';
import 'package:test/test.dart';

void main() {
  group(FastDatagramChannel, () {
    const address = '127.0.0.1';
    const datagramCount = 3;
    final datagrams = new List<Datagram>.unmodifiable(new List.generate(
      datagramCount,
      (i) => new DataDatagram(address, 2, [i], 1),
    ));

    FastDatagramChannel channel;
    TestSink<Datagram> testSink;

    setUp(() {
      testSink = new TestSink<Datagram>();
    });

    setUp(() {
      final socket = new DatagramSocket(null);
      channel = new FastDatagramChannel(
        new ConnectionConfig(
            localAddress: address,
            localPort: 1,
            remoteAddress: address,
            remotePort: 2),
        socket,
      );
    });

    test('should send all datagrams', () {
      channel.addAll(datagrams);
      expect(testSink, []..addAll(datagrams));
    });

    test('should emit each datagram followed by an end datagram', () {
      final expectedDatagrams = <Datagram>[];
      datagrams.forEach((p) {
        expectedDatagrams
          ..add(p)
          ..add(new Datagram(DatagramType.END, p.address, p.port));
      });

      final receivedDatagrams = <Datagram>[];
      channel.onEvent(receivedDatagrams.add);
      datagrams.forEach(channel.receive);

      expect(receivedDatagrams, expectedDatagrams);
    });
  });
}

class TestSink<T> extends DelegatingList<T> implements Sink<T> {
  TestSink([List<T> base]) : super(base ?? []);

  @override
  void close() {}
}
