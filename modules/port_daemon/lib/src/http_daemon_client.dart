import 'dart:async';

import 'package:distributed.connection/src/timeout.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.monitoring/keep_alive.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:meta/meta.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

/// A [PortDaemonClient] that communicates over HTTP.
class HttpDaemonClient implements PortDaemonClient {
  static const _seltzer = const VmSeltzerHttp();

  final String name;
  final _http = new HttpWithTimeout();
  Timer _keepAliveTimer;

  HttpDaemonClient({
    @required this.name,
    @required this.daemonHostMachine,
  });

  @override
  @virtual
  final HostMachine daemonHostMachine;

  @override
  Future<bool> get isDaemonRunning async => _pingDaemon('anonymous');

  @override
  Future<Map<String, int>> getNodes() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_get('list/node'));
      var assignments =
          new PortAssignmentList.fromString(await response.readAsString());
      return assignments.assignments;
    } catch (e) {
      globalLogger.error(e);
      return {};
    }
  }

  @override
  Future<int> lookup(String name) async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_get('node/$name'));
      return int.parse(await response.readAsString());
    } catch (e) {
      globalLogger.error(e);
      return Ports.error;
    }
  }

  @override
  Future<int> register() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_post('node/$name'));
      Registration result =
          deserialize(await response.readAsString(), Registration);
      if (result.port != Ports.error) {
        _startKeepAlive(name);
      }
      return result.port;
    } catch (e) {
      globalLogger.error(e);
      return Ports.error;
    }
  }

  @override
  Future<bool> deregister() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_delete('node/$name'));
      var failed =
          new DeregistrationResult.fromString(await response.readAsString())
              .failed;
      if (!failed) {
        _stopKeepAlive();
      }
      return !failed;
    } catch (e) {
      globalLogger.error(e);

      return false;
    }
  }

  Future<bool> _pingDaemon(String nodeName) async {
    try {
      await _http.send(_get('ping/$nodeName'));
      return true;
    } catch (e) {
      globalLogger.error('$e'.trim());
      return false;
    }
  }

  void _startKeepAlive(String nodeName) {
    var period = KeepAlive.time;
    _keepAliveTimer = new Timer.periodic(period, (_) {
      _pingDaemon(nodeName);
    });
  }

  void _stopKeepAlive() {
    assert(_keepAliveTimer != null);
    _keepAliveTimer.cancel();
  }

  Future _expectDaemonIsRunning() async {
    assert(await isDaemonRunning, 'No daemon @${daemonHostMachine.daemonUrl}');
  }

  SeltzerHttpRequest _get(String route) =>
      _seltzer.get(_createRequestUrl(route));

  SeltzerHttpRequest _delete(String route) =>
      _seltzer.delete(_createRequestUrl(route));

  SeltzerHttpRequest _post(String route) =>
      _seltzer.post(_createRequestUrl(route));

  String _createRequestUrl(String route) =>
      '${daemonHostMachine.daemonUrl}/$route';
}

class HttpWithTimeout {
  Future<SeltzerHttpResponse> send(
    SeltzerHttpRequest request, [
    Object payload,
    Duration timeout = Timeout.defaultDuration,
  ]) {
    var timeout = new Timeout(() {
      throw new TimeoutError(request.toString());
    });

    return request.send().first.then((response) {
      timeout.cancel();
      return response;
    });
  }
}
