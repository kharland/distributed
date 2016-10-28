import 'dart:async';

import 'dart:io';
import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/networking/connection/connection.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

import 'package:distributed/src/io/data_channel.dart';
import 'package:distributed/src/networking/message_handlers.dart';
import 'package:distributed/src/networking/data_channel.dart';
import 'package:meta/meta.dart';

/// A node that runs on the Dart VM
class IONode implements Node {
  final StreamController<Message> _onMessageController =
      new StreamController<Message>();
  final StreamController<Peer> _onConnectController =
      new StreamController<Peer>.broadcast();
  final StreamController<Peer> _onDisconnectController =
      new StreamController<Peer>.broadcast();
  final StreamController<Null> _onLastConnectionClosedController =
      new StreamController<Null>.broadcast();
  final Completer<Null> _onShutdownCompleter = new Completer<Null>();
  final List<MessageHandler> _messageHandlers = <MessageHandler>[];
  final Map<Peer, StreamSubscription> _connectionSubscriptions =
      <Peer, StreamSubscription>{};
  final Map<Peer, Connection> _connections = <Peer, Connection>{};
  final _SocketHost _socketHost;
  final Peer _asPeer;

  CommandMessageHandler _commandMessageHandler;

  @override
  @virtual
  final String name;

  @override
  @virtual
  final String hostname;

  @override
  @virtual
  final String cookie;

  @override
  @virtual
  final bool isHidden;

  StreamSubscription<WebSocket> _socketSubscription;

  IONode._(int port, _SocketHost socketHost,
      {String name, String hostname, this.cookie, bool isHidden})
      : name = name,
        hostname = hostname,
        isHidden = isHidden,
        _socketHost = socketHost,
        _asPeer = new Peer(name, hostname, port: port) {
    _commandMessageHandler = new CommandMessageHandler(this);
    _messageHandlers
      ..add(new PeerInfoMessageHandler(this))
      ..add(_commandMessageHandler);
    _socketSubscription =
        _socketHost.onSocketConnected.listen(_handleIncomingConnection);
  }

  /// Default constructor.
  ///
  /// Parameters are named for convenience. All except [isHidden] are required.
  static Future<IONode> create(
      {String name,
      String hostname,
      String cookie,
      int port,
      bool isHidden: false}) async {
    var socketHost = new _SocketHost(hostname, port: port);
    await socketHost.onStartup;
    return new IONode._(port, socketHost,
        name: name, hostname: hostname, cookie: cookie, isHidden: isHidden);
  }

  @override
  Stream<Peer> get onConnect => _onConnectController.stream;

  @override
  Stream<Peer> get onDisconnect => _onDisconnectController.stream;

  @override
  Future<Null> get onShutdown => _onShutdownCompleter.future;

  @override
  Iterable<Peer> get peers => new List.unmodifiable(_connections.keys);

  @override
  void createConnection(Peer peer) {
    Connection connection;
    DataChannel.connect(cookie, toPeer(), peer).then((DataChannel dataChannel) {
      connection = new Connection(dataChannel as DataChannel<String>);
      connection.send(new ConnectMessage(cookie, toPeer(), peer));
      connection.send(new PeerInfoMessage(toPeer(), peers));
      addConnection(peer, connection);
    });
  }

  @override
  void addConnection(Peer peer, Connection connection) {
    _connections[peer] = connection;
    _connectionSubscriptions[peer] =
        connection.onMessage.listen((Message message) {
      _onMessageController.add(message);
      for (MessageHandler handler in _messageHandlers) {
        if (handler.filter(message)) {
          handler.execute(message);
          break;
        }
      }
    });
    connection.onClose.then((_) {
      _connections.remove(peer);
      _connectionSubscriptions.remove(peer).cancel();
      _onDisconnectController.add(peer);
      if (_connectionSubscriptions.isEmpty) {
        _onLastConnectionClosedController.add(null);
      }
    });
    _onConnectController.add(peer);
  }

  @override
  void disconnect(Peer peer) {
    // Actual cleanup happens inside the callback to the given connection's
    // onClose future.
    //
    // This is imperative because the peer might close the connection first.
    if (peers.contains(peer)) {
      _connections.remove(peer).close();
    }
  }

  @override
  void broadcast(Message message) {
    for (Connection connection in _connections.values) {
      connection.send(message);
    }
  }

  @override
  Future<Null> shutdown() async {
    await _socketSubscription.cancel();
    await _socketHost.close();
    _onMessageController.close();
    _onConnectController.close();
    if (peers.isNotEmpty) {
      peers.forEach(disconnect);
      await _onLastConnectionClosedController.stream.take(1).last;
    }
    _onDisconnectController.close();
    _onShutdownCompleter.complete();
  }

  @override
  Peer toPeer() => _asPeer;

  void _handleIncomingConnection(WebSocket webSocket) {
    var connection = new Connection(new IODataChannel<String>(webSocket));
    connection.onMessage.take(1).last.then((Message message) {
      var connectionRequest = message as ConnectMessage;
      if (connectionRequest.cookie == cookie &&
          connectionRequest.peer.name == name) {
        connection.send(new PeerInfoMessage(toPeer(), peers));
        addConnection(connectionRequest.sender, connection);
      } else {
        connection.close();
      }
    });
  }

  @override
  void receive(String commandType, CommandHandler callback) {
    _commandMessageHandler.registerHandler(commandType, callback);
  }

  @override
  void send(Peer peer, String commandType, Iterable<Object> arguments) {
    if (!peers.contains(peer)) {
      throw new ArgumentError('Peer not found: ${peer.displayName}');
    }
    _connections[peer]
        .send(new CommandMessage(toPeer(), commandType, arguments));
  }
}

/// Listens for new WebSocket connections.
class _SocketHost {
  final Completer<Null> _onStartupCompleter = new Completer();
  final StreamController<WebSocket> _onSocketConnectedController =
      new StreamController<WebSocket>();
  StreamSubscription<HttpRequest> _serverSubscription;
  HttpServer _httpServer;

  _SocketHost(String hostname, {int port: 9095}) {
    HttpServer.bind(hostname, port).then((HttpServer httpServer) {
      _onStartupCompleter.complete();
      _httpServer = httpServer;
      _serverSubscription = _httpServer.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          var webSocket = await WebSocketTransformer.upgrade(request);
          _onSocketConnectedController.add(webSocket);
        }
      });
    });
  }

  Future<Null> get onStartup => _onStartupCompleter.future;

  Stream<WebSocket> get onSocketConnected =>
      _onSocketConnectedController.stream;

  /// Stops listening for incoming connections.
  Future<Null> close() async {
    await _serverSubscription.cancel();
    await _onSocketConnectedController.close();
    await _httpServer.close(force: true);
  }
}
