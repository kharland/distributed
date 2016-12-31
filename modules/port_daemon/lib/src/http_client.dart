import 'dart:async';

import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/http_server.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:fixnum/fixnum.dart';
import 'package:seltzer/seltzer.dart';

class DaemonClient {
  final HttpWithTimeout _http = new HttpWithTimeout();
  final SeltzerHttp _seltzer;
  final String cookie;
  final String hostname;
  final Int64 port;

  DaemonClient(
    this._seltzer, {
    this.hostname: DaemonServer.defaultHostname,
    int port: DaemonServer.defaultPort,
    this.cookie: DaemonServer.defaultCookie
  })
      : this.port = new Int64(port);

  /// Pings the daemon server.
  ///
  /// Returns a future that completes with true iff a response was received.
  Future<bool> isDaemonRunning([void log(String message) = print]) async {
    var responseCompleter = new Completer<bool>();
    runZoned(() async {
      await _http.send(_seltzer.get(_url('ping')));
      responseCompleter.complete(true);
    }, onError: (error) {
      log('[ERROR]: $error');
      responseCompleter.complete(false);
    });
    return responseCompleter.future;
  }

  /// Returns a mapping of node name -> port of the daemon server registrants.
  ///
  /// Returns an empty map if no nodes are registered or if an error occurred.
  Future<Map<String, int>> listNodes([void log(String message) = print]) async {
    var assignmentsCompleter = new Completer<Map<String, int>>();
    runZoned(() async {
      var response = await _http.send(_seltzer.get(_url('list/node')));
      var assignments =
          new PortAssignmentList.fromString(response.readAsString());
      assignmentsCompleter.complete(assignments.assignments);
    }, onError: (error, stacktrace) {
      log(error);
      assignmentsCompleter.complete({});
    });
    return assignmentsCompleter.future;
  }

  /// Request the port for the node named [name].
  ///
  /// Returns Ports.INVALID_PORT if no such node is registered with the daemon.
  Future<Int64> lookupNode(String name, [void log(String message) = print]) {
    var portCompleter = new Completer<Int64>();
    runZoned(() async {
      var response = await _http.send(_seltzer.get(_url('node/$name')));
      portCompleter.complete(Int64.parseInt(response.readAsString()));
    }, onError: (error) {
      log(error);
      portCompleter.complete(Ports.INVALID_PORT);
    });
    return portCompleter.future;
  }

  /// Instructs the daemon server to register [name] under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or Ports.INVALID_PORT if it failed.
  Future<Int64> registerNode(String name, [void log(String message) = print]) {
    var portCompleter = new Completer<Int64>();
    runZoned(() async {
      var response = await _http.send(_seltzer.post(_url('node/$name')));
      var result = new RegistrationResult.fromString(response.readAsString());
      portCompleter.complete(result.port);
    }, onError: (error) {
      log(error);
      portCompleter.complete(Ports.INVALID_PORT);
    });
    return portCompleter.future;
  }

  /// Instructs the daemon server to deregister [name].
  ///
  /// Returns a future that completes with true iff deregistration succeeeded.
  Future<bool> deregisterNode(String name, [void log(String message) = print]) {
    var resultCompleter = new Completer<bool>();
    runZoned(() async {
      var response = await _http.send(_seltzer.delete(_url('node/$name')));
      var result = new DeregistrationResult.fromString(response.readAsString());
      resultCompleter.complete(!result.failed);
    }, onError: (error) {
      log(error);
      resultCompleter.complete(false);
    });
    return resultCompleter.future;
  }

  String _url(String route) =>
      '${DaemonServer.url(hostname, port)}/$route/$cookie';
}

class HttpWithTimeout {
  static const _defaultTimeout = const Duration(seconds: 3);

  final Duration _timeoutDuration;

  HttpWithTimeout({Duration timeout: _defaultTimeout})
      : _timeoutDuration = timeout;

  Future<SeltzerHttpResponse> send(
    SeltzerHttpRequest request, [
    Object payload,
  ]) {
    var timeout = new Timer(_timeoutDuration, () {
      throw new TimeoutException(request.toString());
    });
    return request.send().first.then((response) {
      timeout.cancel();
      return response;
    });
  }
}
