import 'dart:async';

import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/command.dart';
import 'package:distributed/src/networking/connection/connection.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/repl.dart';

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
  Iterable<Peer> get peers => _delegate.peers;

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

/// TODO: delete when I have internet access and can look up
/// an existing class which implements StringSink.
class _StringSink implements StringSink {
  StreamController<String> _onMessageController =
      new StreamController<String>();

  Stream<String> get onMessage => _onMessageController.stream;

  @override
  void write(Object obj) {
    _onMessageController.add(obj);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    for (int i = 0; i < objects.length - 1; i++) {
      write('${objects.elementAt(i)}$separator');
    }
    write('${objects.last}');
  }

  @override
  void writeCharCode(int charCode) {
    throw new UnimplementedError();
  }

  @override
  void writeln([Object obj = ""]) {
    throw new UnimplementedError();
  }

  void close() {
    _onMessageController.close();
  }
}

/// A Node that launches an interactive shell and accepts commands.
class InteractiveNode extends DelegatingNode {
  CommandRunner _commandRunner;
  final _StringSink _errorSink = new _StringSink();
  final _StringSink _logSink = new _StringSink();

  final REPL _repl;
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  InteractiveNode(Node node, {String prompt: '> '})
      : _repl = new REPL(prompt),
        super(node) {
    _commandRunner = new CommandRunner()
      ..addCommand(new ConnectCommand(this, _errorSink))
      ..addCommand(new DisconnectCommand(this, _errorSink))
      ..addCommand(new SendCommand(this, _errorSink))
      ..addCommand(new ListCommand(this, _logSink))
      ..addCommand(new QuitCommand(this));

    onShutdown.then((_) {
      _subscriptions.forEach((s) => s.cancel());
      _repl.stop();
      print('${toPeer().displayName} successfully shut down.');
    });

    _subscriptions.addAll(<StreamSubscription>[
      _errorSink.onMessage.listen(logError),
      _logSink.onMessage.listen(log),
      onConnect.listen((peer) {
        log('connected to ${peer.displayName}');
      }),
      onDisconnect.listen((peer) {
        log('disconnected from ${peer.displayName}');
      }),
      _repl.onInput.listen((String input) {
        var args = input.split(' ').map((s) => s.trim()).toList();
        _commandRunner.parseAndRun(args);
      })
    ]);

    _repl.start();
    log('Node $name listening at ${toPeer().url}...');
  }

  Stream<String> get onInput => _repl.onInput;

  void log(String message) {
    _repl.log(message);
  }
  
  void logError(String message) {
    _repl.log('[Error] $message');
  }
}
