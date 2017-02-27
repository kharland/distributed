import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket/seltzer_socket.dart';
import 'package:seltzer/platform/vm.dart';

class SocketServer {
  final SeltzerHttpServer _delegate;
  final _onSocketController = new StreamController<Socket>(sync: true);

  SocketServer._(this._delegate) {
    _delegate.socketConnections.forEach((SeltzerWebSocket rawSocket) async {
      _onSocketController.add(receiveSeltzerSocket(rawSocket));
    });
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

  Future close({bool force: false}) => _delegate.close(force: force);
}
