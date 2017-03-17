import 'dart:async';

import 'package:distributed.connection/src/timeout.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.monitoring/periodic_function.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:meta/meta.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

/// A [PortDaemonClient] that communicates over HTTP.
class HttpDaemonClient implements PortDaemonClient {
  static const _seltzer = const VmSeltzerHttp();

  final String name;
  final Logger logger;

  @override
  final HostMachine daemonHostMachine;
  final _http = new HttpWithTimeout();

  PeriodicFunction _keepAliveSignal;

  HttpDaemonClient({
    @required this.name,
    @required this.daemonHostMachine,
    Logger logger,
  })
      : this.logger = logger ?? new Logger(name);

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
      logger.error("getNodes $e");
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
      logger.error("lookup $e");
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
        _periodicallySendKeepAliveSignal();
      }
      return result.port;
    } catch (e) {
      logger.error("register $e");
      return Ports.error;
    }
  }

  @override
  Future<bool> deregister() async {
    await _expectDaemonIsRunning();
    try {
      var response = await _http.send(_delete('node/$name'));
      var error = await response.readAsString();
      if (error.isEmpty) {
        _stopSendingKeepAliveSignal();
        return true;
      } else {
        logger.error(error);
        return false;
      }
    } catch (e) {
      logger.error("deregister $e");
      return false;
    }
  }

  Future<bool> _pingDaemon(String nodeName) async {
    try {
      await _http.send(_get('ping/$nodeName'));
      return true;
    } catch (e) {
      logger.error("ping $e");
      return false;
    }
  }

  void _periodicallySendKeepAliveSignal() {
    _keepAliveSignal = new PeriodicFunction(name, () async {
      _pingDaemon(name);
    });
  }

  void _stopSendingKeepAliveSignal() {
    _keepAliveSignal.stop();
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
  Future<SeltzerHttpResponse> send(SeltzerHttpRequest request) {
    var timeout = new Timeout(() {
      throw new TimeoutError(request.toString());
    });
    return request.send().first.then((response) {
      timeout.cancel();
      return response;
    });
  }
}
