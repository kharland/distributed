import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/node.dart';
import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/message/message_channels.dart';
import 'package:distributed.node/src/socket/seltzer_socket.dart';
import 'package:distributed.node/src/socket/socket_channels.dart';
import 'package:seltzer/platform/vm.dart';

export 'package:distributed.node/src/connection/connection.dart';

class ConnectionServer {
  final StreamController<Connection> _connectionController =
      new StreamController<Connection>(sync: true);
  final SeltzerHttpServer _delegate;

  static Future<ConnectionServer> bind(address, int port, Peer localPeer,
      {Secret secret: Secret.acceptAny,
      int backlog: 0,
      bool v6Only: false,
      bool shared: false}) async {
    return new ConnectionServer._(
        await SeltzerHttpServer.bind(
          address,
          port,
          backlog: backlog,
          v6Only: v6Only,
          shared: shared,
        ),
        localPeer,
        secret);
  }

  ConnectionServer._(this._delegate, Peer localPeer, Secret secret) {
    _delegate.socketConnections.forEach((SeltzerWebSocket rawSocket) async {
      var socket = await SeltzerSocket.receive(rawSocket, secret: secret);
      var channels = new MessageChannels(await SocketChannels.incoming(socket));
      _connectionController.add(new Connection(localPeer, channels));
    });
  }

  Stream<Connection> get onConnection => _connectionController.stream;

  Future close({bool force: false}) => _delegate.close(force: force);
}
