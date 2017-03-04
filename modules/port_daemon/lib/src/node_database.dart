import 'dart:async';

import 'package:distributed.monitoring/keep_alive.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/src/ports.dart';

/// A database used by a [PortDaemon] for keeping track of registered nodes.
class NodeDatabase {
  final _nodeNameToKeepAlive = <String, KeepAlive>{};
  final _delegateDatabase = new MemoryDatabase<String, int>();

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _delegateDatabase.keys.toSet();

  /// Signals that node [name] is still available.
  void keepAlive(String name) {
    if (_nodeNameToKeepAlive.containsKey(name)) {
      _nodeNameToKeepAlive[name].ack();
    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<int> registerNode(String name) async {
    int port;
    if ((port = await getPort(name)) > 0) {
      globalLogger.error('$name is already registered to port $port');
      return Ports.error;
    }
    port = await _delegateDatabase.insert(name, await Ports.getUnusedPort());
    _nodeNameToKeepAlive[name] = new KeepAlive(name)
      ..onDead.listen(deregisterNode);
    globalLogger.log("Registered $name to port $port");
    return port;
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future deregisterNode(String name) async {
    int port;
    if ((port = await getPort(name)) < 0) {
      globalLogger.log('Unable to deregister unregistered node $name');
      return;
    }
    await _delegateDatabase.remove(name);

    var keepAlive = _nodeNameToKeepAlive.remove(name);
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
  Future<int> getPort(String nodeName) async =>
      (await _delegateDatabase.get(nodeName))?.toInt() ?? Ports.error;
}
