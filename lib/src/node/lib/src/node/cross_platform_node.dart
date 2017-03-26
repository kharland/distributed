import 'dart:async';

import 'package:distributed.connection/src/connection_manager.dart';
import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.objects/interfaces.dart';
import 'package:meta/meta.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  @override
  final String name;

  @override
  final HostMachine hostMachine;
  final _messageController =
      new StreamController<Message>.broadcast(sync: true);
  final _zeroPeersController = new StreamController<String>(sync: true);
  final ConnectionManager _connectionManager;
  final Logger _logger;

  CrossPlatformNode({
    @required this.name,
    @required this.hostMachine,
    @required ConnectionManager connectionManager,
    @required Logger logger,
  })
      : _connectionManager = connectionManager,
        _logger = logger;

  @override
  List<Peer> get peers => _connectionManager.peers;

  @override
  Stream<Peer> get onConnect => _connectionManager.onConnection;

  @override
  Stream<Peer> get onDisconnect => _connectionManager.onDisconnection;

  @override
  Future<bool> connect(Peer peer) async =>
      await _connectionManager.connect(peer);

  @override
  void disconnect(Peer peer) {
    _connectionManager.disconnect(peer);
  }

  @override
  void send(Peer peer, String action, String data) {
    assert(peers.contains(peer), '$peer is not in $peers');
    var message = new Message(action, data, toPeer());
    _logger.log("Sending ${data} to ${peer.displayName}");
    _connections[peer].add(message);
  }

  @override
  Stream<Message> receive(String action) => _messageController.stream
      .where((Message message) => message.category == action);

  @override
  Future shutdown() async {
    _connectionManager.dispose();
    await _zeroPeersController.stream.first;
    _messageController.close();
    _zeroPeersController.close();
  }

  @override
  Peer toPeer() => new Peer(name, hostMachine);
}
