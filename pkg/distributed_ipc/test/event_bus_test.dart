import 'package:distributed.ipc/src/typedefs.dart';
import 'package:test/test.dart';

void main() {
  group(EventBus, () {
    EventBus<int> bus;

    setUp(() {
      bus = new EventBus<int>();
    });

    test('should call each callback when emitting an event', () {
      bus.onEvent(expectAsync1((data) {
        expect(data, 1);
      }, count: 3));

      bus.emit(1);

      bus.onEvent(expectAsync1((data) {
        expect(data, 1);
      }, count: 2));

      bus
        ..emit(1)
        ..emitAll([1]);
    });
  });
}
