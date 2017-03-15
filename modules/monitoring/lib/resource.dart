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

/// An object that expects a periodic signal from some remote resource.
///
/// If the remote resource fails to notify this monitor that it is available,
/// the monitor will announce that the resources is gone.
class ResourceMonitor<T> {
  /// The name of the resource.
  final String resource;

  final _stopMemo = new AsyncMemoizer();
  final _goneCompleter = new Completer<String>();
  final int _numRetries;
  final Duration _pingInterval;

  StreamSubscription<T> _subscription;
  int _currentRetries = 0;
  Timer _timer;

  /// Creates a new [ResourceMonitor].
  ///
  /// [numRetries] is the number of signals that can be missed before a resource
  /// is considered unavailable. [pingInterval] is the duration allowed
  /// between successive signals.
  ResourceMonitor(
    this.resource,
    Stream<T> stream, {
    int numRetries: _defaultNumRetries,
    Duration pingInterval: _defaultPingInterval,
  })
      : _numRetries = numRetries,
        _pingInterval = pingInterval {
    _restartTimer();
    _subscription = stream.listen((_) {
      _acknowledgeSignal();
    });
  }

  /// Whether [resource] is still available.
  bool get isAvailable => !_goneCompleter.isCompleted;

  /// A future that completes when this monitor is stopped or [resource] is no
  /// longer available.
  Future<String> get onGone => _goneCompleter.future;

  /// Stops monitoring [resource].
  Future stop() => _stopMemo.runOnce(() {
        _subscription.cancel();
        _timer.cancel();
        _goneCompleter.complete(resource);
      });

  /// Acknowledges that a signal has been received from [resource].
  void _acknowledgeSignal() {
    _errorIfGone();
    _currentRetries = 0;
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = new Timer.periodic(_pingInterval, (_) {
      if (++_currentRetries > _numRetries) {
        stop();
      }
    });
  }

  void _errorIfGone() {
    if (!isAvailable) {
      throw new StateError("$resource is not available");
    }
  }
}
