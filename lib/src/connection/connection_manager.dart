import 'dart:async';

import 'package:distributed/src/connection/message_channel.dart';
import 'package:distributed/src/connection/peer_verifier.dart';
import 'package:distributed/src/connection/socket.dart';
import 'package:distributed/src/connection/socket_server.dart';
import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:meta/meta.dart';

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

  /// The stream of all messages received from [Peer]s.
  Stream<Message> get messages;

  /// Sends [message] to [peer].
  ///
  /// Returns true if [message] was sent, or false if an error occurred.
  void send(Peer peer, Message message);

  /// Connects to the remote at [url].
  ///
  /// Returns a future that completes with true iff the connection succeeded.
  Future<bool> connect(String url);

  /// Disconnects from [peer].
  void disconnect(Peer peer);

  /// Closes all connections and disposes of this [ConnectionManager].
  ///
  /// Returns a future that completes when all connections have been closed.
  /// This may only be called once, and the manager cannot be used after calling
  /// this
  Future dispose();
}

class VmConnectionManager implements ConnectionManager {
  final PeerVerifier _peerVerifier;
  final SocketServer _server;
  final Logger _logger;

  final _peerToChannel = <Peer, MessageChannel>{};
  final _onConnectionController =
      new StreamController<Peer>.broadcast(sync: true);
  final _onDisconnectionController =
      new StreamController<Peer>.broadcast(sync: true);
  final _onMessageController = new StreamController<Message>();
  final _zeroPeersController = new StreamController();

  static Future<VmConnectionManager> bind(
    String address,
    int port, {
    @required PeerVerifier peerVerifier,
    @required Logger logger,
  }) async {
    final socketServer = await SocketServer.bind(address, port);
    return new VmConnectionManager(peerVerifier, socketServer, logger);
  }

  VmConnectionManager(this._peerVerifier, this._server, this._logger) {
    _server.onSocket.forEach(_handleNewSocketConnection);
  }

  @override
  List<Peer> get peers => new List.unmodifiable(_peerToChannel.keys);

  @override
  Stream<Peer> get onConnection => _onConnectionController.stream;

  @override
  Stream<Peer> get onDisconnection => _onDisconnectionController.stream;

  @override
  Stream<Message> get messages => _onMessageController.stream;

  @override
  Future<bool> connect(String url) async {
    final socket = await Socket.connect(url);
    final verification = await _peerVerifier.verifyOutgoing(socket);
    if (verification.error.isNotEmpty) {
      throw new Exception(verification.error);
    }
    _addConnection(verification.peer, socket);
    return true;
  }

  @override
  void disconnect(Peer peer) {
    assert(_peerToChannel.containsKey(peer));
    _peerToChannel[peer].close();
  }

  @override
  Future dispose() async {
    _onConnectionController.close();
    if (peers.isEmpty) {
      _zeroPeersController.close();
    } else {
      new List.from(_peerToChannel.keys).forEach(disconnect);
      return _zeroPeersController.stream.take(1).first.then((_) {
        _zeroPeersController.close();
        _onDisconnectionController.close();
      });
    }
  }

  @override
  void send(Peer peer, Message message) {
    assert(peers.contains(peer));
    _peerToChannel[peer].send(message);
    _logger.log("Sent ${message.contents} to ${peer.displayName}");
  }

  void _addConnection(Peer peer, Socket socket) {
    assert(!peers.contains(peer));
    _peerToChannel[peer] = new MessageChannel.fromSocket(socket);
    _peerToChannel[peer]
      ..done.then((_) {
        _handleConnectionClosed(peer);
      })
      ..messages.forEach(_handleMessage);
    _onConnectionController.add(peer);
    _logger.log('Connected to ${peer.displayName}');
  }

  Future _handleNewSocketConnection(Socket socket) async {
    final verification = await _peerVerifier.verifyIncoming(socket);
    if (verification.error.isNotEmpty) {
      throw new Exception(verification.error);
    }
    _addConnection(verification.peer, socket);
  }

  void _handleConnectionClosed(Peer peer) {
    assert(peers.contains(peer));
    _peerToChannel.remove(peer);
    _onDisconnectionController.add(peer);
    if (peers.isEmpty && _zeroPeersController.hasListener) {
      _zeroPeersController.add('');
    }
    _logger.log('Disconnected from $peer');
  }

  void _handleMessage(Message message) {
    _logger.log('Got ${message.contents} from ${message.sender.displayName}');
    _onMessageController.add(message);
  }
}
