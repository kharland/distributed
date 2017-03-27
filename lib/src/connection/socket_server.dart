import 'dart:async';

import 'package:distributed/src/connection/socket.dart';
import 'package:seltzer/platform/vm.dart';

import 'seltzer_socket.dart';

class SocketServer {
  final SeltzerHttpServer _delegate;
  final _onSocketController = new StreamController<Socket>(sync: true);

  SocketServer._(this._delegate) {
    _delegate.socketConnections
        .map(SeltzerSocket.receive)
        .forEach(_onSocketController.add);
  }

  static Future<SocketServer> bind(
    address,
    int port, {
    int backlog: 0,
    bool v6Only: false,
    bool shared: false,
  }) async =>
      new SocketServer._(
        await SeltzerHttpServer.bind(
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
        _delegate.close(force: force),
      ]);
}
