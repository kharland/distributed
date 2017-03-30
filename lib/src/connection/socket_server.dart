import 'dart:async';
import 'dart:io' as io;

import 'package:distributed/src/connection/http_socket.dart';
import 'package:distributed/src/connection/socket.dart';

class SocketServer {
  final io.ServerSocket _delegate;
  final _onSocketController = new StreamController<HttpSocket>(sync: true);

  SocketServer._(this._delegate) {
    _delegate.asyncMap(HttpSocket.receive).forEach(_onSocketController.add);
  }

  static Future<SocketServer> bind(
    address,
    int port, {
    int backlog: 0,
    bool v6Only: false,
    bool shared: false,
  }) async =>
      new SocketServer._(
        await io.ServerSocket.bind(
          address,
          port,
          backlog: backlog,
          v6Only: v6Only,
          shared: shared,
        ),
      );

  Stream<Socket> get onSocket => _onSocketController.stream;

  Future close({bool force: false}) => Future.wait([
        _onSocketController.close(),
        _delegate.close(),
      ]);
}
