import 'dart:async';
import 'package:distributed/src/port_daemon/client.dart';
import 'package:http/http.dart' as http;
import 'package:distributed/src/objects/interfaces.dart';

/// Forces a connection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future connect(Peer connector, Peer recipient) async {
  final daemonClient =
      new PortDaemonClient(recipient.hostMachine.portDaemonUrl);
  final connectorServerUrl = await daemonClient.getNodeServer(connector.name);
  http.post('$connectorServerUrl/connect', body: serialize(recipient));
}

/// Forces a disconnection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future disconnect(Peer connector, Peer recipient) async {
  final daemonClient =
      new PortDaemonClient(connector.hostMachine.portDaemonUrl);
  final connectorServerUrl = await daemonClient.getNodeServer(connector.name);
  http.post('$connectorServerUrl/connect', body: serialize(recipient));
}
