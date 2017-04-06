import 'dart:async';

import 'package:distributed.monitoring/signal_monitor.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed/src/port_daemon/database_errors.dart';
import 'package:distributed/src/port_daemon/database.dart';

/// A database used by a [PortDaemon] for keeping track of registered nodes.
class NodeDatabase {
  final _nodeNameToMonitor = <String, SignalMonitor>{};
  final _nodeNameToKeepAlive = <String, StreamController<Null>>{};
  final _delegateDatabase = new MemoryDatabase<String, int>();
  final _onDeregistered = new StreamController<String>(sync: true);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _delegateDatabase.keys.toSet();

  /// A stream of names for nodes that are deregistered from this database.
  Stream<String> get onDeregistered => _onDeregistered.stream;

  /// Signals that the node with [name] is still available.
  void keepAlive(String name) {
//    if (_nodeNameToKeepAlive.containsKey(name)) {
//      _nodeNameToKeepAlive[name].add(null);
//    }
  }

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the node's [Registration]. If
  /// registration succeeded, the returned registration's port will contain
  /// the newly assigned port and its error will be empty.  If registration
  /// failed, its port will be [Ports.error] and its error will contain the
  /// corresponding error message.
  /// [Ports.error] if registration failed.
  Future<Registration> registerNode(String name) async {
    // Make sure no node with [name] is already registered.
    int port = await getPort(name);
    if (port >= 0) {
      return $registration(Ports.error, NODE_ALREADY_EXISTS);
    }

    // Check if a free port is available.
    port = await Ports.getUnusedPort();
    if (port == Ports.error) {
      return $registration(Ports.error, NO_AVAILABLE_PORT);
    }

    await _delegateDatabase.insert(name, port);
//    var keepAliveController = new StreamController<Null>(sync: true);
//    _nodeNameToKeepAlive[name] = keepAliveController;
//    _nodeNameToMonitor[name] = new SignalMonitor(keepAliveController.stream)
//      ..gone.then((_) {
//        keepAliveController.close();
//        deregisterNode(name);
//        _deregisterNodeServer(name);
//      });
    return $registration(port, '');
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future<String> deregisterNode(String name) async {
    var port = await getPort(name);
    if (port == Ports.error) {
      return NODE_NOT_FOUND;
    }

    await _delegateDatabase.remove(name);
    _nodeNameToKeepAlive.remove(name);
    var nodeResourceMonitor = _nodeNameToMonitor.remove(name);
    if (nodeResourceMonitor?.isAlive == true) {
      await nodeResourceMonitor.stop();
    }
    _onDeregistered.add(name);
    return NO_ERROR;
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> getPort(String nodeName) async =>
      await _delegateDatabase.get(nodeName) ?? Ports.error;

  Future<int> getServerPort(String nodeName) async =>
      await _delegateDatabase.get(_getServerName(nodeName)) ?? Ports.error;

  String _getServerName(String name) => '${name}_server';
}
