import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/logging.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/objects.dart';
import 'package:meta/meta.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  final Logger _logger;
  final PeerConnector _connector;

  final StreamController<Message> _onUserMessageController =
      new StreamController<Message>.broadcast(sync: true);
  final StreamController<Peer> _onConnectController =
      new StreamController<Peer>.broadcast(sync: true);
  final StreamController<Peer> _onDisconnectController =
      new StreamController<Peer>.broadcast(sync: true);
  final StreamController<Null> _onZeroConnections =
      new StreamController<Null>();
  final Completer<Null> _onShutdown = new Completer<Null>();
  final Map<Peer, Connection> _connections = <Peer, Connection>{};

  @override
  final String name;

  @override
  final HostMachine hostMachine;

  CrossPlatformNode({
    @required this.name,
    @required this.hostMachine,
    PeerConnector peerConnector,
    Logger logger,
  })
      : _connector = peerConnector ?? (() => throw new UnimplementedError())(),
        _logger = logger ?? new Logger('$name@$hostMachine');

  @override
  List<Peer> get peers => new List.unmodifiable(_connections.keys);

  @override
  Stream<Peer> get onConnect => _onConnectController.stream;

  @override
  Stream<Peer> get onDisconnect => _onDisconnectController.stream;

  @override
  Future connect(Peer peer) async {
    assert(!_connections.containsKey(peer));
    await for (var result in _connector.connect(toPeer(), peer)) {
      if (result.error != null) {
        _logger.error(result.error);
      } else {
        _logger.log('Connected to ${result.receiver}');
        addConnection(result.connection, result.receiver);
      }
    }
  }

  @override
  void disconnect(Peer peer) {
    assert(_connections.containsKey(peer));
    _connections.remove(peer).close();
    _logger.log('disconnected from $peer');
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(_connections.containsKey(peer));
    _connections[peer].user.sink.add(new Message(action, data));
  }

  @override
  Stream<Message> receive(String action) => _onUserMessageController.stream
      .where((Message message) => message.category == action);

  @override
  Future shutdown() async {
    _onUserMessageController.close();
    _onConnectController.close();
    if (peers.isNotEmpty) {
      peers.forEach(disconnect);
      await _onZeroConnections.stream.take(1).first;
    }
    _onZeroConnections.close();
    _onDisconnectController.close();
    _onShutdown.complete();
  }

  void addConnection(Connection connection, Peer peer) {
    assert(!_connections.containsKey(peer));
    connection
      ..system.stream.forEach(_handleSystemMessage)
      ..error.stream.forEach(_handleErrorMessage)
      ..done.then(_handleConnectionClosed)
      ..user.stream.map(_onUserMessageController.add);
    _connections[peer] = connection;
    _logger.log('connected to $peer');
  }

  @override
  Peer toPeer() => new Peer((b) => b
    ..name = name
    ..hostMachine = hostMachine);

  void _handleSystemMessage(Message message) {
    switch (message.category) {
      case MessageCategories.error:
        _logger.error(message.payload);
        break;
      default:
        _logger.error('Unsupported meesage received ${message.category}');
    }
  }

  void _handleErrorMessage(Message message) {
    _logger.error(message.payload);
  }

  void _handleConnectionClosed(Peer peer) {
    _connections.remove(peer);
    if (_connections.isEmpty) {
      _onZeroConnections.add(null);
    }
    _onDisconnectController.add(peer);
  }
}
