import 'dart:async';

import 'dart:io';
import 'package:distributed/interfaces/connection.dart';
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

import 'package:distributed/src/io/data_channel.dart';
import 'package:distributed/src/networking/message_handlers.dart';
import 'package:distributed/src/networking/platform_data_channel.dart';
import 'package:meta/meta.dart';

/// A node that runs on the Dart VM
class IONode implements Node {
  final StreamController<Message> _onMessageController =
      new StreamController<Message>();
  final StreamController<Peer> _onConnectController =
      new StreamController<Peer>.broadcast();
  final StreamController<Peer> _onDisconnectController =
      new StreamController<Peer>();
  final Completer<Null> _onShutdownCompleter = new Completer<Null>();
  final List<MessageHandler> _messageHandlers = <MessageHandler>[];
  final Map<Peer, StreamSubscription> _connectionSubscriptions =
      <Peer, StreamSubscription>{};
  final Map<Peer, Connection> _connections = <Peer, Connection>{};
  final _SocketHost _socketHost;
  final int _port;

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
      {this.name, this.hostname, this.cookie, this.isHidden})
      : _port = port,
        _socketHost = socketHost {
    _messageHandlers..add(new PeerInfoMessageHandler(this));
    _socketSubscription =
        _socketHost.onSocketConnected.listen(_handleIncomingConnection);
  }

  /// Default constructor.
  ///
  /// Parameters are named for convenience, but all are required.
  static Future<IONode> create(
      {String name,
      String hostname,
      String cookie,
      int port,
      bool isHidden}) async {
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
  Stream<Message> get onMessage => _onMessageController.stream;

  @override
  Future<Null> get onShutdown => _onShutdownCompleter.future;

  @override
  Iterable<Peer> get peers => _connections.keys;

  @override
  Future<Null> createConnection(Peer peer) async {
    var connection = new Connection(
        await PlatformDataChannel.connect(cookie, toPeer(), peer));
    addConnection(peer, connection);
    connection.send(new PeerInfoMessage(toPeer(), peers));
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
      _connectionSubscriptions.remove(peer)..cancel();
      _onDisconnectController.add(peer);
    });
    _onConnectController.add(peer);
  }

  @override
  Future<Null> disconnect(Peer peer) async {
    if (peers.contains(peer)) {
      var connection = _connections.remove(peer);
      connection.close();
      await connection.onClose;
    }
  }

  @override
  Future<Null> send(Message message, Peer peer) async {
    if (peers.contains(peer)) {
      _connections[peer].send(message);
    } else {
      throw new ArgumentError("Unknown peer ${peer.displayName}");
    }
  }

  @override
  Future<Null> broadcast(Message message) async {
    for (Connection connection in _connections.values) {
      connection.send(message);
    }
  }

  @override
  Future<Null> shutdown() async {
    await _socketSubscription.cancel();
    await _socketHost.close();
    await Future.wait(peers.map(disconnect));
    _onMessageController.close();
    _onConnectController.close();
    _onDisconnectController.close();
    _onShutdownCompleter.complete();
  }

  @override
  Peer toPeer() => new Peer(name, hostname, port: _port, isHidden: isHidden);

  void _handleIncomingConnection(WebSocket webSocket) {
    StreamSubscription<String> dataSubscription;
    var dataChannel = new IODataChannel<String>(webSocket);
    dataSubscription = dataChannel.onData.take(1).listen((String payload) {
      var request = new ConnectMessage.fromString(payload);
      if (request.cookie == cookie) {
        var connection = new Connection(dataChannel);
        addConnection(request.sender, connection);
        connection.send(new PeerInfoMessage(toPeer(), peers));
      } else {
        dataChannel.close();
      }
      dataSubscription.cancel();
    });
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
