import 'dart:async';

import 'package:distributed.port_mapping_daemon/src/api.dart';
import 'package:distributed.port_mapping_daemon/src/http_server.dart';
import 'package:seltzer/seltzer.dart';

class DaemonClient {
  final HttpWithTimeout _http = new HttpWithTimeout();
  final SeltzerHttp _seltzer;
  final String cookie;
  final String hostname;
  final int port;

  DaemonClient(
    this._seltzer, {
    this.hostname: DaemonServer.defaultHostname,
    this.port: DaemonServer.defaultPort,
    this.cookie: DaemonServer.defaultCookie,
  });

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
  /// Returns -1 if no such node is registered with the daemon.
  Future<int> lookupNode(String name, [void log(String message) = print]) {
    var portCompleter = new Completer<int>();
    runZoned(() async {
      var response = await _http.send(_seltzer.get(_url('node/$name')));
      portCompleter.complete(int.parse(response.readAsString()));
    }, onError: (error) {
      log(error);
      portCompleter.complete(-1);
    });
    return portCompleter.future;
  }

  /// Instructs the daemon server to register [name] under a new port.
  ///
  /// Returns a Future that completes with the new port if registration
  /// succeeded or -1 if it failed.
  Future<int> registerNode(String name, [void log(String message) = print]) {
    var portCompleter = new Completer<int>();
    runZoned(() async {
      var response = await _http.send(_seltzer.post(_url('node/$name')));
      var result = new RegistrationResult.fromString(response.readAsString());
      portCompleter.complete(result.port);
    }, onError: (error) {
      log(error);
      portCompleter.complete(-1);
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
