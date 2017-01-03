import 'dart:async';
import 'dart:io';

import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'src/database/database.dart';
import 'src/database/serializer.dart';

/// An interface for interacting with the database of nodes registered to the
/// local port mapping daemon.
class Daemon {
  static final Ports _ports = new Ports();

  final Database<String, Int64> _database;
  final Map<String, ServerHeartbeat> _heartbeats = <String, ServerHeartbeat>{};

  Daemon(this._database);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _database.keys.toSet();

  void acknowledgeNodeIsAlive(String name) {
    if (_heartbeats.containsKey(name)) {
      _heartbeats[name].beat();
    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<Int64> registerNode(String name) async {
    Int64 port;
    if ((port = await lookupPort(name)) > Int64.ZERO) {
      throw new ArgumentError('$name is already registered to port $port');
    }
    port = await _database.insert(name, await _ports.getUnusedPort());
    _heartbeats[name] = new ServerHeartbeat(name)
      ..onFlatline.listen(deregisterNode);
    return port;
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future<Null> deregisterNode(String name) async {
    if (await lookupPort(name) < Int64.ZERO) {
      throw new ArgumentError('$name is not registered');
    }
    await _database.remove(name);

    var heartbeat = _heartbeats.remove(name);
    if (!heartbeat.isFlatlined) {
      heartbeat.flatline(notify: false);
    }
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns Ports.INVALID_PORT.
  Future<Int64> lookupPort(String nodeName) async =>
      await _database.get(nodeName) ?? Ports.invalidPort;
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
  static const defaultDuration = const Duration(seconds: 3);

  final StreamController<String> _flatlineController =
      new StreamController<String>();
  final Duration _duration;
  final String nodeName;

  Timer _timer;

  ServerHeartbeat(this.nodeName, [Duration duration = defaultDuration])
      : _duration = duration {
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
