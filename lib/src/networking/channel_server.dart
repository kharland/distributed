import 'dart:async';

import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A simple websocket server that emits a WebSocketChannel when a connection
/// is received.
class ChannelServer {
  final StreamController<WebSocketChannel> _onChannel =
      new StreamController<WebSocketChannel>();
  final StreamController<WebSocket> _onSocket =
      new StreamController<WebSocket>();
  final Completer<Null> _onStartup = new Completer<Null>();

  StreamSubscription<HttpRequest> _serverSubscription;
  HttpServer _httpServer;

  ChannelServer(String hostname, [int port = 9095]) {
    HttpServer.bind(hostname, port).then((HttpServer httpServer) {
      _httpServer = httpServer;
      _onStartup.complete();
      _serverSubscription = _httpServer.listen((HttpRequest request) async {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          var socket = await WebSocketTransformer.upgrade(request);
          _onSocket.add(socket);
          _onChannel.add(new IOWebSocketChannel(socket));
        }
      });
    });
  }

  Future<Null> get onStartup => _onStartup.future;

  Stream<WebSocket> get onSocket => _onSocket.stream;

  Stream<WebSocketChannel> get onChannel => _onChannel.stream;

  /// Stops listening for incoming connections.
  Future<Null> stop() async {
    await _serverSubscription?.cancel();
    await _onChannel.close();
    await _httpServer.close();
  }
}
