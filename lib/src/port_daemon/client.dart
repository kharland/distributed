import 'dart:async';

import 'package:distributed/src/port_daemon/client.dart' as api;
import 'package:distributed/src/port_daemon/port_daemon.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:distributed/src/port_daemon/routes.dart' as routes;
import 'package:distributed.objects/private.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

/// Sends a signal to [daemonUrl].
///
/// Returns true iff the daemon sends a response. [nodeName] is optionally used
/// to specify to the daemon who is sending the signal.
Future<bool> pingDaemon(String daemonUrl, [String nodeName = '']) async {
  try {
    await _get(nodeName.isEmpty
        ? routes.toPing(daemonUrl)
        : routes.toKeepAlive(daemonUrl, nodeName));
    return true;
  } catch (_) {
    return false;
  }
}

/// Returns the url for connecting to the node named [nodeName].
///
/// Returns the empty string if [nodeName] could not be found.
Future<String> getNodeUrl(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    final response = await _get(routes.toNodeByName(daemonUrl, nodeName));
    final port = int.parse(await response.readAsString());
    return port == Ports.error ? '' : 'ws://${extractAddress(daemonUrl)}:$port';
  } catch (_) {
    return '';
  }
}

/// Returns the url for the remote interaction server for the node named
/// [nodeName].
///
/// Returns the empty string if no server was found.
Future<String> getControlServerUrl(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    final response = await _get(routes.toControlServer(daemonUrl, nodeName));
    final port = int.parse(await response.readAsString());
    return port == Ports.error
        ? ''
        : 'http://${extractAddress(daemonUrl)}:$port';
  } catch (_) {
    return '';
  }
}

/// Returns the empty string if no server was found.
Future<String> getDiagnosticsServerUrl(
    String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    final response =
        await _get(routes.toDiagnosticsServer(daemonUrl, nodeName));
    final port = int.parse(await response.readAsString());
    return port == Ports.error
        ? ''
        : 'http://${extractAddress(daemonUrl)}:$port';
  } catch (_) {
    return '';
  }
}

Future<List<int>> registerNode(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    var response = await _post(routes.toNodeByName(daemonUrl, nodeName));
    Registration result =
        deserialize(await response.readAsString(), Registration);
    return result.ports.toList();
  } catch (_) {
    return [Ports.error];
  }
}

/// Instructs the daemon server to deregister [nodeName].
///
/// Returns a future that completes with true iff deregistration succeeded.
Future<bool> deregisterNode(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    var response = await _delete(routes.toNodeByName(daemonUrl, nodeName));
    var error = await response.readAsString();
    return error.isEmpty;
  } catch (_) {
    return false;
  }
}

Future _throwIfDaemonIsUnresponsive(String daemonUrl) async {
  if (!await pingDaemon(daemonUrl)) {
    throw new Exception('Daemon not found at $daemonUrl');
  }
}

/// Sends a GET request.
Future<SeltzerHttpResponse> _get(String url) {
  return _send(_seltzer.get(url));
}

/// Sends a DELETE request.
Future<SeltzerHttpResponse> _delete(String url) => _send(_seltzer.delete(url));

/// Sends a POST request.
Future<SeltzerHttpResponse> _post(String url) => _send(_seltzer.post(url));

/// Strips the port-suffix from an internet address.
///
/// Expects [url] to have the form <protocol>://<address>:<port>
/// TODO: dedup
String extractAddress(String url) {
  // Strip proto
  if (url.contains('://')) {
    url = url.substring(url.indexOf('://') + 3);
  }
  // Strip port
  final lastColon = url.lastIndexOf(':');
  if (lastColon > 0) {
    url = url.substring(0, lastColon);
  }
  return url;
}

/// Throws an error if [future] takes too long to complete.
///
/// Completes with the result of [future] or [errorValue] if an error occurred.
// TODO: move this to a common location
Future/*<T>*/ timeoutFuture/*<T>*/(Future<T> future, {errorValue}) {
  Timer timeout;
  final responseCompleter = new Completer<T>();

  // The timeout error is thrown in a separate zone, so we catch it here because
  // we can't in the zone below.
  runZoned(() {
    timeout = new Timer(const Duration(seconds: 5), () {
      throw new TimeoutException('');
    });
  }, onError: (_) {
    print(_);
    if (!responseCompleter.isCompleted) {
      responseCompleter.complete(errorValue);
    }
  });

  runZoned(() {
    future.then((response) {
      timeout.cancel();
      if (!responseCompleter.isCompleted) {
        print(response);
        responseCompleter.complete(response);
      }
    });
  }, onError: (_) {
    print(_);
    responseCompleter.complete(errorValue);
  });

  return responseCompleter.future;
}

/// A convenience wrapper for the [PortDaemon] client api.
///
/// The wrapper sends all requests to the same port daemon.
class PortDaemonClient {
  final String daemonUrl;

  PortDaemonClient(this.daemonUrl);

  Future<bool> pingDaemon([String nodeName = '']) =>
      api.pingDaemon(daemonUrl, nodeName);

  Future<String> getNodeUrl(String nodeName) =>
      api.getNodeUrl(daemonUrl, nodeName);

  Future<String> getControlServerUrl(String nodeName) =>
      api.getControlServerUrl(daemonUrl, nodeName);

  Future<List<int>> registerNode(String nodeName) =>
      api.registerNode(daemonUrl, nodeName);

  Future<bool> deregisterNode(String nodeName) =>
      api.deregisterNode(daemonUrl, nodeName);
}

final _seltzer = const VmSeltzerHttp();

Future<SeltzerHttpResponse> _send(SeltzerHttpRequest request) =>
    timeoutFuture<SeltzerHttpResponse>(request.send().first);
