import 'package:collection/collection.dart';
import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:test/test.dart';

void main() {
  group(FastDatagramChannel, () {
    const datagramCount = 3;
    final datagrams = new List<Datagram>.unmodifiable(new List.generate(
      datagramCount,
      (i) => new DataDatagram('127.0.0.1', 2, [i], 1),
    ));

    const partnerAddress = '127.0.0.1';
    const partnerPort = 1;

    FastDatagramChannel channel;
    TestSink<Datagram> testSink;

    setUp(() {
      testSink = new TestSink<Datagram>();
    });

    setUp(() {
      final pipe = new SinkPipe<Datagram>(testSink);
      channel = new FastDatagramChannel(
          new DatagramChannelConfig(partnerAddress, partnerPort, pipe));
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
