import 'dart:async';

import 'package:distributed.connection/src/timeout.dart';
import 'package:distributed.node/src/logging.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/src/api.dart';
import 'package:distributed.port_daemon/src/database_helpers.dart';
import 'package:distributed.port_daemon/src/ports.dart';
import 'package:meta/meta.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

/// A [PortDaemonClient] that communicates over HTTP.
class HttpClient implements PortDaemonClient {
  static const _seltzer = const VmSeltzerHttp();

  final _http = new HttpWithTimeout();
  final _logger = new Logger('$PortDaemonClient');

  Timer _heartbeatTimer;

  HttpClient({@required this.daemonHostMachine});

  @override
  @virtual
  final HostMachine daemonHostMachine;

  @override
  void startKeepAlive(String nodeName) {
    var period = KeepAlive.time ~/ 2;
    _heartbeatTimer = new Timer.periodic(period, (_) {
      _pingDaemon(nodeName);
    });
  }

  @override
  void stopHeartBeat(String nodeName) {
    assert(_heartbeatTimer != null);
    _heartbeatTimer.cancel();
  }

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
      _logger.error(e);
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
      _logger.error(e);
      return Ports.error;
    }
  }

  @override
  Future<int> register(String name) async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_post('node/$name'));
      Registration result =
          deserialize(await response.readAsString(), Registration);
      return result.port;
    } catch (e) {
      _logger.error(e);
      return Ports.error;
    }
  }

  @override
  Future<bool> deregister(String name) async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_delete('node/$name'));
      var result =
          new DeregistrationResult.fromString(await response.readAsString());
      return !result.failed;
    } catch (e) {
      _logger.error(e);

      return false;
    }
  }

  Future<bool> _pingDaemon(String nodeName) async {
    try {
      await _http.send(_get('ping/$nodeName'));
      return true;
    } catch (e) {
      _logger.error(e);
      return false;
    }
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
