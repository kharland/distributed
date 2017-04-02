import 'dart:async';

import 'package:distributed/src/monitoring/signal_monitor.dart';
import 'package:distributed/src/port_daemon/database.dart';
import 'package:distributed/src/port_daemon/database_errors.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.objects/private.dart';

const errorPortList = const <int>[Ports.error, Ports.error];

/// A database used by a [PortDaemon] for keeping track of registered nodes.
class NodeDatabase {
  final _nodeNameToSignalMonitor = <String, SignalMonitor>{};
  final _delegateDatabase = new MemoryDatabase<String, int>();
  final _onDeregistered = new StreamController<String>(sync: true);

  /// The set of names of all nodes registered with this daemon.
  Set<String> get nodes => _delegateDatabase.keys.toSet();

  /// A stream of names for nodes that are deregistered from this database.
  Stream<String> get onDeregistered => _onDeregistered.stream;

  /// Assigns a port to a new node named [name].
  ///
  /// Returns a future that completes with the node's [Registration]. If
  /// registration succeeded, the returned registration's port will contain
  /// the newly assigned port and its error will be empty.  If registration
  /// failed, its port will be [Ports.error] and its error will contain the
  /// corresponding error message.
  /// [Ports.error] if registration failed.
  Future<Registration> registerNode(String name) async {
    final nodeReg = await _obtainPortForEntity(name);
    if (nodeReg.error.isNotEmpty) {
      return $registration(errorPortList, nodeReg.error);
    }

    final controlServerReg =
        await _obtainPortForEntity(_getControlServerName(name));
    if (controlServerReg.error.isNotEmpty) {
      return $registration(errorPortList, controlServerReg.error);
    }

    return $registration([nodeReg.port, controlServerReg.port], NO_ERROR);
  }

  /// Frees the port held by the node named [name].
  ///
  /// An argument error is thrown if such a node does not exist.
  Future<String> deregisterNode(String name) async {
    var nodeResourceMonitor = _nodeNameToSignalMonitor.remove(name);
    if (nodeResourceMonitor?.isAlive == true) {
      await nodeResourceMonitor.stop();
    }
    return _freeEntityPort(name);
  }

  /// Returns the port for the node named [nodeName].
  ///
  /// If no node is found, returns [Ports.error].
  Future<int> getPort(String nodeName) async =>
      await _delegateDatabase.get(nodeName) ?? Ports.error;

  Future<int> getControlServerPort(String nodeName) async =>
      await _delegateDatabase.get(_getControlServerName(nodeName)) ??
      Ports.error;

  Future<_PortRegistration> _obtainPortForEntity(String name) async {
    if (await _isRegistered(name)) {
      return new _PortRegistration.failed(ALREADY_EXISTS);
    }

    int port = await Ports.getFreePort();
    if (port == Ports.error) {
      throw new Exception(NO_AVAILABLE_PORT);
    }

    return new _PortRegistration(await _delegateDatabase.insert(name, port));
  }

  Future<String> _freeEntityPort(String name) async {
    if (!await _isRegistered(name)) return NODE_NOT_FOUND;
    await _delegateDatabase.remove(name);
    _onDeregistered.add(name);
    return NO_ERROR;
  }

  String _getControlServerName(String name) => '${name}_control_server';

  Future<bool> _isRegistered(String name) async => await getPort(name) >= 0;
}

class _PortRegistration {
  final String error;
  final int port;

  _PortRegistration(this.port) : error = NO_ERROR;
  _PortRegistration.failed(this.error) : this.port = Ports.error;
}
