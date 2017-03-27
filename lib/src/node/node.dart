import 'dart:async';

import 'package:distributed/src/monitoring/logging.dart';
import 'package:distributed/src/configuration.dart';
import 'package:distributed/src/objects/interfaces.dart';

/// A node in a distributed system.
abstract class Node {
  /// The name used to identify this node.
  String get name;

  // This node's host machine.
  HostMachine get hostMachine;

  /// The list of peers that are connected to this [Node].
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Returns a future that completes when this node has finished shutting down.
  Future get onShutdown;

  /// Connects this node to [peer].
  Future<bool> connect(Peer peer);

  /// Disconnects from the remote peer identified by [name].
  void disconnect(Peer peer);

  /// Returns a peer with the same information as this [Node].
  Peer toPeer();

  /// Send a command of type [category] to [peer] with [data].
  void send(Peer peer, String category, String data);

  /// Returns a stream that emits any [category] messages this node receives.
  Stream<Message> receive(String category);

  /// Closes all connections and disables the node.
  ///
  /// Returns [onShutdown].
  Future shutdown();

  static Future<Node> spawn(String name, {Logger logger}) =>
      nodeProvider.spawn(name, logger: logger ??= new Logger(name));
}
