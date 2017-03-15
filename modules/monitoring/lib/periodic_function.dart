import 'dart:async';
import 'package:async/async.dart';

const _defaultNumRetries = 3;
const _defaultPingInterval = const Duration(milliseconds: 500);

/// A function that calls another function periodically.
class PeriodicFunction {
  /// The name of the resource.
  final String name;
  final _stopMemo = new AsyncMemoizer();
  final Duration _pingInterval;
  Timer _timer;

  /// Creates a new [PeriodicFunction].
  ///
  /// [callback] is the function to call.  [period] is the duration between
  /// successive calls.
  PeriodicFunction(
    this.name,
    void callback(), {
    Duration period: _defaultPingInterval,
  })
      : _pingInterval = period {
    _callPeriodically(callback);
  }

  /// Stops calling the given function.
  void stop() {
    _stopMemo.runOnce(() {
      _timer.cancel();
    });
  }

  /// Periodically calls [notify].
  void _callPeriodically(void notify()) {
    _timer = new Timer.periodic(_pingInterval, (_) {
      notify();
    });
  }
}