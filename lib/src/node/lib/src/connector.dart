import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.node/src/peer_verification.dart';
import 'package:distributed.objects/interfaces.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';

/// Connects one [Peer] to another.
class Connector {
  final Peer _localPeer;
  final PortDaemonClientFactory _clientFactory;

  Connector(this._localPeer, this._clientFactory);

  /// Attempts to open a socket connection with [receiver].
  ///
  /// If the connection fails, the returned [ConnectionResult] will contain an
  /// error message explaining the failure, but no [Socket].
  Future<ConnectionResult> connect(Peer receiver) async {
    final sender = _localPeer;
    final client =
        _clientFactory.createClient(_localPeer.name, receiver.hostMachine);
    final receiverUrl = await client.lookup(receiver.name);

    if (receiverUrl.isEmpty) {
      return new ConnectionResult.failed('Peer ${receiver.name} not found.');
    }

    final socket = Socket.connect(receiverUrl);
    final verification =
        await verifyRemotePeer(socket, sender, incoming: false);

    if (verification.error.isNotEmpty) {
      return new ConnectionResult.failed(verification.error);
    } else if (verification.peer != receiver) {
      return new ConnectionResult.failed('Invalid reciever');
    } else {
      return new ConnectionResult(socket, verification.peer);
    }
  }

  /// Attempts to receive the [socket] connected opened by some remote peer.
  ///
  /// Returns a future that completes with the [ConnectionResult]. See [connect]
  /// for details on the return value.
  Future<ConnectionResult> receiveSocket(Socket socket) async {
    final receiver = _localPeer;
    final verification =
        await verifyRemotePeer(socket, receiver, incoming: true);
    return verification.error.isNotEmpty
        ? new ConnectionResult(socket, verification.peer)
        : new ConnectionResult.failed(verification.error);
  }
}

/// The result of attempting a connection.
class ConnectionResult {
  final Socket socket;
  final Peer remote;
  final String error;

  ConnectionResult(this.socket, this.remote) : error = '';

  ConnectionResult.failed(this.error)
      : socket = null,
        remote = Peer.Null;
}
