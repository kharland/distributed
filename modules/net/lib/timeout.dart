import 'dart:async';

class Timeout {
  static const defaultDuration = const Duration(seconds: 3);

  final Timer _timer;

  Timeout(void onTimeout(), {Duration duration: defaultDuration})
      : _timer = new Timer(duration, onTimeout);

  void cancel() {
    _timer.cancel();
  }
}

class TimeoutError implements Exception {
  final String message;

  TimeoutError([this.message = '']);
}
