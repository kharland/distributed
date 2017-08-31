import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/testing/test_udp_sink.dart';
import 'package:test/test.dart';

void main() {
  group(FastPacketChannel, () {
    const packetCount = 3;
    final packets = new List<Packet>.unmodifiable(new List.generate(
      packetCount,
      (i) => new DataPacket('127.0.0.1', 2, [i], 1),
    ));
    const packetCodec = const Utf8PacketCodec();
    const partnerAddress = '127.0.0.1';
    const partnerPort = 1;

    FastPacketChannel channel;
    TestUdpSink<List<int>> testSink;

    setUp(() {
      testSink = new TestUdpSink<List<int>>();
    });

    void commonSetUp({Iterable<Packet> incomingPackets = const []}) {
      channel = new FastPacketChannel(partnerAddress, partnerPort, testSink);
      incomingPackets.forEach(channel.receive);
    }

    test('send should send all packets', () {
      commonSetUp();
      channel.send(packets);
      expect(testSink.data, []..addAll(packets.map(packetCodec.encode)));
    });

    test('packets should emit each packet followed by an end packet', () {
      final expectedPackets = <Packet>[];
      packets.forEach((p) {
        expectedPackets
          ..add(p)
          ..add(new Packet(PacketType.END, p.address, p.port));
      });

      commonSetUp(incomingPackets: packets);
      expect(channel.packets, emitsInOrder(expectedPackets));
    });
  });
}
