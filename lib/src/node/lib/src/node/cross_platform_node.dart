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
  final _zeroPeersController = new StreamController<String>(sync: true);

  final Logger _logger;

  CrossPlatformNode({
    @required this.name,
    @required this.hostMachine,
    Logger logger,
  })
      : _logger = logger ?? new Logger(name);

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
    // The connection will be de-referenced and clients will be notified when
    // its done future completes. All we must do here is close it.
    _connections[peer].close();
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(_connections.containsKey(peer), '$peer is not in $peers');
    var message = $message(action, data, toPeer());
    _logger.log("Sending message to ${peer.displayName}: ${message}");
    _connections[peer].add(message);
  }

  @override
  Stream<Message> receive(String action) => _userMessageController.stream
      .where((Message message) => message.category == action);

  @override
  Future shutdown() async {
    peers.forEach(disconnect);
    await _zeroPeersController.stream.first;
    _connectController.close();
    _userMessageController.close();
    _zeroPeersController.close();
    _disconnectController.close();
  }

  void addConnection(Connection connection, Peer peer) {
    assert(!_connections.containsKey(peer));
    connection
      ..done.then((_) {
        _connections.remove(peer);
        _disconnectController.add(peer);
        _logger.log('Disconnected from $peer');
        if (peers.isEmpty) {
          _zeroPeersController.add('');
        }
      })
      ..messages.forEach(_userMessageController.add);
    _connections[peer] = connection;
    _logger.log('Connected to ${peer.displayName}');
    _connectController.add(peer);
  }

  @override
  Peer toPeer() => $peer(name, hostMachine);
}
