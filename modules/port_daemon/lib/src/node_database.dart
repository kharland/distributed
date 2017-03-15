import 'dart:async';

import 'package:distributed.monitoring/resource.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.port_daemon/port_daemon.dart';
import 'package:distributed.port_daemon/src/database/database.dart';
import 'package:distributed.port_daemon/ports.dart';

/// A database used by a [PortDaemon] for keeping track of registered nodes.
class NodeDatabase {
  final _nodeNameToMonitor = <String, ResourceMonitor>{};
  final _nodeNameToKeepAliveStream = <String, StreamController<Null>>{};
  final _delegateDatabase = new MemoryDatabase<String, int>();
  final Logger _logger;

  NodeDatabase(this._logger);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _delegateDatabase.keys.toSet();

  /// Signals that node [name] is still available.
  void keepAlive(String name) {
    if (_nodeNameToKeepAliveStream.containsKey(name)) {
      _nodeNameToKeepAliveStream[name].add(null);
    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the port number.
  Future<int> registerNode(String name) async {
    int port;
    if ((port = await getPort(name)) > 0) {
      _logger.error('$name is already registered to port $port');
      return Ports.error;
    }
    port = await _delegateDatabase.insert(name, await Ports.getUnusedPort());
    _nodeNameToKeepAliveStream[name] = new StreamController<Null>(sync: true);
    _nodeNameToMonitor[name] =
        new ResourceMonitor(name, _nodeNameToKeepAliveStream[name].stream)
          ..onGone.then(deregisterNode);
    _logger.log("Registered $name to port $port");
    return port;
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future<bool> deregisterNode(String name) async {
    var port = await getPort(name);
    if (port == Ports.error) {
      _logger.log('Unable to deregister unregistered node $name');
      return false;
    }
    await _delegateDatabase.remove(name);
    _nodeNameToKeepAliveStream.remove(name).close();

    var nodeResourceMonitor = _nodeNameToMonitor.remove(name);
    if (nodeResourceMonitor.isAvailable) {
      _logger.log("Deregistered unresponsive node $name from port $port");
    } else {
      await nodeResourceMonitor.stop();
      _logger.log("Deregistered node $name from port $port");
    }
    return true;
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> getPort(String nodeName) async =>
      (await _delegateDatabase.get(nodeName))?.toInt() ?? Ports.error;
}
