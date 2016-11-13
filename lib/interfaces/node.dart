import 'dart:async';

import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/io/command.dart';
import 'package:distributed/src/networking/connection.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/io/repl.dart';

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

  /// This [Node]'s identifier.
  String get name;

  /// Whether this node will attempt to connect to all other nodes in a new
  /// [Peer]'s network.
  bool get isHidden;

  /// The list of peers that are connected to this [Node].
  Iterable<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Completes when this node stops receiving and sending connections.
  Future<Null> get onShutdown;

  /// Connects to the remote peer identified by [name] and [hostname].
  void createConnection(Peer peer);

  /// Adds a pre-established [connection] to [peer] to this [Node].
  void addConnection(Peer peer, Connection connection);

  /// Disconnects from the remote peer identified by [name] and [hostname].
  void disconnect(Peer peer);

  /// Sends [message] to all [peers].
  void broadcast(Message message);

  /// Send a command of type [command] to [peer] with [arguments].
  void send(Peer peer, String command, Iterable<Object> arguments);

  /// Register [callback] to be run on commands received with type
  /// [command].
  void receive(String command, CommandHandler callback);

  /// Returns this [Node] as a [Peer].
  Peer toPeer();

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
  String get cookie => _delegate.cookie;

  @override
  String get hostname => _delegate.hostname;

  @override
  bool get isHidden => _delegate.isHidden;

  @override
  String get name => _delegate.name;

  @override
  Stream<Peer> get onConnect => _delegate.onConnect;

  @override
  Stream<Peer> get onDisconnect => _delegate.onDisconnect;

  @override
  Future<Null> get onShutdown => _delegate.onShutdown;

  @override
  Iterable<Peer> get peers => _delegate.peers;

  @override
  void createConnection(Peer peer) => _delegate.createConnection(peer);

  @override
  void addConnection(Peer peer, Connection connection) =>
      _delegate.addConnection(peer, connection);

  @override
  void disconnect(Peer peer) => _delegate.disconnect(peer);

  @override
  void broadcast(Message message) => _delegate.broadcast(message);

  @override
  void send(Peer peer, String commandType, Iterable<Object> arguments) {
    _delegate.send(peer, commandType, arguments);
  }

  @override
  void receive(String commandType, CommandHandler callback) {
    _delegate.receive(commandType, callback);
  }

  @override
  Peer toPeer() => _delegate.toPeer();

  @override
  Future<Null> shutdown() => _delegate.shutdown();
}
