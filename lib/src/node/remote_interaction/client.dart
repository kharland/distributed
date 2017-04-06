import 'dart:async';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:http/http.dart' as http;
import 'package:distributed/src/objects/interfaces.dart';

const _anon = 'anon';

/// Forces a connection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future connect(Peer connector, Peer recipient, {String id: _anon}) async {
  final daemonClient =
      new PortDaemonClient(id, connector.hostMachine, new Logger(id));
  final connectorServerUrl = await daemonClient.lookupServer(connector.name);
  http.post('$connectorServerUrl/connect', body: serialize(recipient));
}

/// Forces a disconnection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future disconnect(Peer connector, Peer recipient, {String id: _anon}) async {
  final daemonClient =
      new PortDaemonClient(id, connector.hostMachine, new Logger(id));
  final connectorServerUrl = await daemonClient.lookupServer(connector.name);
  http.post('$connectorServerUrl/connect', body: serialize(recipient));
}
