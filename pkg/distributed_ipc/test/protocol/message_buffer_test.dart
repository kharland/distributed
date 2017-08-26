import 'package:distributed.ipc/src/vm/lazy_message_converter.dart';
import 'package:distributed.ipc/src/message_buffer.dart';
import 'package:test/test.dart';

void main() {
  group(MessageBuffer, () {
    MessageBuffer receiver;

    setUp(() {
      receiver = new MessageBuffer();
    });

    test('should reassemble a fragmented message', () {
      const message = 'Hello, World! This is Doggo.  How are you?  Borq Borq.';
      final converter = new LazyMessageConverter(message, 1);

      while (converter.moveNext()) {
        receiver.add(converter.current);
      }
      expect(receiver.toString(), message);
    });
  });
}
