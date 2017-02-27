import 'dart:async';
import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/socket.dart';
import 'package:distributed.objects/objects.dart';

/// Connects one [Peer] to another.
abstract class PeerConnector {
  /// Creates a request initiated by [sender] and received by [receiver].
  ///
  /// If the connection is successful, the returned [ConnectionResult] will
  /// contain the [Connection] between [sender] and [receiver]. an error results
  /// in a failed connection, the returned result will contain an error message
  /// explaining the failure, but no [Connection].
  Stream<ConnectionResult> connect(Peer sender, Peer receiver);

  /// Upgrades [socket] to a [Connection] between [receiver] and some peer.
  ///
  /// See [connect] for details on the return value.
  Stream<ConnectionResult> receiveSocket(Peer receiver, Socket socket);
}

/// The result of attempting a connection.
class ConnectionResult {
  final Peer sender;
  final Peer receiver;
  final Connection connection;
  final String error;

  const ConnectionResult({
    this.sender,
    this.receiver,
    this.connection,
    this.error,
  });
}
