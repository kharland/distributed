import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/src/database/serializer.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';

/// A partial [PortDaemon] implementation that excludes http-server specifics.
class DatabaseHelpers {
  static final Ports _ports = new Ports();

  Database<String, Int64> _database;
  final Map<String, ServerHeartbeat> _heartbeats = <String, ServerHeartbeat>{};
  final Logger _logger = new Logger('$DatabaseHelpers');

  //TODO: Initialize heartbeats for nodes that are already in the database.

  set database(Database<String, Int64> value) {
    _database = value;
  }

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _database.keys.toSet();

  void acknowledgeNodeIsAlive(String name) {
    if (_heartbeats.containsKey(name)) {
      _heartbeats[name].beat();
    }
  }

  void clearDatabase() {
    var keys = _database.keys.toList();
    for (var key in keys) {
      _database.remove(key);
    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<int> registerNode(String name) async {
    Int64 port;
    if ((port = new Int64(await lookupPort(name))) > 0) {
      throw new ArgumentError('$name is already registered to port $port');
    }
    port =
        await _database.insert(name, new Int64(await _ports.getUnusedPort()));
    _heartbeats[name] = new ServerHeartbeat(name)
      ..onFlatline.listen(deregisterNode);
    _logger.info("Registered $name to port $port");
    return port.toInt();
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String name) async {
    Int64 port;
    if ((port = new Int64(await lookupPort(name))) < Int64.ZERO) {
      throw new Exception('Unable to deregister unregistered node $name');
    }
    await _database.remove(name);

    var heartbeat = _heartbeats.remove(name);
    if (heartbeat.isFlatlined) {
      _logger.info("Deregistered unresponsive node $name from port $port");
    } else {
      heartbeat.flatline(notify: false);
      _logger.info("Deregistered node $name from port $port");
    }
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> lookupPort(String nodeName) async =>
      (await _database.get(nodeName))?.toInt() ?? Ports.error;
}

class NodeDatabase extends MemoryDatabase<String, Int64> {
  NodeDatabase(File databaseFile)
      : super(databaseFile,
            recordSerializer: new RecordSerializer(
              new StringSerializer(),
              new Int64Serializer(),
            ));
}

/// Do not extend this class.
class ServerHeartbeat {
  static const period = const Duration(seconds: 3);

  final StreamController<String> _flatlineController =
      new StreamController<String>();
  final Duration _duration = period;
  final String nodeName;

  Timer _timer;

  ServerHeartbeat(this.nodeName) {
    beat();
  }

  /// Whether this [ServerHeartbeat] has flatlined.
  bool get isFlatlined => _flatlineController.isClosed;

  /// A singleton stream that emits when [beat]
  Stream<String> get onFlatline => _flatlineController.stream;

  /// Prevents flatlining for one more duration.
  void beat() {
    _errorIfFlatlined();
    _timer?.cancel();
    _timer = new Timer(_duration, flatline);
  }

  /// Notifies subscribers that the heartbeat has died.
  ///
  /// Additionally closes [onFlatline] after emitting a single event.
  void flatline({bool notify: true}) {
    _errorIfFlatlined();
    _timer.cancel();
    if (notify) {
      _flatlineController.add(nodeName);
    }
    _flatlineController.close();
  }

  void _errorIfFlatlined() {
    if (isFlatlined) {
      throw new StateError("$ServerHeartbeat has already flatlined");
    }
  }
}
