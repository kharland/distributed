import 'package:distributed.monitoring/signal_monitor.dart';
import 'package:quiver/testing/async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

void main() {
  group('$SignalMonitor', () {
    SignalMonitor monitor;
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
        monitor = new SignalMonitor(controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        for (int currentRetry = 0; currentRetry < numRetries; currentRetry++) {
          fakeAsync.elapse(pingInterval * 1.1);
          expect(monitor.isAlive, currentRetry <= numRetries);
        }
      });
    });

    test('onGone should complete when the resource becomes unavailable', () {
      var numRetries = 3;
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        monitor = new SignalMonitor(controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        expect(monitor.gone, completes);
        fakeAsync.elapse(pingInterval * (numRetries + 1));
      });
    });

    test('stop should stop monitoring the resource', () {
      var numRetries = 3;
      var pingInterval = const Duration(milliseconds: 100);

      new FakeAsync().run((fakeAsync) {
        monitor = new SignalMonitor(controller.local.stream,
            numRetries: numRetries, pingInterval: pingInterval);
        expect(monitor.isAlive, true);
        expect(monitor.gone, completes);
        monitor.stop().then(expectAsync1((_) {
          expect(monitor.isAlive, false);
        }));
        fakeAsync.flushMicrotasks();
      });
    });
  });
}
