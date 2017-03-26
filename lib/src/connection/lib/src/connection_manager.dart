import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/message_router.dart';
import 'package:distributed.connection/src/socket_server.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/src/connector.dart';
import 'package:distributed.objects/interfaces.dart';

/// An interface for managing a group of connections.
///
/// A connection is associated with a peer
abstract class ConnectionManager {
  /// The list currently connected of peers.
  List<Peer> get peers;

  /// A stream of [Peer]s that emits when a connection is made.
  Stream<Peer> get onConnection;

  /// A stream of [Peer]s this emits when connection is closed.
  Stream<Peer> get onDisconnection;

  /// Sends [message] to [peer].
  ///
  /// Returns true if [message] was sent, or false if an error occurred.
  void send(Peer peer, Message message);

  /// Connects to [receiver].
  ///
  /// Returns a future that completes with true iff the connection succeeded.
  Future<bool> connect(Peer receiver);

  /// Disconnects from [peer].
  void disconnect(Peer peer);

  /// Closes all connections and disposes of this [ConnectionManager].
  ///
  /// This may only be called once, and the manager cannot be used after calling
  /// this.
  void dispose();
}

abstract class VmConnectionManager extends ConnectionManager {
  final Connector _connector;
  final SocketServer _server;
  final Logger _logger;

  final _peerToConnection = <Peer, Connection>{};
  final _onConnectionController = new StreamController<Peer>();
  final _onDisconnectionController = new StreamController<Peer>();
  final _zeroPeersController = new StreamController();

  VmConnectionManager(this._connector, this._server, this._logger) {
    _server.onSocket.forEach((Socket socket) async {
      final connectionResult = await _connector.receiveSocket(socket);
      if (connectionResult.error.isNotEmpty) {
        _logger.error(connectionResult.error);
      } else {
        _addConnection(connectionResult.remote, connectionResult.socket);
      }
    });
  }

  @override
  List<Peer> get peers => new List.unmodifiable(_peerToConnection.keys);

  @override
  Stream<Peer> get onConnection => _onConnectionController.stream;

  @override
  Stream<Peer> get onDisconnection => _onDisconnectionController.stream;

  @override
  Future<bool> connect(Peer receiver) async {
    final result = await _connector.connect(receiver);
    if (result.error.isNotEmpty) {
      _logger.error(result.error);
      return false;
    } else {
      _addConnection(result.remote, result.socket);
      return true;
    }
  }

  @override
  void disconnect(Peer peer) {
    assert(_peerToConnection.containsKey(peer));
    _peerToConnection[peer].close();
  }

  @override
  void dispose() {
    new List.from(_peerToConnection.keys).forEach(disconnect);
    _onConnectionController.close();
    _onDisconnectionController.close();
  }

  @override
  void send(Peer peer, Message message) {
    assert(peers.contains(peer));
    _peerToConnection[peer].add(message);
  }

  void _addConnection(Peer peer, Socket socket) {
    assert(!peers.contains(peer));
    _peerToConnection[peer] = new Connection(new MessageRouter(socket));
    _peerToConnection[peer]
      ..done.then((_) {
        _handleConnectionClosed(peer);
      })
      ..messages.forEach(_handleMessage);
    _onConnectionController.add(peer);
    _logger.log('Connected to ${peer.displayName}');
  }

  void _handleConnectionClosed(Peer peer) {
    assert(peers.contains(peer));
    _peerToConnection.remove(peer);
    _onDisconnectionController.add(peer);
    if (peers.isEmpty) {
      _zeroPeersController.add('');
    }
    _onDisconnectionController.add(peer);
    _logger.log('Disconnected from $peer');
  }

  void _handleMessage(Message message) {
    _logger.log(
        'Received ${message.contents} from ${message.sender.displayName}');

  }
}