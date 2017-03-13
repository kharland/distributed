import 'dart:async';

/// A signal for communicating that a node is still available.
///
/// If a node does not ping the daemon repeatedly in [KeepAlive.time] second
/// intervals,  it is automatically deregistered from the daemon.
///
/// Do not extend this class.
class KeepAlive {
  /// The time between successive signals.
  static const time = const Duration(seconds: 1);

  /// The number of signals that can be missed before a node is considered dead.
  static const _numRetries = 3;

  /// The name of the node sending signals for this [KeepAlive].
  final String name;

  // ...have you ever heard the tale of Darth Plagueis the wise?
  final _deathController = new StreamController<String>();

  int _currentRetries = 0;
  Timer _timer;

  KeepAlive(this.name) {
    keepAlive();
  }

  bool get isDead => _deathController.isClosed;

  /// A stream that emits when a signal has not been received in [time] seconds.
  Stream<String> get onDead => _deathController.stream;

  /// Acknowledges that a signal has been received.
  void keepAlive() {
    _errorIfDead();
    _currentRetries = 0;
    _timer?.cancel();
    _timer = new Timer.periodic(time, (_) {
      if (++_currentRetries > _numRetries) {
        letDie();
      }
    });
  }

  /// Stops listening for signals.
  ///
  /// Additionally closes [onDead] after emitting a single event.
  Future letDie({bool notify: true}) {
    _errorIfDead();
    _timer.cancel();
    if (notify) {
      _deathController.add(name);
    }
    return _deathController.close();
  }

  void _errorIfDead() {
    if (isDead) {
      throw new StateError("$KeepAlive is already dead");
    }
  }
}
