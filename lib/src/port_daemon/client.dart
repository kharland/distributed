import 'dart:async';

import 'package:distributed.objects/objects.internal.dart';
import 'package:distributed/src/port_daemon/port_daemon_routes.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed.http/http.dart';
import 'package:distributed.monitoring/logging.dart';

//
// This library assumes that initializeHttp from distributed.http has already
// been called
//

/// Sends a signal to the daemon at `routes.daemonUrl`.
///
/// Returns true iff the daemon sends a response.
Future<bool> pingDaemon(Http http, DaemonRoutes routes, [Logger logger]) {
  var completer = new Completer<bool>();
  runZoned(() async {
    await http.get(routes.ping());
    logger?.error("Pinged daemon server recieved reponse");
    return completer.complete(true);
  }, onError: (error) {
    logger?.error(error);
    completer.complete(false);
  });
  return completer.future;
}

/// Returns the url for connecting to the node named [nodeName].
///
/// Returns the empty string if [nodeName] could not be found.
Future<String> getNodeConnectionUrl(
  Http http,
  DaemonRoutes routes,
  String nodeName, [
  Logger logger,
]) {
  var completer = new Completer<String>();
  runZoned(() async {
    await _ensureDaemonIsRunning(http, routes);
    var port = await (await http.get(routes.node(nodeName))).first;
    completer.complete(port == '${Ports.error}'
        ? ''
        : 'ws://${extractHost(routes.daemonUrl)}:$port');
  }, onError: (error) {
    logger?.error(error);
    completer.complete('');
  });
  return completer.future;
}

/// Returns the control server url for the node named [nodeName].
Future<String> getNodeControlUrl(
  Http http,
  DaemonRoutes routes,
  String nodeName, [
  Logger logger,
]) {
  var completer = new Completer<String>();
  runZoned(() async {
    await _ensureDaemonIsRunning(http, routes);
    var port = await (await http.get(routes.controlServer(nodeName))).first;
    completer.complete(port == '${Ports.error}'
        ? ''
        : 'http://${extractHost(routes.daemonUrl)}:$port');
  }, onError: (error) {
    logger?.error(error);
    completer.complete('');
  });
  return completer.future;
}

/// Returns the empty string if no server was found.
Future<String> getNodeDiagnosticsUrl(
  Http http,
  DaemonRoutes routes,
  String nodeName, [
  Logger logger,
]) {
  var completer = new Completer<String>();
  runZoned(() async {
    await _ensureDaemonIsRunning(http, routes);
    var port = await (await http.get(routes.diagnosticsServer(nodeName))).first;
    completer.complete(port == '${Ports.error}'
        ? ''
        : 'http://${extractHost(routes.daemonUrl)}:$port');
  }, onError: (error) {
    logger?.error(error);
    completer.complete('');
  });
  return completer.future;
}

Future<bool> registerNode(
  Http http,
  DaemonRoutes routes,
  String nodeName,
  NodePorts ports, [
  Logger logger,
]) async {
  var completer = new Completer<bool>();
  runZoned(() async {
    await _ensureDaemonIsRunning(http, routes);
    var response = await (await http.post(routes.node(nodeName),
            payload: new Registration(nodeName, ports).serialize()))
        .first;
    if (response.isNotEmpty) {
      logger?.error(response);
      completer.complete(false);
    } else {
      completer.complete(true);
    }
  }, onError: (error) {
    logger?.error(error);
    completer.complete(false);
  });
  return completer.future;
}

/////
///// Returns a future that completes with true iff deregistration succeeded.
//Future<bool> deregisterNode(String daemonUrl, String nodeName) async {
//  await _ensureDaemonIsRunning(daemonUrl);
//  try {
//    var response = await _delete(routes.toNodeByName(daemonUrl, nodeName));
//    var error = await response.readAsString();
//    return error.isEmpty;
//  } catch (_) {
//    return false;
//  }
//}

class DaemonClient {
  final Logger logger;
  final Http http;
  final DaemonRoutes routes;

  DaemonClient(this.http, this.routes, this.logger);
}

/// Expects [url] to have the form <protocol>://<address>:<port>
String extractHost(String url) => Uri.parse(url).host;

Future _ensureDaemonIsRunning(Http http, DaemonRoutes routes) async {
  if (!await pingDaemon(http, routes)) {
    throw new Exception('Daemon is not running!');
  }
}
