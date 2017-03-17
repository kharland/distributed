import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/socket.dart';
import 'package:distributed.objects/objects.dart';
import 'package:distributed.port_daemon/port_daemon_client.dart';
import 'package:distributed.port_daemon/ports.dart';

/// Connects one [Peer] to another.
abstract class Connector {
  /// Creates a request initiated by [sender] and received by [receiver].
  ///
  /// After completing the connection, this connector might attempt to open more
  /// connections with [receiver]'s peers.  Each successful connection will be
  /// emitted on the returned stream.
  ///
  /// If an error results in a failed connection, the [ConnectionResult] event
  /// will contain an error message explaining the failure, but no [Connection].
  Stream<ConnectionResult> connect(Peer sender, Peer receiver);

  /// Upgrades [socket] to a [Connection] between [receiver] and some peer.
  ///
  /// Returns a future that completes with the [ConnectionResult]. See [connect]
  /// for details on the return value.
  Future<ConnectionResult> receiveSocket(Peer receiver, Socket socket);
}

/// A [Connector] that creates one [Connection] per call to [connect].
class OneShotConnector implements Connector {
  static const _idCategory = 'id';
  static const _statusCategory = 'status';

  @override
  Stream<ConnectionResult> connect(Peer sender, Peer receiver) async* {
    var daemonClient = new PortDaemonClient(
        name: sender.name, daemonHostMachine: receiver.hostMachine);

    var receiverAddress = receiver.hostMachine.address;
    var receiverPort = await daemonClient.lookup(receiver.name);
    if (receiverPort == Ports.error) {
      yield new ConnectionResult.failed(
          'Peer ${receiver.name} not found at $receiverAddress');
      return;
    }

    var connection =
        await Connection.open('ws://$receiverAddress:$receiverPort');
    connection.add($message(_idCategory, serialize(sender), sender));

    var receiverStatus = await connection.messages.take(1).first;
    if (receiverStatus.payload.isEmpty) {
      yield new ConnectionResult(
        sender: sender,
        receiver: receiver,
        connection: connection,
      );
    } else {
      yield new ConnectionResult.failed(receiverStatus.payload);
    }
  }

  @override
  Future<ConnectionResult> receiveSocket(Peer receiver, Socket socket) async {
    var connection = await Connection.receive(socket);
    var sender = await _waitForSenderInfo(connection.messages);

    if (sender == null) {
      var error = 'Invalid sender info';
      connection.add($message(_statusCategory, error, receiver));
      return new ConnectionResult.failed(error);
    } else {
      connection.add($message(_statusCategory, '', receiver));
      return new ConnectionResult(
        sender: sender,
        receiver: receiver,
        connection: connection,
      );
    }
  }

  Future<Peer> _waitForSenderInfo(Stream<Message> stream) async {
    var message = await stream.take(1).first;
    if (message.category != _idCategory) {
      return null;
    }

    var sender = deserialize(message.payload, Peer) as Peer;
    if (sender is Peer) {
      return sender;
    } else {
      return null;
    }
  }
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
    this.error: '',
  });

  const ConnectionResult.failed(this.error)
      : sender = null,
        receiver = null,
        connection = null;
}
