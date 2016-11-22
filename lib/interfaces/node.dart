import 'dart:async';

import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/peer.dart';

/// A node participating in a distributed system.
///
/// A node is uniquely identified by its [name] and [hostname].
///
/// Upon creation, the node immediately begins listening for and accepting
/// connection requests with a [cookie] matching this node's [cookie].
abstract class Node {
  /// A string that another node must supply when requesting to connect with
  /// this node.
  String get cookie;

  /// This [Node]'s hostname.
  String get hostname;

  /// This [Node]'s port.
  int get port;

  /// This [Node]'s identifier.
  String get name;

  /// Whether this node will attempt to connect to all other nodes in a new
  /// [Peer]'s network.
  bool get isHidden;

  /// The list of peers that are connected to this [Node].
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Completes when this node stops receiving and sending connections.
  Future<Null> get onShutdown;

  /// Connects to the remote peer identified by [name] and [hostname].
  void connectTo(Peer peer);

  /// Disconnects from the remote peer identified by [name] and [hostname].
  void disconnect(Peer peer);

  /// Send a command of type [action] to [peer] with [data].
  void send(Peer peer, String action, String data);

  /// Returns a stream that emits any [action] messages this node receives.
  Stream<Message> receive(String action);

  /// Returns this [Node] as a [Peer].
  Peer toPeer();

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future<Null> shutdown();
}
