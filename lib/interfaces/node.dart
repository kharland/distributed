import 'dart:async';

import 'event.dart';
import 'peer.dart';

/// A callback executed by a [Node] when [message] is received.
typedef Future<Null> MessageHandler(String message);

/// A filter returns true iff [message] is acceptable.
///
/// This callback is used by [Node] to decide which [MessageActions] should
/// execute when [message] is received.
typedef bool MessageFilter(String message);

/// A node participating in a distributed system.
///
/// A node is uniquely identified by its [name] and [hostname].
///
/// Upon creation, the node immediately begins listening for and accepting
/// connection requests with a [cookie] matching this node's [cookie].
abstract class Node {
  static const int DEFAULT_PORT=9095;
  /// A string that another node must supply when requesting to connect with
  /// this node.
  String get cookie;

  /// This [Node]'s hostname.
  String get hostname;

  /// This [Node]'s identifier.
  String get name;

  /// Whether this node will attempt to connect to all other nodes in a [Peer]
  /// network after a connection is established.
  bool get isHidden;

  /// The list of peers in this node's network.
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<ConnectionEvent> get onConnect;

  /// Emits events when this node disconnects to a [Peer].
  Stream<DisconnectionEvent> get onDisconnect;

  /// Emits events when this node recieves a message.
  Stream<String> get onMessage;

  /// Connects to the remote peer identified by [name] and [hostname].
  Future<bool> connect(String name, String hostname);

  /// Disconnects from the remote peer identified by [name] and [hostname].
  Future<bool> disconnect(String name, String hostname);

  /// Sends [message] to [peer].
  Future<Null> send(String message, Peer peer);

  /// Executes [handler] on all incoming messages that pass [filter].
  void receive(MessageFilter filter, MessageHandler handler);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future<Null> shutdown();
}

/// A [Node] that delegates to another [Node].
///
/// Prefer extending this to add functionality to a [Node].
class DelegatingNode implements Node {
  final Node _delegate;

  DelegatingNode(this._delegate);

  @override
  Future<bool> connect(String name, String hostname) =>
      _delegate.connect(name, hostname);

  @override
  String get cookie => _delegate.cookie;

  @override
  Future<bool> disconnect(String name, String hostname) =>
      _delegate.disconnect(name, hostname);

  @override
  String get hostname => _delegate.hostname;

  @override
  bool get isHidden => _delegate.isHidden;

  @override
  String get name => _delegate.name;

  @override
  Stream<ConnectionEvent> get onConnect => _delegate.onConnect;

  @override
  Stream<DisconnectionEvent> get onDisconnect => _delegate.onDisconnect;

  @override
  Stream<String> get onMessage => _delegate.onMessage;

  @override
  List<Peer> get peers => _delegate.peers;

  @override
  void receive(MessageFilter filter, MessageHandler handler) =>
      _delegate.receive(filter, handler);

  @override
  Future<Null> send(String message, Peer peer) => _delegate.send(message, peer);

  @override
  Future<Null> shutdown() => _delegate.shutdown();
}
