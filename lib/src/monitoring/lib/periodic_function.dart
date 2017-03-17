import 'dart:async';

const _defaultNumRetries = 3;
const _defaultPeriod = const Duration(milliseconds: 500);

/// A function that calls another function periodically.
class PeriodicFunction {
  /// The name of the resource.
  final Duration _period;
  Timer _timer;

  /// Creates a new [PeriodicFunction].
  ///
  /// [callback] is the function to call.  [period] is the duration between
  /// successive calls.
  PeriodicFunction(
    void callback(), {
    Duration period: _defaultPeriod,
  })
      : _period = period {
    _callPeriodically(callback);
  }

  /// Stops calling the given function.
  void stop() {
    _timer.cancel();
  }

  /// Periodically calls [notify].
  void _callPeriodically(void notify()) {
    _timer = new Timer.periodic(_period, (_) {
      notify();
    });
  }
}
