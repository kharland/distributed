import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.port_daemon/src/http_with_timeout.dart';
import 'package:distributed.port_daemon/daemon_server.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/port_daemon.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logging/logging.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

class DaemonClient {
  final String nodeName;
  final String address;
  final Int64 port;
  final Secret secret;

  final HttpWithTimeout _http = new HttpWithTimeout();
  final SeltzerHttp _seltzer;
  final Logger _logger = new Logger('$DaemonClient');
  Timer _heartbeatTimer;

  DaemonClient(
    this.nodeName, {
    this.address: DaemonServer.defaultHostname,
    this.secret: Secret.acceptAny,
    int port: DaemonServer.defaultPort,
  })
      : port = new Int64(port),
        _seltzer = const VmSeltzerHttp();

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
    runZoned(() async {
      await _http.send(_seltzer.get(_url('ping/$nodeName')));
      responseCompleter.complete(true);
    }, onError: (error) {
      _logger.info('Port daemon is unavailable');
      _logger.severe(error);
      responseCompleter.complete(false);
    });
    return responseCompleter.future;
  }

  /// Returns a mapping of node name -> port of the daemon server registrants.
  ///
  /// Returns an empty map if no nodes are registered or if an error occurred.
  Future<Map<String, int>> listNodes() async {
    var assignmentsCompleter = new Completer<Map<String, int>>();
    runZoned(() async {
      var response = await _http.send(_seltzer.get(_url('list/node')));
      var assignments =
          new PortAssignmentList.fromString(await response.readAsString());
      assignmentsCompleter.complete(assignments.assignments);
    }, onError: (error, stacktrace) {
      _logger.severe(error);
      assignmentsCompleter.complete({});
    });
    return assignmentsCompleter.future;
  }

  /// Request the port for the node named [name].
  ///
  /// Returns Ports.INVALID_PORT if no such node is registered with the daemon.
  Future<Int64> lookupNode(String name) async {
    if (!await pingDaemon()) {
      throw new Exception('No deamon running at http://$address:$port');
    }
    var portCompleter = new Completer<Int64>();
    runZoned(() async {
      var response = await _http.send(_seltzer.get(_url('node/$name')));
      portCompleter.complete(Int64.parseInt(await response.readAsString()));
    }, onError: (error) {
      _logger.severe(error);
      portCompleter.complete(Ports.invalidPort);
    });
    return portCompleter.future;
  }

  /// Instructs the daemon server to register [name] under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or Ports.INVALID_PORT if it failed.
  Future<Int64> registerNode(String name) {
    var portCompleter = new Completer<Int64>();
    runZoned(() async {
      var response = await _http.send(_seltzer.post(_url('node/$name')));
      var result =
          new RegistrationResult.fromString(await response.readAsString());
      portCompleter.complete(result.port);
    }, onError: (error) {
      _logger.severe(error);
      portCompleter.complete(Ports.invalidPort);
    });
    return portCompleter.future;
  }

  /// Instructs the daemon server to deregister [name].
  ///
  /// Returns a future that completes with true iff deregistration succeeeded.
  Future<bool> deregisterNode(String name) {
    var resultCompleter = new Completer<bool>();
    runZoned(() async {
      var response = await _http.send(_seltzer.delete(_url('node/$name')));
      var result =
          new DeregistrationResult.fromString(await response.readAsString());
      resultCompleter.complete(!result.failed);
    }, onError: (error) {
      _logger.severe(error);
      resultCompleter.complete(false);
    });
    return resultCompleter.future;
  }

  String _url(String route) =>
      '${DaemonServer.url(address, port)}/$route/$secret';
}
