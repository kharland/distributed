import 'package:distributed.ipc/src/protocol/lazy_message_converter.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';
import 'package:test/test.dart';

void main() {
  group(LazyMessageConverter, () {
    LazyMessageConverter converter;

    const part1 = 'This';
    const part2 = ' is ';
    const part3 = 'dog.';
    const part4 = ':)';

    void commonSetUp([int bytesPerPacket]) {
      bytesPerPacket ??= utf8Encode(part1).length;
      converter = new LazyMessageConverter(
        '$part1$part2$part3$part4',
        bytesPerPacket,
      );
    }

    ;

    test('should progressively convert a string into a series of packets', () {
      commonSetUp();

      converter.moveNext();
      expect(
        converter.current.toBytes(),
        new MSGPacket(utf8Encode(part1)).toBytes(),
      );

      converter.moveNext();
      expect(
        converter.current.toBytes(),
        new MSGPacket(utf8Encode(part2)).toBytes(),
      );

      converter.moveNext();
      expect(
        converter.current.toBytes(),
        new MSGPacket(utf8Encode(part3)).toBytes(),
      );

      converter.moveNext();
      expect(
        converter.current.toBytes(),
        new MSGPacket(utf8Encode(part4)).toBytes(),
      );

      converter.moveNext();
      expect(converter.current, null);
    });

    test('should convert a message smaller than the max specified packet size',
        () {
      commonSetUp(1000);

      converter.moveNext();
      expect(
        converter.current.toBytes(),
        new MSGPacket(utf8Encode('$part1$part2$part3$part4')).toBytes(),
      );

      converter.moveNext();
      expect(converter.current, null);
    });
  });
}
