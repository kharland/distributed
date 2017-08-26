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
    const packetCodec = const Utf8PacketCodec();
    const partnerAddress = '127.0.0.1';
    const partnerPort = 1;

    MockUdpAdapter mockAdapter;
    FastPacketChannel channel;

    void commonSetUp({Iterable<io.Datagram> receiveDatagrams = const []}) {
      mockAdapter = new MockUdpAdapter();
      when(mockAdapter.datagrams)
          .thenReturn(new Stream.fromIterable(receiveDatagrams));

      channel = new FastPacketChannel(mockAdapter, partnerAddress, 1);
    }

    test('send should send all packets', () {
      commonSetUp();
      final packets = new List.generate(
        3,
        (i) => new DataPacket('127.0.0.1', 2, [i], 1),
      );

      channel.send(packets);
      verifyInOrder(packets.map((packet) {
        return mockAdapter.add(
            packetCodec.encode(packet), partnerAddress, partnerPort);
      }).toList());
    });

    test('packets should emit each packet followed by an end packet', () {
      final packets = <Packet>[];
      final datagrams = new List.generate(
        3,
        (i) => new io.Datagram(
              [i],
              new io.InternetAddress(partnerAddress),
              partnerPort,
            ),
      );

      datagrams.forEach((dg) {
        packets
          ..add(new DataPacket(
            dg.address.address,
            dg.port,
            dg.data,
            partnerPort,
          ))
          ..add(Packet.end(dg.address.address, dg.port));
      });

      commonSetUp(receiveDatagrams: datagrams);
      expect(channel.packets, emitsInOrder(packets));
    });
  });
}

class MockUdpAdapter extends Mock implements UdpAdapter {}
