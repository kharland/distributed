import 'dart:async';

import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/message/message_categories.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.utils/logging.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  final ConnectionStrategy _defaultConnectionStrategy;
  final Logger _logger;

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
  final String address;

  @override
  final bool isHidden;

  CrossPlatformNode(
    String name, {
    this.address: 'localhost',
    this.isHidden: false,
    ConnectionStrategy connectionStrategy,
  })
      : name = name,
        _defaultConnectionStrategy = connectionStrategy,
        _logger = new Logger('$Node:$name');

  @override
  List<Peer> get peers => new List.unmodifiable(_connections.keys);

  @override
  Stream<Peer> get onConnect => _onConnectController.stream;

  @override
  Stream<Peer> get onDisconnect => _onDisconnectController.stream;

  @override
  Future connect(Peer peer, {ConnectionStrategy connectionStrategy}) async {
    assert(!_connections.containsKey(peer));
    connectionStrategy ??= _defaultConnectionStrategy;
    _defaultConnectionStrategy.connect(name, peer.name).forEach(addConnection);
  }

  @override
  void disconnect(Peer peer) {
    assert(_connections.containsKey(peer));
    _connections.remove(peer).channels.close();
    _logger.info('disconnected from $peer');
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(_connections.containsKey(peer));
    _connections[peer].channels.user.sink.add(new Message(action, data));
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

  @override
  Peer toPeer() => new Peer(name, address);

  @override
  void addConnection(Connection connection) {
    assert(!_connections.containsKey(connection.peer));
    connection.channels.system.stream.forEach(_handleSystemMessage);
    connection.channels.error.stream.forEach(_handleErrorMessage);
    connection.done.then(_handleConnectionClosed);
    connection.channels.user.stream.map(_onUserMessageController.add);
    _connections[connection.peer] = connection;
    _logger.info('connected to ${connection.peer}');
  }

  void _handleSystemMessage(Message message) {
    switch (message.category) {
      case MessageCategories.error:
        _logger.shout(message.payload);
        break;
      default:
        _logger.shout('Unsupported meesage received ${message.category}');
    }
  }

  void _handleErrorMessage(Message message) {
    _logger.shout(message.payload);
  }

  void _handleConnectionClosed(Peer peer) {
    _connections.remove(peer);
    if (_connections.isEmpty) {
      _onZeroConnections.add(null);
    }
    _onDisconnectController.add(peer);
  }
}
