import 'package:distributed.ipc/src/udp/data_builder.dart';
import 'package:test/test.dart';

void main() {
  group(DataBuilder, () {
    const builder = const DataBuilder();

    test('should assemble and disassmble a message', () {
      final message = 'Hello world!';
      final parts = [
        [72],
        [101],
        [108],
        [108],
        [111],
        [32],
        [119],
        [111],
        [114],
        [108],
        [100],
        [33],
      ];
      expect(builder.splitIntoParts(message), parts);
      expect(builder.assembleParts(parts), message);
    });
  });
}
