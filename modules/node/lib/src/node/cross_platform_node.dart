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
  final PeerConnector _connector = new OneShotConnector();
  final Map<Peer, Connection> _connections = <Peer, Connection>{};

  final StreamController<Message> _onUserMessageController =
      new StreamController<Message>.broadcast(sync: true);
  final StreamController<Peer> _onConnectController =
      new StreamController<Peer>.broadcast(sync: true);
  final StreamController<Peer> _onDisconnectController =
      new StreamController<Peer>.broadcast(sync: true);
  final StreamController<Null> _onZeroConnections =
      new StreamController<Null>();
  final Completer<Null> _onShutdown = new Completer<Null>();

  CrossPlatformNode({@required this.name, @required this.hostMachine});

  @override
  List<Peer> get peers => new List.unmodifiable(_connections.keys);

  @override
  Stream<Peer> get onConnect => _onConnectController.stream;

  @override
  Stream<Peer> get onDisconnect => _onDisconnectController.stream;

  @override
  Future<ConnectionResult> connect(Peer peer) async {
    assert(!_connections.containsKey(peer));
    ConnectionResult result = await _connector.connect(toPeer(), peer).first;
    if (result.error.isNotEmpty) {
      globalLogger.error(result.error);
    } else {
      addConnection(result.connection, result.receiver);
    }
    return result;
  }

  @override
  void disconnect(Peer peer) {
    assert(_connections.containsKey(peer));
    _connections.remove(peer).close();
    globalLogger.log('Disconnected from $peer');
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(_connections.containsKey(peer), '$peer not in $peers');
    globalLogger
        .log("Sending ${peer.displayName}: ${createMessage(action, data)}");
    _connections[peer].user.sink.add(createMessage(action, data));
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
      ..done.then((_) {
        _handleConnectionClosed(peer);
      })
      ..user.stream.forEach(_onUserMessageController.add);
    _connections[peer] = connection;
    globalLogger.log('Connected to ${peer.displayName}');
    _onConnectController.add(peer);
  }

  @override
  Peer toPeer() => new Peer((b) => b
    ..name = name
    ..hostMachine = hostMachine);

  void _handleSystemMessage(Message message) {
    globalLogger.log(message.payload);
    throw new UnimplementedError();
  }

  void _handleErrorMessage(Message message) {
    globalLogger.error(message.payload);
  }

  void _handleConnectionClosed(Peer peer) {
    _connections.remove(peer);
    if (_connections.isEmpty) {
      _onZeroConnections.add(null);
    }
    _onDisconnectController.add(peer);
  }
}
