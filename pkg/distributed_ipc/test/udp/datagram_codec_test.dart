import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram_codec.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:test/test.dart';

void main() {
  group(Utf8DatagramCodec, () {
    const codec = const Utf8DatagramCodec();
    const address = '127.0.0.1';
    const port = 1;

    group('encode', () {
      test('should encode a non-data datagram', () {
        final datagram = const Datagram(DatagramType.ACK, address, port);
        expect(codec.encode(datagram), utf8Encode('1:$address:$port:'));
      });

      test('should encode a data datagram', () {
        final datagram = const DataDatagram(address, port, const [123], 7);
        expect(codec.encode(datagram), utf8Encode('3:$address:$port:7:[123]:'));
      });
    });

    group('decode', () {
      test('should decode a non-data datagram', () {
        final datagram = const Datagram(DatagramType.ACK, address, port);
        expect(codec.decode(codec.encode(datagram)), datagram);
      });

      test('should decode a data datagram', () {
        final datagram =
            const DataDatagram(address, port, const [12, 345, 6], 7);
        expect(codec.decode(codec.encode(datagram)), datagram);
      });
    });
  });
}
