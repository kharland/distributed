import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/interfaces.dart';
import 'package:distributed.objects/objects.dart';
import 'package:meta/meta.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  @override
  final String name;

  @override
  final BuiltHostMachine hostMachine;

  final _connector = new OneShotConnector();
  final _connections = <BuiltPeer, Connection>{};
  final _userMessageController =
      new StreamController<BuiltMessage>.broadcast(sync: true);
  final _connectController =
      new StreamController<BuiltPeer>.broadcast(sync: true);
  final _disconnectController =
      new StreamController<BuiltPeer>.broadcast(sync: true);
  final _zeroPeersController = new StreamController<String>(sync: true);

  final Logger _logger;

  CrossPlatformNode({
    @required this.name,
    @required this.hostMachine,
    @required Logger logger,
  })
      : _logger = logger;

  @override
  List<BuiltPeer> get peers => new List.unmodifiable(_connections.keys);

  @override
  Stream<BuiltPeer> get onConnect => _connectController.stream;

  @override
  Stream<BuiltPeer> get onDisconnect => _disconnectController.stream;

  @override
  Future<ConnectionResult> connect(BuiltPeer peer) async {
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
  void disconnect(BuiltPeer peer) {
    assert(_connections.containsKey(peer));
    // The connection will be de-referenced and clients will be notified when
    // its done future completes. All we must do here is close it.
    _connections[peer].close();
  }

  @override
  void send(BuiltPeer peer, String action, String data) {
    assert(_connections.containsKey(peer), '$peer is not in $peers');
    var message = $message(action, data, toPeer());
    _logger.log("Sending ${data} to ${peer.displayName}");
    _connections[peer].add(message);
  }

  @override
  Stream<BuiltMessage> receive(String action) => _userMessageController.stream
      .where((BuiltMessage message) => message.category == action);

  @override
  Future shutdown() async {
    peers.forEach(disconnect);
    await _zeroPeersController.stream.first;
    _connectController.close();
    _userMessageController.close();
    _zeroPeersController.close();
    _disconnectController.close();
  }

  void addConnection(Connection connection, BuiltPeer peer) {
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
      ..messages.forEach((Message message) {
        _logger.log(
            'Received ${message.contents} from ${message.sender.displayName}');
        _userMessageController.add(message);
      });
    _connections[peer] = connection;
    _logger.log('Connected to ${peer.displayName}');
    _connectController.add(peer);
  }

  @override
  BuiltPeer toPeer() => $peer(name, hostMachine);
}
