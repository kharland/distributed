import 'dart:async';

import 'package:distributed/src/connection/connection_manager.dart';
import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/objects/interfaces.dart';
import 'package:distributed/src/port_daemon/port_daemon_client.dart';
import 'package:meta/meta.dart';

import 'node.dart';
import 'package:async/async.dart';

/// Internal-only [Node] implementation.
class CrossPlatformNode implements Node {
  final Peer _asPeer;
  final ConnectionManager _connectionManager;
  final Logger _logger;
  final _onShutdownCompleter = new Completer();
  final _shutdownMemo = new AsyncMemoizer();

  CrossPlatformNode.fromPeer(
    Peer peer, {
    @required ConnectionManager connectionManager,
    @required Logger logger,
  })
      : _asPeer = peer,
        _connectionManager = connectionManager,
        _logger = logger;

  @override
  HostMachine get hostMachine => _asPeer.hostMachine;

  @override
  String get name => _asPeer.name;

  @override
  List<Peer> get peers => _connectionManager.peers;

  @override
  Stream<Peer> get onConnect => _connectionManager.onConnection;

  @override
  Stream<Peer> get onDisconnect => _connectionManager.onDisconnection;

  @override
  Future get onShutdown => _onShutdownCompleter.future;

  @override
  Future<bool> connect(Peer peer) async {
    final portDaemonClient =
        new PortDaemonClient(name: name, daemonHost: peer.hostMachine);
    final peerUrl = await portDaemonClient.lookup(peer.name);

    if (peerUrl.isEmpty) {
      _logger.error('Peer ${peer.name} not found.');
      return false;
    }
    return _connectionManager.connect(peerUrl);
  }

  @override
  void disconnect(Peer peer) {
    _connectionManager.disconnect(peer);
  }

  @override
  void send(Peer peer, String action, String data) {
    _connectionManager.send(peer, new Message(action, data, toPeer()));
  }

  @override
  Stream<Message> receive(String category) => _connectionManager.messages
      .where((Message message) => message.category == category);

  @override
  Future shutdown() => _shutdownMemo.runOnce(() async {
        await _connectionManager.dispose();
        _onShutdownCompleter.complete();
      });

  @override
  Peer toPeer() => _asPeer;
}
