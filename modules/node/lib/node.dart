import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.objects/objects.dart';

export 'package:distributed.objects/objects.dart';

/// A node in a distributed system.
abstract class Node {
  /// The name used to identify this node.
  String get name;

  // The address of this node.
  HostMachine get hostMachine;

  /// The list of peers that are connected to this [Node].
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Connects this node to [peer].
  Future connect(Peer peer);

  /// Disconnects from the remote peer identified by [name].
  void disconnect(Peer peer);

  /// Returns a peer with the same information as this [Node].
  Peer toPeer();

  /// Send a command of type [action] to [peer] with [data].
  void send(Peer peer, String action, String data);

  /// Returns a stream that emits any [action] messages this node receives.
  Stream<Message> receive(String action);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future shutdown();
}

class DelegatingNode implements Node {
  final Node delegate;

  DelegatingNode(this.delegate);

  @override
  String get name => delegate.name;

  @override
  HostMachine get hostMachine => delegate.hostMachine;

  @override
  List<Peer> get peers => delegate.peers;

  @override
  Stream<Peer> get onConnect => delegate.onConnect;

  @override
  Stream<Peer> get onDisconnect => delegate.onDisconnect;

  @override
  Future connect(Peer peer) => delegate.connect(peer);

  @override
  void disconnect(Peer peer) {
    delegate.disconnect(peer);
  }

  @override
  Peer toPeer() => delegate.toPeer();

  @override
  void send(Peer peer, String action, String data) {
    delegate.send(peer, action, data);
  }

  @override
  Stream<Message> receive(String action) => delegate.receive(action);

  @override
  Future shutdown() => delegate.shutdown();
}
