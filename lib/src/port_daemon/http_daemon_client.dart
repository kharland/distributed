import 'dart:async';

import 'package:distributed.http/vm.dart' as http;
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/objects/objects.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:distributed/src/port_daemon/ports.dart';

/// A [PortDaemonClient] that communicates over HTTP.
class HttpDaemonClient implements PortDaemonClient {
  @override
  final HostMachine daemonHost;
  final String name;
  final Logger _logger;

  HttpDaemonClient(this.name, this.daemonHost, this._logger);

  @override
  Future<Map<String, int>> getNodes() async {
    if (!await pingDaemon(name)) {
      return {};
    }

    try {
      var response = await _post('list/node');
      var responseContent = await response.first;
      PortAssignmentList assignments =
          deserialize(responseContent, PortAssignmentList);

      return assignments.assignments.toMap();
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return {};
    }
  }

  @override
  Future<String> lookup(String name) async {
    if (!await pingDaemon(name)) {
      return '';
    }

    try {
      var response = await _post('get/node', payload: name);
      final port = int.parse(await response.first);
      return port == Ports.error ? '' : 'ws://${daemonHost.address}:$port';
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return '';
    }
  }

  @override
  Future<String> lookupServer(String nodeName) async {
    if (!await pingDaemon(name)) {
      return '';
    }

    try {
      var response = await _post('node/server/$nodeName');
      final port = int.parse(await response.first);
      return port == Ports.error ? '' : 'http://${daemonHost.address}:$port';
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return '';
    }
  }

  @override
  Future<int> registerNode() async {
    if (!await pingDaemon(name)) {
      return Ports.error;
    }

    try {
      var response = await _post('add/node', payload: name);
      var data = await response.first;
      Registration result = deserialize(data, Registration);
      return result.port;
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return Ports.error;
    }
  }

  @override
  Future<int> registerServer() async {
    if (!await pingDaemon(name)) {
      return Ports.error;
    }

    try {
      var response = await _post('node/server', payload: name);
      Registration result = deserialize(
          await response.fold('', (prev, next) => "$prev$next"), Registration);
      return result.port;
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return Ports.error;
    }
  }

  @override
  Future<bool> deregister() async {
    if (!await pingDaemon(name)) {
      return false;
    }

    try {
      var response = await _post('remove/node', payload: name);
      var error = await response.first;
      return error.isEmpty;
    } catch (e, s) {
      _logger..error(e.toString())..error(s.toString());
      return false;
    }
  }

  @override
  Future<bool> pingDaemon([String name]) async {
    _logger.log('Pinging daemon...');
    final _pingCompleter = new Completer<bool>();

    runZoned(() async {
      await (await _post('ping', payload: name)).first;
      if (_pingCompleter.isCompleted) return;
      _logger.log('Got ping from daemon');
      _pingCompleter.complete(true);
    }, onError: (e, s) {
      _logger..error(e.toString()); //..error(s.toString());
      if (_pingCompleter.isCompleted) return;
      _pingCompleter.complete(false);
    });
    return _pingCompleter.future;
  }

  Future<http.HttpResponse> _post(String route, {String payload}) =>
      http.post(_createRequestUrl(route), payload: payload);

  String _createRequestUrl(String route) =>
      '${daemonHost.portDaemonUrl}/$route';
}
