import 'dart:async';

import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/daemon_server_info.dart';
import 'package:distributed.port_daemon/src/http_with_timeout.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

class DaemonClient {
  final String name;
  final DaemonServerInfo serverInfo;

  final HttpWithTimeout _http = new HttpWithTimeout();
  final SeltzerHttp _seltzer;
  final Logger _logger = new Logger('$DaemonClient');

  Timer _heartbeatTimer;

  DaemonClient(this.name, this.serverInfo) : _seltzer = const VmSeltzerHttp();

  void startHeartbeat() {
    var period = ServerHeartbeat.period ~/ 2;
    _heartbeatTimer = new Timer.periodic(period, (_) {
      pingDaemon();
    });
  }

  void stopHeartBeat() {
    assert(_heartbeatTimer != null);
    _heartbeatTimer.cancel();
  }

  /// Pings the daemon server.
  ///
  /// Returns a future that completes with true iff a response was received.
  Future<bool> pingDaemon() async {
    var responseCompleter = new Completer<bool>();
    try {
      await _http.send(_seltzer.get(_createRequestUrl('ping/$name')));
      responseCompleter.complete(true);
    } catch (e) {
      responseCompleter.complete(false);
    }
    return responseCompleter.future;
  }

  /// Returns a mapping of node name -> port of the daemon server registrants.
  ///
  /// Returns an empty map if no nodes are registered or if an error occurred.
  Future<Map<String, int>> listNodes() async {
    var assignmentsCompleter = new Completer<Map<String, int>>();
    try {
      var response =
          await _http.send(_seltzer.get(_createRequestUrl('list/node')));
      var assignments =
          new PortAssignmentList.fromString(await response.readAsString());
      assignmentsCompleter.complete(assignments.assignments);
    } catch (e) {
      assignmentsCompleter.complete({});
    }
    return assignmentsCompleter.future;
  }

  /// Request the port for the node named [name].
  ///
  /// Returns Ports.INVALID_PORT if no such node is registered with the daemon.
  Future<Int64> lookupNode(String name) async {
    if (!await pingDaemon()) {
      throw new Exception('No deamon running at ${serverInfo.url}');
    }
    var portCompleter = new Completer<Int64>();
    try {
      var response =
          await _http.send(_seltzer.get(_createRequestUrl('node/$name')));
      portCompleter.complete(Int64.parseInt(await response.readAsString()));
    } catch (e) {
      portCompleter.complete(Ports.invalidPort);
    }
    return portCompleter.future;
  }

  /// Instructs the daemon server to register [name] under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or Ports.INVALID_PORT if it failed.
  Future<Int64> registerNode(String name) async {
    var portCompleter = new Completer<Int64>();
    try {
      var response =
          await _http.send(_seltzer.post(_createRequestUrl('node/$name')));
      var result =
          new RegistrationResult.fromString(await response.readAsString());
      portCompleter.complete(result.port);
    } catch (e) {
      _logger.severe(e);
      portCompleter.complete(Ports.invalidPort);
    }
    return portCompleter.future;
  }

  /// Instructs the daemon server to deregister [name].
  ///
  /// Returns a future that completes with true iff deregistration succeeeded.
  Future<bool> deregisterNode(String name) async {
    var resultCompleter = new Completer<bool>();
    try {
      var response =
          await _http.send(_seltzer.delete(_createRequestUrl('node/$name')));
      var result =
          new DeregistrationResult.fromString(await response.readAsString());
      resultCompleter.complete(!result.failed);
    } catch (e) {
      resultCompleter.complete(false);
    }
    return resultCompleter.future;
  }

  String _createRequestUrl(String route) => '${serverInfo.url}/$route';
}
