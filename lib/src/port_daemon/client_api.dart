import 'dart:async';

import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

final _seltzer = const VmSeltzerHttp();

/// Sends a signal to [daemonUrl].
///
/// Returns true iff the daemon sends a response. [nodeName] is optionally used
/// to specify to the daemon who is sending the signal.
Future<bool> pingDaemon(String daemonUrl, [String nodeName = '']) async {
  try {
    await _get('$daemonUrl/ping' + (nodeName.isEmpty ? '' : '/$nodeName'));
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
    final response = await _get('$daemonUrl/node/$nodeName');
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
Future<String> getNodeServer(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    final response = await _get('$daemonUrl/node/server/$nodeName');
    final port = int.parse(await response.readAsString());
    return port == Ports.error
        ? ''
        : 'http://${extractAddress(daemonUrl)}:$port';
  } catch (_) {
    return '';
  }
}

/// Returns a new port for [nodeName].
///
/// Returns a Future that completes with the new port if registration
/// succeeded or [Ports.error] if it failed.
Future<int> registerNode(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    var response = await _post('$daemonUrl/node/$nodeName');
    Registration result =
        deserialize(await response.readAsString(), Registration);
    if (result.port != Ports.error) {
      // TODO: Start sending keepalive signal
    }
    return result.port;
  } catch (_) {
    return Ports.error;
  }
}

/// Returns a port for [nodeName]'s remote interaction server.
///
/// Returns a Future that completes with the new port if registration succeeded
/// or [Ports.error] if it failed.
Future<int> registerRIServer(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    var response = await _post('$daemonUrl/node/server/$nodeName');
    Registration result =
        deserialize(await response.readAsString(), Registration);
    if (result.port != Ports.error) {
      // TODO: Stop sending keepalive signal
    }
    return result.port;
  } catch (_) {
    return Ports.error;
  }
}

/// Instructs the daemon server to deregister [nodeName].
///
/// Returns a future that completes with true iff deregistration succeeded.
Future<bool> deregisterNode(String daemonUrl, String nodeName) async {
  await _throwIfDaemonIsUnresponsive(daemonUrl);
  try {
    // TODO: Stop sending keepalive signal
    var response = await _delete('$daemonUrl/node/$nodeName');
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

/// Sends an http request with a timeout.
///
/// Returns a future that completes with the response.  If a response is not
/// received within the timeout, the future completes with a null value.
Future<SeltzerHttpResponse> _send(SeltzerHttpRequest request) {
  final responseCompleter = new Completer<SeltzerHttpResponse>();
  Timer timeout;

  // The timeout error is thrown in a separate zone, so we catch it here because
  // we can't in the zone below.
  runZoned(() {
    timeout = new Timer(const Duration(seconds: 5), () {
      throw new TimeoutException(request.toString());
    });
  }, onError: (_) {
    if (!responseCompleter.isCompleted) {
      responseCompleter.complete(null);
    }
  });

  runZoned(() {
    request.send().first.then((response) {
      timeout.cancel();
      if (!responseCompleter.isCompleted) {
        responseCompleter.complete(response);
      }
    });
  }, onError: (_) {
    responseCompleter.complete(null);
  });

  return responseCompleter.future;
}
