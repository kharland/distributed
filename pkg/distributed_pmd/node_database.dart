import 'dart:async';

import 'package:distributed/src/port_daemon/database.dart';
import 'package:distributed/src/port_daemon/database_errors.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed.objects/objects.dart';

/// A database used by a [PortDaemon] for keeping track of registered nodes.
class NodeDatabase {
  final _delegate = new MemoryDatabase<String, int>();
  final _onDeregistered = new StreamController<String>(sync: true);

  /// A stream of names for nodes that are deregistered from this database.
  Stream<String> get onDeregistered => _onDeregistered.stream;

  /// Returns a list of nodes registered in this database.
  List<String> get registrants => new List.unmodifiable(_delegate.keys);

  /// Returns the ports register for [nodeName].
  Future<NodePorts> getPorts(String nodeName) async => new NodePorts(
      await _getEntityPort(nodeName),
      await _getEntityPort(_getControlServerName(nodeName)),
      await _getEntityPort(_getDiagnosticServerName(nodeName)));

  /// Registers [node] with the specified [ports].
  ///
  /// Returns a future that completes with the error message if registration
  /// failed, or the empty string if it succeeded.
  Future<String> registerNode(String node, NodePorts ports) async {
    var controlServerName = _getControlServerName(node);
    var diagnosticServerName = _getDiagnosticServerName(node);

    if (await getPorts(node) == NodePorts.Null) {
      await _registerEntity(node, ports.connectionPort);
      await _registerEntity(controlServerName, ports.controlPort);
      await _registerEntity(diagnosticServerName, ports.diagnosticPort);
      return NO_ERROR;
    } else {
      return NODE_ALREADY_EXISTS;
    }
  }

  /// Deregisters [node].
  ///
  /// Returns a future that completes with the error message if registration
  /// failed, or the empty string if it succeeded.
  Future deregisterNode(String node) async {
    var controlServerName = _getControlServerName(node);
    var diagnosticServerName = _getDiagnosticServerName(node);
    await _deregisterEntity(node);
    await _deregisterEntity(controlServerName);
    await _deregisterEntity(diagnosticServerName);
  }

  Future<bool> _registerEntity(String name, int port) async {
    var completer = new Completer();
    runZoned(() async {
      await _delegate.insert(name, port);
      completer.complete(true);
    }, onError: (_) {
      completer.complete(false);
    });
    return completer.future;
  }

  Future<bool> _deregisterEntity(String name) async {
    var completer = new Completer();
    runZoned(() async {
      await _delegate.remove(name);
      completer.complete(true);
    }, onError: (_) {
      completer.complete(false);
    });
    return completer.future;
  }

  Future<int> _getEntityPort(String name) async {
    var completer = new Completer<int>();
    runZoned(() async {
      completer.complete(await _delegate.get(name) ?? -1);
    }, onError: (_) {
      completer.complete(-1);
    });
    return completer.future;
  }

  String _getControlServerName(String name) => '${name}_control';
  String _getDiagnosticServerName(String name) => '${name}_diagnostic';
}
