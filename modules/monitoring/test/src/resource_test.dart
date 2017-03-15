import 'package:distributed.monitoring/resource.dart';
import 'package:quiver/testing/async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

void main() {
  group('$ResourceMonitor', () {
    ResourceMonitor monitor;
    StreamChannelController<String> controller;

    setUp(() {
      controller = new StreamChannelController<String>();
    });

    tearDown(() {
      monitor.stop();
      controller.local.sink.close();
      controller.foreign.sink.close();
    });

    test('isAvailable should return true iff the resource is available', () {
      var numRetries = 3;
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        monitor = new ResourceMonitor('a', controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        for (int currentRetry = 0; currentRetry < numRetries; currentRetry++) {
          fakeAsync.elapse(pingInterval * 1.1);
          expect(monitor.isAvailable, currentRetry <= numRetries);
        }
      });
    });

    test('onGone should complete when the resource becomes unavailable', () {
      var numRetries = 3;
      var resource = 'a';
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        monitor = new ResourceMonitor(resource, controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        expect(monitor.onGone, completion(resource));
        fakeAsync.elapse(pingInterval * (numRetries + 1));
      });
    });

    test('stop should stop monitoring the resource', () {
      var numRetries = 3;
      var resource = 'a';
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        monitor = new ResourceMonitor(resource, controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        expect(monitor.isAvailable, true);
        expect(monitor.onGone, completion(resource));
        monitor.stop().then(expectAsync1((_) {
          expect(monitor.isAvailable, false);
        }));
        fakeAsync.flushMicrotasks();
      });
    });
  });
}
