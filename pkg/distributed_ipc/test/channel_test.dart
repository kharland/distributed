import 'dart:async';
import 'package:distributed.ipc/ipc.dart';
import 'package:test/test.dart';

void main() {
  group(Channel, () {
    Channel channel;

    test("add should send a message with the channel's id", () {
      channel = new Channel('test', (id, message) {
        expect(id, 'test');
        expect(message, 'A');
      }, new Stream<String>.empty());

      channel.add('A');
    });

    test('should emit messages from the given stream', () {
      const messages = const <String>['A', 'B'];
      channel = new Channel(
        'test',
            (_, __) {},
        new Stream.fromIterable(messages),
      );

      expect(channel, emitsInOrder(messages));
    });
  });
}
