import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/objects.dart';
import 'package:meta/meta.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  @override
  final String name;

  @override
  final HostMachine hostMachine;

  final _connector = new OneShotConnector();
  final _connections = <Peer, Connection>{};
  final _userMessageController =
      new StreamController<Message>.broadcast(sync: true);
  final _connectController = new StreamController<Peer>.broadcast(sync: true);
  final _disconnectController =
      new StreamController<Peer>.broadcast(sync: true);
  final _noConnectionsController = new StreamController<Null>();
  final _onShutdown = new Completer<Null>();

  Logger _logger;

  CrossPlatformNode({
    @required this.name,
    @required this.hostMachine,
    Logger logger,
  }) {
    _logger = logger ?? new Logger(name);
  }

  @override
  List<Peer> get peers => new List.unmodifiable(_connections.keys);

  @override
  Stream<Peer> get onConnect => _connectController.stream;

  @override
  Stream<Peer> get onDisconnect => _disconnectController.stream;

  @override
  Future<ConnectionResult> connect(Peer peer) async {
    assert(!_connections.containsKey(peer));
    ConnectionResult result = await _connector.connect(toPeer(), peer).first;
    if (result.error.isNotEmpty) {
      _logger.error(result.error);
    } else {
      addConnection(result.connection, result.receiver);
    }
    return result;
  }

  @override
  void disconnect(Peer peer) {
    assert(_connections.containsKey(peer));
    _connections.remove(peer).close();
    _logger.log('Disconnected from $peer');
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(_connections.containsKey(peer), '$peer not in $peers');
    _logger.log("Sending ${peer.displayName}: ${createMessage(action, data)}");
    _connections[peer].user.sink.add(createMessage(action, data));
  }

  @override
  Stream<Message> receive(String action) => _userMessageController.stream
      .where((Message message) => message.category == action);

  @override
  Future shutdown() async {
    _userMessageController.close();
    _connectController.close();
    if (peers.isNotEmpty) {
      peers.forEach(disconnect);
      await _noConnectionsController.stream.take(1).first;
    }
    _noConnectionsController.close();
    _disconnectController.close();
    _onShutdown.complete();
  }

  void addConnection(Connection connection, Peer peer) {
    assert(!_connections.containsKey(peer));
    connection
      ..system.stream.forEach(_handleSystemMessage)
      ..error.stream.forEach(_handleErrorMessage)
      ..done.then((_) {
        _handleConnectionClosed(peer);
      })
      ..user.stream.forEach(_userMessageController.add);
    _connections[peer] = connection;
    _logger.log('Connected to ${peer.displayName}');
    _connectController.add(peer);
  }

  @override
  Peer toPeer() => new Peer((b) => b
    ..name = name
    ..hostMachine = hostMachine);

  void _handleSystemMessage(Message message) {
    _logger.log(message.payload);
    throw new UnimplementedError();
  }

  void _handleErrorMessage(Message message) {
    _logger.error(message.payload);
  }

  void _handleConnectionClosed(Peer peer) {
    _connections.remove(peer);
    if (_connections.isEmpty) {
      _noConnectionsController.add(null);
    }
    _disconnectController.add(peer);
  }
}
