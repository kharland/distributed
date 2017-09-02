import 'package:collection/collection.dart';
import 'package:distributed.ipc/src/internal/pipe.dart';
import 'package:distributed.ipc/src/udp/packet.dart';
import 'package:distributed.ipc/src/udp/packet_channel.dart';
import 'package:test/test.dart';

void main() {
  group(FastPacketChannel, () {
    const packetCount = 3;
    final packets = new List<Packet>.unmodifiable(new List.generate(
      packetCount,
      (i) => new DataPacket('127.0.0.1', 2, [i], 1),
    ));

    const partnerAddress = '127.0.0.1';
    const partnerPort = 1;

    FastPacketChannel channel;
    TestSink<Packet> testSink;

    setUp(() {
      testSink = new TestSink<Packet>();
    });

    setUp(() {
      final pipe = new SinkPipe<Packet>(testSink);
      channel = new FastPacketChannel(
          new PacketChannelConfig(partnerAddress, partnerPort, pipe));
    });

    test('should send all packets', () {
      channel.addAll(packets);
      expect(testSink, []..addAll(packets));
    });

    test('should emit each packet followed by an end packet', () {
      final expectedPackets = <Packet>[];
      packets.forEach((p) {
        expectedPackets
          ..add(p)
          ..add(new Packet(PacketType.END, p.address, p.port));
      });

      final receivedPackets = <Packet>[];
      channel.onEvent(receivedPackets.add);
      packets.forEach(channel.receive);

      expect(receivedPackets, expectedPackets);
    });
  });
}

class TestSink<T> extends DelegatingList<T> implements Sink<T> {
  TestSink([List<T> base]) : super(base ?? []);

  @override
  void close() {}
}
