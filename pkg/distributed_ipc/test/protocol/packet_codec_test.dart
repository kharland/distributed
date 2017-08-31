import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/protocol/packet_codec.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:test/test.dart';

void main() {
  group(Utf8PacketCodec, () {
    const codec = const Utf8PacketCodec();
    const address = '127.0.0.1';
    const port = 1;

    group('encode', () {
      test('should encode a non-data packet', () {
        final packet = const Packet(PacketTypes.ACK, address, port);
        expect(codec.encode(packet), utf8Encode('1:$address:$port:'));
      });

      test('should encode a data packet', () {
        final packet = const DataPacket(address, port, const [123], 7);
        expect(codec.encode(packet), utf8Encode('3:$address:$port:7:[123]:'));
      });
    });

    group('decode', () {
      test('should decode a non-data packet', () {
        final packet = const Packet(PacketTypes.ACK, address, port);
        expect(codec.decode(codec.encode(packet)), packet);
      });

      test('should decode a data packet', () {
        final packet = const DataPacket(address, port, const [12, 345, 6], 7);
        expect(codec.decode(codec.encode(packet)), packet);
      });
    });
  });
}
