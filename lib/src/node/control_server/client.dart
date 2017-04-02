import 'dart:async';
import 'dart:io' as io;

import 'package:distributed/src/port_daemon/client.dart';
import 'package:distributed.objects/public.dart';
import 'package:http/http.dart' as http;

/// Pings [peer].
///
/// Returns true iff a response was received.
/// TODO: preconditions
/// TODO: postconditions
Future<bool> ping(Peer peer, int diagnosticsServerPort) async {
  final diagnosticsUrl =
      'http://${peer.hostMachine.address}:$diagnosticsServerPort';
  if (diagnosticsUrl.isEmpty) {
    return false;
  }

  print("PINGING: $diagnosticsUrl");
  final response = await timeoutFuture<http.Response>(
      http.get('$diagnosticsUrl/ping'),
      errorValue: new http.Response('', io.HttpStatus.REQUEST_TIMEOUT));

  return response.statusCode == io.HttpStatus.REQUEST_TIMEOUT;
}

/// Forces a connection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future connect(Peer connector, Peer recipient) async {
  final daemonClient =
      new PortDaemonClient(recipient.hostMachine.portDaemonUrl);
  final connectorServerUrl =
      await daemonClient.getControlServerUrl(connector.name);
  http.post('$connectorServerUrl/connect', body: Peer.serialize(recipient));
}

/// Forces a disconnection between [connector] and [recipient].
/// TODO: preconditions
/// TODO: postconditions
Future disconnect(Peer connector, Peer recipient) async {
  final daemonClient =
      new PortDaemonClient(connector.hostMachine.portDaemonUrl);
  final connectorServerUrl =
      await daemonClient.getControlServerUrl(connector.name);
  http.post('$connectorServerUrl/connect', body: Peer.serialize(recipient));
}
