import 'dart:async';

import 'package:distributed.monitoring/logging.dart';
import 'package:distributed.node/src/configuration.dart';
import 'package:distributed.node/src/peer_connector.dart';
import 'package:distributed.objects/objects.dart';

/// A node in a distributed system.
abstract class Node {
  /// The name used to identify this node.
  String get name;

  // This node's host machine.
  BuiltHostMachine get hostMachine;

  /// The list of peers that are connected to this [Node].
  List<BuiltPeer> get peers;

  /// Emits events when this node connects to a [BuiltPeer].
  Stream<BuiltPeer> get onConnect;

  /// Emits events when this node disconnects from a [BuiltPeer].
  Stream<BuiltPeer> get onDisconnect;

  /// Connects this node to [peer].
  Future<ConnectionResult> connect(BuiltPeer peer);

  /// Disconnects from the remote peer identified by [name].
  void disconnect(BuiltPeer peer);

  /// Returns a peer with the same information as this [Node].
  BuiltPeer toPeer();

  /// Send a command of type [action] to [peer] with [data].
  void send(BuiltPeer peer, String action, String data);

  /// Returns a stream that emits any [action] messages this node receives.
  Stream<BuiltMessage> receive(String action);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future shutdown();

  static Future<Node> spawn(String name, {Logger logger}) =>
      nodeProvider.spawn(name, logger: logger);
}

class DelegatingNode implements Node {
  final Node delegate;

  DelegatingNode(this.delegate);

  @override
  String get name => delegate.name;

  @override
  BuiltHostMachine get hostMachine => delegate.hostMachine;

  @override
  List<BuiltPeer> get peers => delegate.peers;

  @override
  Stream<BuiltPeer> get onConnect => delegate.onConnect;

  @override
  Stream<BuiltPeer> get onDisconnect => delegate.onDisconnect;

  @override
  Future<ConnectionResult> connect(BuiltPeer peer) => delegate.connect(peer);

  @override
  void disconnect(BuiltPeer peer) => delegate.disconnect(peer);

  @override
  BuiltPeer toPeer() => delegate.toPeer();

  @override
  void send(BuiltPeer peer, String action, String data) {
    delegate.send(peer, action, data);
  }

  @override
  Stream<BuiltMessage> receive(String action) => delegate.receive(action);

  @override
  Future shutdown() => delegate.shutdown();
}
