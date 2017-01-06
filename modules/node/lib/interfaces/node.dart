import 'dart:async';

import 'package:distributed.node/interfaces/message.dart';
import 'package:distributed.node/interfaces/peer.dart';
import 'package:distributed.node/src/configuration.dart';
import 'package:distributed.port_daemon/client.dart';

/// A node in a distributed system.
///
/// Upon creation, the node immediately begins listening for connection
/// requests. A request is only accepted if the provided "cookie" matches this
/// node's [cookie].
///
/// If a node is hidden, it will not connect to another peers's peers when a new
/// connection is established.
///
/// If a peer is hidden, a node will not share that peer's information with
/// other peers when a new connection is made.
abstract class Node extends Peer {
  static const defaultCookie = '';
  static const defaultHostname = 'localhost';
  static const defaultPort = 9000;

  factory Node(String name,
          {String hostname: defaultHostname,
          String cookie: defaultCookie,
          int port: defaultPort,
          bool isHidden: false,
          DaemonClient daemonClient}) =>
      nodeProvider.create(
        name,
        hostname: hostname,
        cookie: cookie,
        port: port,
        isHidden: isHidden,
        daemonClient: daemonClient,
      );

  /// A string that another node must supply when requesting to connect with
  /// this node.
  String get cookie;

  /// The list of peers that are connected to this [Node].
  List<Peer> get peers;

  /// Emits events when this node connects to a [Peer].
  Stream<Peer> get onConnect;

  /// Emits events when this node disconnects from a [Peer].
  Stream<Peer> get onDisconnect;

  /// Completes when this node stops receiving and sending connections.
  Future<Null> get onShutdown;

  /// Completes when this node begins listening for connections.
  Future<Null> get onStartup;

  /// Connects to the remote peer identified by [name] and [hostname].
  void connect(Peer peer);

  /// Disconnects from the remote peer identified by [name] and [hostname].
  void disconnect(Peer peer);

  /// Send a command of type [action] to [peer] with [data].
  void send(Peer peer, String action, String data);

  /// Returns a stream that emits any [action] messages this node receives.
  Stream<Message> receive(String action);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future<Null> shutdown();
}
