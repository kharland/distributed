import 'dart:async';

import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_strategy.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/peer.dart';

export 'package:distributed.node/src/message/message.dart';
export 'package:distributed.node/src/peer.dart';

/// A node in a distributed system.
abstract class Node {
  /// The name used to identify this node.
  String get name;

  /// This node's address
  String get address;

  /// Whether this node is hidden;
  bool get isHidden;

  /// The list of peers that are connected to this [Node].
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Connect to [peer].
  ///
  /// [connectionStrategy] determines how this node will conneect to [peer]. If
  /// it is not supplied, the default strategy is used.
  Future connect(Peer peer, {ConnectionStrategy connectionStrategy});

  /// Add an established [connection].
  void addConnection(Connection connection);

  /// Disconnects from the remote peer identified by [name] and [address].
  void disconnect(Peer peer);

  /// Send a command of type [action] to [peer] with [data].
  void send(Peer peer, String action, String data);

  /// Returns a stream that emits any [action] messages this node receives.
  Stream<Message> receive(String action);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future shutdown();

  Peer toPeer() => new Peer(name, address);
}

class DelegatingNode implements Node {
  final Node delegate;

  DelegatingNode(this.delegate);

  @override
  String get address => delegate.address;

  @override
  bool get isHidden => delegate.isHidden;

  @override
  String get name => delegate.name;

  @override
  List<Peer> get peers => delegate.peers;

  @override
  Stream<Peer> get onConnect => delegate.onConnect;

  @override
  Stream<Peer> get onDisconnect => delegate.onDisconnect;

  @override
  Future connect(Peer peer, {ConnectionStrategy connectionStrategy}) =>
      delegate.connect(peer, connectionStrategy: connectionStrategy);

  @override
  void addConnection(Connection connection) =>
      delegate.addConnection(connection);

  @override
  void disconnect(Peer peer) {
    delegate.disconnect(peer);
  }

  @override
  void send(Peer peer, String action, String data) {
    delegate.send(peer, action, data);
  }

  @override
  Stream<Message> receive(String action) => delegate.receive(action);

  @override
  Future shutdown() => delegate.shutdown();

  @override
  Peer toPeer() => delegate.toPeer();
}
