import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.monitoring/keep_alive.dart';
import 'package:distributed.objects/objects.dart';

/// Monitors a [Connection] by periodically sending and expecting messages.
///
/// [onDead] completes when the remote or local connection is closed. This class
/// is necessary because a web socket's done future will never complete simply
/// because the remote end of the socket is closed.  The socket must be
/// explicitly closed.
class ConnectionMonitor {
  static const _monitor = 'monitor';

  final KeepAlive _keepAlive = new KeepAlive('');
  Future<Null> _onDeadFuture;

  ConnectionMonitor(Connection connection) {
    _onDeadFuture = _keepAlive.onDead.first.then((_) {});
    // If the connection closes, stop monitoring.
    connection.done.then((_) {
      stop();
    });
    _expectPeriodicMessages(connection);
    _sendPeriodicMessages(connection);
  }

  /// Completes after [stop] is called or the remote connection is closed.
  Future<Null> get onDead => _onDeadFuture;

  /// Shuts down this monitor.
  void stop() {
    if (!_keepAlive.isDead) {
      _keepAlive.letDie();
    }
  }

  void _expectPeriodicMessages(Connection connection) {
    _onDeadFuture.then((_) {
      connection.close();
    });
    connection.system.stream.where((m) => m.category == _monitor).forEach((_) {
      _keepAlive.keepAlive();
    });
  }

  void _sendPeriodicMessages(Connection connection) {
    var timer = new Timer.periodic(KeepAlive.time, (_) {
      connection.system.sink.add(createMessage(_monitor, ''));
    });
    _onDeadFuture.then((_) {
      timer.cancel();
    });
  }
}
