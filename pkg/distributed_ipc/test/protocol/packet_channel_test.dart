import 'dart:async';
import 'dart:io' as io;

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_channel.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/vm/vm_socket.dart';
import 'package:mockito/mockito.dart';
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

    List<List<int>> writtenBytes;
    FastPacketChannel channel;

    setUp(() {
      writtenBytes = [];
    });

    void commonSetUp({Iterable<List<int>> incomingBytes = const []}) {
      channel = new FastPacketChannel(
        partnerAddress,
        1,
        new Stream.fromIterable(incomingBytes),
        (List<int> data, __, ___) {
          writtenBytes.add(data);
        },
      );
    }

    test('send should send all packets', () {
      commonSetUp();

      channel.send(packets);
      expect(writtenBytes, []..addAll(packets.map(packetCodec.encode)));
    });

    test('packets should emit each packet followed by an end packet', () {
      final datagrams = new List.generate(
        3,
        (i) => new io.Datagram(
              packetCodec.encode(packets[i]),
              new io.InternetAddress(partnerAddress),
              partnerPort,
            ),
      );

      final expectedPackets = <Packet>[];
      packets.forEach((p) {
        expectedPackets
          ..add(p)
          ..add(new Packet(PacketTypes.END, p.address, p.port));
      });

      commonSetUp(incomingBytes: datagrams.map((dg) => dg.data));
      expect(channel.packets, emitsInOrder(expectedPackets));
    });
  });
}

class MockUdpAdapter extends Mock implements UdpAdapter {}
