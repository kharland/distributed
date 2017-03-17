import 'package:distributed.monitoring/periodic_function.dart';
import 'package:quiver/testing/async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

void main() {
  group('$PeriodicFunction', () {
    PeriodicFunction resource;
    StreamChannelController<String> controller;

    setUp(() async {
      controller = new StreamChannelController<String>();
    });

    tearDown(() async {
      resource?.stop();
      controller.local.sink.close();
      controller.foreign.sink.close();
    });

    test('should periodically notify it is available', () async {
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        resource = new PeriodicFunction(() => controller.local.sink.add(null),
            period: pingInterval);
        expect(controller.foreign.stream, emitsInOrder([null, null, null]));
        fakeAsync.elapse(pingInterval * 10);
      });
    });

    test('should stop emitting after goAway is called', () async {
      var pingInterval = const Duration(milliseconds: 100);
      var streamEvents = <String>[];
      controller.foreign.stream.forEach(streamEvents.add);

      new FakeAsync().run((fakeAsync) {
        resource = new PeriodicFunction(() => controller.local.sink.add(null),
            period: pingInterval);
        fakeAsync.elapse(pingInterval * 3.5);
        expect(streamEvents, [null, null, null]);

        resource.stop();
        fakeAsync.elapse(pingInterval * 100);
        expect(streamEvents, [null, null, null]);
      });
    });
  });
}
