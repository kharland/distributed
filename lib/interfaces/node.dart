import 'dart:async';

import 'package:distributed/src/networking/connection/connection.dart';
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/repl.dart';

typedef void CommandHandler(Peer sender, Set arguments);

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

  /// Send a command of type [commandType] to [peer] with [arguments].
  void send(Peer peer, String commandType, Iterable<Object> arguments);

  /// Register [callback] to be run on commands received with type
  /// [commandType].
  void receive(String commandType, CommandHandler callback);

  /// Sends [message] to all [peers].
  void broadcast(Message message);

  /// Closes all connections and disables the node. Be sure to call [disconnect]
  /// before calling [shutdown] to remove the node from any connected networks.
  Future<Null> shutdown();

  /// Returns this [Node] as a [Peer].
  Peer toPeer();
}

/// A [Node] that delegates to another [Node].
///
/// Prefer extending this to add functionality to a [Node].
class DelegatingNode implements Node {
  final Node _delegate;

  DelegatingNode(this._delegate);

  @override
  void createConnection(Peer peer) => _delegate.createConnection(peer);

  @override
  void addConnection(Peer peer, Connection connection) =>
      _delegate.addConnection(peer, connection);

  @override
  String get cookie => _delegate.cookie;

  @override
  void disconnect(Peer peer) => _delegate.disconnect(peer);

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
  List<Peer> get peers => _delegate.peers;

  @override
  Peer toPeer() => _delegate.toPeer();

  @override
  void broadcast(Message message) => _delegate.broadcast(message);

  @override
  Future<Null> shutdown() => _delegate.shutdown();

  @override
  void send(Peer peer, String commandType, Iterable<Object> arguments) {
    _delegate.send(peer, commandType, arguments);
  }

  @override
  void receive(String commandType, CommandHandler callback) {
    _delegate.receive(commandType, callback);
  }
}

class InteractiveNode extends DelegatingNode {
  final REPL _repl;
  List<StreamSubscription> _nodeSubscriptions = <StreamSubscription>[];

  InteractiveNode(Node node, {String prefix: '> ', String startupMessage: ''})
      : _repl = new REPL(prefix: prefix, startupMessage: startupMessage),
        super(node) {
    _repl.log('Node ${node.name} listening at ${node.toPeer().url}...');
    _nodeSubscriptions.addAll(<StreamSubscription>[
      node.onConnect.listen((peer) {
        _repl.log('connected to ${peer.displayName}');
      }),
      node.onDisconnect.listen((peer) {
        _repl.log('disconnected from ${peer.displayName}');
      }),
    ]);
    node.onShutdown.then((_) {
      _repl.log('${node.toPeer().displayName} successfully shut down.');
      _repl.stop();
    });

    Peer _parsePeer(String peerStr) {
      var parts = peerStr.split('@');
      if (parts.length < 2) {
        _repl.log('Invalid peer name $peerStr.');
        _repl.log('Specify a peer using the format: <name>@<hostname>:<port>');
        _repl.log('The port number is optional (default 8080)');
        return null;
      }
      var port = 8080;
      var hostname = parts.last;
      var hostnameParts = parts.last.split(':');
      if (hostnameParts.length > 1) {
        hostname = hostnameParts.first;
        port = int.parse(hostnameParts.last);
      }

      return new Peer(parts.first, hostname, port: port);
    }

    _repl.onInput.listen((String input) {
      if (input.trim() == 'quit') {
        node.shutdown();
      }
      var args = input.split(' ').map((s) => s.trim()).toList();
      if (args.first.trim() == 'connect') {
        Peer peer = _parsePeer(args[1]);
        if (peer == null) return;
        if (!peers.contains(peer)) {
          _repl.log('connecting to ${peer.displayName}');
          try {
            node.createConnection(peer);
          } catch (_) {
            _repl.log('unable to connect to $peer');
          }
        }
        return;
      }

      if (args.first.trim() == 'list') {
        _repl.log('Connected peers:');
        for (int peerno = 0; peerno < peers.length; peerno++) {
          var peer = peers[peerno];
          _repl.log('${peerno+1}. ${peer.displayName} --> ${peer.url}');
        }
        return;
      }

      if (args.first.trim() == 'disconnect') {
        Peer peer = _parsePeer(args[1]);
        if (peer == null) return;
        node.disconnect(peer);
        return;
      }

      if (args.first.trim() == 'send') {
        Peer peer = _parsePeer(args[1]);
        if (peers.map((p) => p.name).contains(peer.name)) {
          String command = args[2];
          List<String> params = args.skip(3).toList();
          node.send(peer, command, params);
          _repl.log('Sent ${peer.displayName} command: $command $params');
        } else {
          _repl.log('Not connected to any peer named ${peer.name}');
        }
        return;
      }
    });
  }

  Stream<String> get onInput => _repl.onInput;

  @override
  Future<Null> shutdown() {
    for (var subscription in _nodeSubscriptions) {
      subscription.cancel();
    }
    _nodeSubscriptions.clear();
    return super.shutdown();
  }

  void log(String message) {
    _repl.log(message);
  }
}
