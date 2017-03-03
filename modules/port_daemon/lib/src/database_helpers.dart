import 'dart:async';

import 'package:distributed.node/src/logging.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/src/ports.dart';

/// A partial [PortDaemon] implementation that excludes web-server specifics.
class DatabaseHelpers {
  final _keepAlives = <String, KeepAlive>{};
  Database<String, int> _database;

  set database(Database<String, int> value) {
    _database = value;
  }

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _database.keys.toSet();

  /// Signals that node [name] is still available.
  void keepAlive(String name) {
    if (_keepAlives.containsKey(name)) {
      _keepAlives[name].ack();
    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<int> registerNode(String name) async {
    int port;
    if ((port = await lookupPort(name)) > 0) {
      globalLogger.error('$name is already registered to port $port');
      return Ports.error;
    }
    port = await _database.insert(name, await Ports.getUnusedPort());
    _keepAlives[name] = new KeepAlive(name)..onDead.listen(deregisterNode);
    globalLogger.log("Registered $name to port $port");
    return port;
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String name) async {
    int port;
    if ((port = await lookupPort(name)) < 0) {
      globalLogger.log('Unable to deregister unregistered node $name');
    }
    await _database.remove(name);

    var keepAlive = _keepAlives.remove(name);
    if (keepAlive.isDead) {
      globalLogger.log("Deregistered unresponsive node $name from port $port");
    } else {
      await keepAlive.letDie(notify: false);
      globalLogger.log("Deregistered node $name from port $port");
    }
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> lookupPort(String nodeName) async =>
      (await _database.get(nodeName))?.toInt() ?? Ports.error;
}

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
  static const numRetries = 3;

  /// The name of the node sending signals for this [KeepAlive].
  final String name;

  // ...have you ever heard the tale of Darth Plagueis the wise?
  final _deathController = new StreamController<String>();

  int _currentRetries = 0;
  Timer _timer;

  KeepAlive(this.name) {
    ack();
  }

  bool get isDead => _deathController.isClosed;

  /// A stream that emits when a signal has not been received in [time] seconds.
  Stream<String> get onDead => _deathController.stream;

  /// Acknowledges that a signal has been received.
  void ack() {
    _errorIfDead();
    _currentRetries = 0;
    _timer?.cancel();
    _timer = new Timer.periodic(time, (_) {
      if (++_currentRetries > numRetries) {
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
