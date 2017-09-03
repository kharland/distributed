import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:test/test.dart';

void main() {
  group(EventSource, () {
    EventSource<int> bus;

    setUp(() {
      bus = new EventSource<int>();
    });

    test('should notify each consumer when emitting an event', () {
      bus.onEvent(expectAsync1((data) {
        expect(data, 1);
      }, count: 3));

      bus.emit(1);

      bus.onEvent(expectAsync1((data) {
        expect(data, 1);
      }, count: 2));

      bus..emit(1)..emit(1);
    });
  });
}
