import 'dart:async';

import 'package:distributed/src/monitoring/periodic_function.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

/// A [PortDaemonClient] that communicates over HTTP.
class HttpDaemonClient implements PortDaemonClient {
  static const _seltzer = const VmSeltzerHttp();

  final String name;

  @override
  final HostMachine daemonHost;
  final _http = new HttpWithTimeout();

  PeriodicFunction _keepAliveSignal;

  HttpDaemonClient(this.name, this.daemonHost);

  @override
  Future<bool> get isDaemonRunning async => _pingDaemon(name);

  @override
  Future<Map<String, int>> getNodes() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_get('list/node'));
      PortAssignmentList assignments =
          deserialize(await response.readAsString(), PortAssignmentList);
      return assignments.assignments.toMap();
    } catch (e) {
      return {};
    }
  }

  @override
  Future<String> lookup(String name) async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_get('node/$name'));
      final port = int.parse(await response.readAsString());
      return port == Ports.error ? '' : 'ws://${daemonHost.address}:$port';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<String> lookupServer(String nodeName) async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_get('node/server/$nodeName'));
      final port = int.parse(await response.readAsString());
      return port == Ports.error ? '' : 'http://${daemonHost.address}:$port';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<int> registerNode() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_post('node/$name'));
      Registration result =
          deserialize(await response.readAsString(), Registration);
      if (result.port != Ports.error) {
        _periodicallySendKeepAliveSignal();
      }
      return result.port;
    } catch (e) {
      return Ports.error;
    }
  }

  @override
  Future<int> registerServer() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_post('node/server/$name'));
      Registration result =
          deserialize(await response.readAsString(), Registration);
      if (result.port != Ports.error) {
        _periodicallySendKeepAliveSignal();
      }
      return result.port;
    } catch (e) {
      return Ports.error;
    }
  }

  @override
  Future<bool> deregister() async {
    await _expectDaemonIsRunning();
    try {
      _stopSendingKeepAliveSignal();
      var response = await _http.send(_delete('node/$name'));
      var error = await response.readAsString();
      return error.isEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _pingDaemon(String nodeName) async {
    try {
      await _http.send(_get('ping/$nodeName'));
      return true;
    } catch (e) {
      return false;
    }
  }

  void _periodicallySendKeepAliveSignal() {
    _keepAliveSignal = new PeriodicFunction(() {
      _pingDaemon(name);
    });
  }

  void _stopSendingKeepAliveSignal() {
    _keepAliveSignal.stop();
  }

  Future _expectDaemonIsRunning() async {
    if (!await isDaemonRunning) {
      throw new Exception('Daemon not found at ${daemonHost.portDaemonUrl}');
    }
  }

  SeltzerHttpRequest _get(String route) =>
      _seltzer.get(_createRequestUrl(route));

  SeltzerHttpRequest _delete(String route) =>
      _seltzer.delete(_createRequestUrl(route));

  SeltzerHttpRequest _post(String route) =>
      _seltzer.post(_createRequestUrl(route));

  String _createRequestUrl(String route) =>
      '${daemonHost.portDaemonUrl}/$route';
}

class HttpWithTimeout {
  Future<SeltzerHttpResponse> send(SeltzerHttpRequest request) {
    final responseCompleter = new Completer<SeltzerHttpResponse>();
    Timer timeout;

    runZoned(() {
      timeout = new Timer(const Duration(seconds: 5), () {
        throw new TimeoutException(request.toString());
      });
    }, onError: (e, s) {
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
    }, onError: (e, s) {
      responseCompleter.complete(null);
    });

    return responseCompleter.future;
  }
}
