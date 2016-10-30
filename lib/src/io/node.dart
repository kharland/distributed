import 'dart:async';

import 'dart:convert';
import 'dart:io';
import 'package:distributed/src/networking/message_channel.dart';
import 'package:distributed/src/networking/system_payloads.dart';
import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';

import 'package:distributed/src/system_action.dart' as system_action;
import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A node that runs on the Dart VM
class IONode implements Node {
  final StreamController<Message> _onMessage =
      new StreamController<Message>.broadcast();
  final StreamController<Peer> _onConnect =
      new StreamController<Peer>.broadcast();
  final StreamController<Peer> _onDisconnect =
      new StreamController<Peer>.broadcast();
  final StreamController<Null> _onLastConnectionClosed =
      new StreamController<Null>.broadcast();
  final Completer<Null> _onShutdown = new Completer<Null>();

  final Map<Peer, MessageChannel> _channels = <Peer, MessageChannel>{};
  final Map<Peer, StreamSubscription> _peerSubscriptions =
      <Peer, StreamSubscription>{};
  final List<StreamSubscription<Message>> _messageSubscriptions =
      <StreamSubscription<Message>>[];

  final _ChannelServer _socketHost;
  final List<Peer> _pendingPeers = <Peer>[];

  @override
  @virtual
  final String name;

  @override
  @virtual
  final String hostname;

  @override
  @virtual
  final int port;

  @override
  @virtual
  final String cookie;

  @override
  @virtual
  final bool isHidden;

  StreamSubscription<WebSocketChannel> _socketSubscription;
  Peer _asPeer;

  IONode._(this._socketHost,
      {this.name, this.hostname, this.port, this.cookie, this.isHidden}) {
    _socketSubscription = _socketHost.onChannel.listen(_handshake);
    _messageSubscriptions
        .add(receive(system_action.networkInfo).listen((Message message) {
      var info = NetworkInfo.fromJsonString(message.data);
      if (!isHidden) {
        for (var remotePeer in info.connectedPeers) {
          if (!peers.contains(remotePeer) && toPeer().name != remotePeer.name) {
            connectTo(remotePeer);
          }
        }
      }
    }));
  }

  /// Creates a new [IONode].
  ///
  /// Parameters are named for convenience. All except [isHidden] are required.
  static Future<IONode> create(
          {String name,
          String hostname,
          String cookie,
          int port,
          bool isHidden: false}) async =>
      new IONode._(new _ChannelServer(hostname, port: port),
          name: name,
          hostname: hostname,
          port: port,
          cookie: cookie,
          isHidden: isHidden);

  @override
  Stream<Peer> get onConnect => _onConnect.stream;

  @override
  Stream<Peer> get onDisconnect => _onDisconnect.stream;

  @override
  Future<Null> get onShutdown => _onShutdown.future;

  @override
  Iterable<Peer> get peers => new List.unmodifiable(_channels.keys);

  @override
  void connectTo(Peer peer) {
    _pendingPeers.add(peer);
    _handshake(new IOWebSocketChannel.connect(peer.url), initiate: true);
  }

  @override
  void disconnect(Peer peer) {
    if (peers.contains(peer)) {
      _channels.remove(peer).close();
    }
  }

  @override
  Future<Null> shutdown() async {
    await _socketSubscription.cancel();
    await _socketHost.close();
    _onMessage.close();
    _onConnect.close();
    if (peers.isNotEmpty) {
      peers.forEach(disconnect);
      await _onLastConnectionClosed.stream.take(1).last;
    }
    _messageSubscriptions.forEach((s) => s.cancel());
    _peerSubscriptions.values.forEach((s) => s.cancel());
    _peerSubscriptions.clear();
    _onDisconnect.close();
    _onShutdown.complete();
  }

  @override
  Peer toPeer() {
    if (_asPeer == null) {
      _asPeer = new Peer(name, hostname, port: port);
    }
    return _asPeer;
  }

  @override
  void send(Peer peer, String action, String data) {
    if (!peers.contains(peer)) {
      throw new ArgumentError('Peer not found: ${peer.displayName}');
    }
    _channels[peer].send(new Message(toPeer(), action, data));
  }

  @override
  Stream<Message> receive(String action) =>
      _onMessage.stream.where((Message message) => message.action == action);

  void _handshake(WebSocketChannel webSocketChannel, {bool initiate: false}) {
    var channel = new MessageChannel.from(webSocketChannel);
    var subscription;

    if (initiate) {
      channel.send(new Message(toPeer(), system_action.requestConnection,
          JSON.encode(new ConnectionRequest(toPeer(), cookie).toJson())));
    }

    subscription = channel.onMessage.listen((Message message) {
      var request = ConnectionRequest.fromJsonString(message.data);
      if (message.action == system_action.requestConnection) {
        if (request.cookie == cookie) {
          channel.send(new Message(toPeer(), system_action.acceptConnection,
              JSON.encode(new ConnectionRequest(toPeer(), cookie).toJson())));
          _addChannel(request.sender, channel);
        } else {
          _rejectHandshake(request.sender, channel);
        }
      } else if (message.action == system_action.acceptConnection) {
        if (request.cookie == cookie &&
            _pendingPeers.contains(request.sender)) {
          assert(!_channels.containsKey(request.sender));
          _addChannel(request.sender, channel);
        } else {
          _rejectHandshake(request.sender, channel);
        }
      } else if (message.action == system_action.rejectConnection) {
        channel.close();
        _onDisconnect.add(request.sender);
        if (_pendingPeers.contains(request.sender)) {
          _pendingPeers.remove(request.sender);
        }
        if (_channels.containsKey(request.sender)) {
          disconnect(request.sender);
        }
      }
      subscription.cancel();
    });
  }

  void _addChannel(Peer peer, MessageChannel channel) {
    channel.send(new Message(toPeer(), system_action.networkInfo,
        JSON.encode(new NetworkInfo(toPeer(), peers).toJson())));
    _channels[peer] = channel;
    _peerSubscriptions[peer] = channel.onMessage.listen(_onMessage.add);

    channel.onClose.then((_) {
      _channels.remove(peer);
      _peerSubscriptions.remove(peer).cancel();
      _onDisconnect.add(peer);
      if (_peerSubscriptions.isEmpty) {
        _onLastConnectionClosed.add(null);
      }
    });
    _onConnect.add(peer);
  }

  void _rejectHandshake(Peer peer, MessageChannel channel) {
    channel.send(new Message(toPeer(), system_action.rejectConnection,
        JSON.encode(new ConnectionRequest(toPeer()).toJson())));
    channel.close();
    _pendingPeers.remove(peer);
    _onDisconnect.add(peer);
  }
}

/// Listens for new WebSocket connections.
class _ChannelServer {
  final StreamController<WebSocketChannel> _onSocketConnectedController =
      new StreamController<WebSocketChannel>();
  StreamSubscription<HttpRequest> _serverSubscription;
  HttpServer _httpServer;

  _ChannelServer(String hostname, {int port: 9095}) {
    HttpServer.bind(hostname, port).then((HttpServer httpServer) {
      _httpServer = httpServer;
      _serverSubscription = _httpServer.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          _onSocketConnectedController.add(new IOWebSocketChannel(
              await WebSocketTransformer.upgrade(request)));
        }
      });
    });
  }

  Stream<WebSocketChannel> get onChannel => _onSocketConnectedController.stream;

  /// Stops listening for incoming connections.
  Future<Null> close() async {
    await _serverSubscription?.cancel();
    await _onSocketConnectedController?.close();
    await _httpServer.close();
  }
}
