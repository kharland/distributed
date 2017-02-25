import 'dart:async';

import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/data_channels.dart';
import 'package:distributed.connection/src/socket/seltzer_socket.dart';
import 'package:distributed.net/secret.dart';
import 'package:seltzer/platform/vm.dart';

class ConnectionServer {
  final DataChannelsProvider<String> _dataChannelsProvider;
  final StreamController<Connection> _channelsController =
      new StreamController<Connection>(sync: true);
  final SeltzerHttpServer _delegate;

  ConnectionServer._(
    this._delegate,
    this._dataChannelsProvider, {
    Secret secret: Secret.acceptAny,
  }) {
    _delegate.socketConnections.forEach((SeltzerWebSocket rawSocket) async {
      var socket = await receiveSeltzerSocket(rawSocket, secret: secret);
      var channels = await _dataChannelsProvider.createFromSocket(socket);
      _channelsController.add(new Connection(channels));
    });
  }

  static Future<ConnectionServer> bind(
    address,
    int port,
    DataChannelsProvider<String> channelsProvider, {
    Secret secret: Secret.acceptAny,
    int backlog: 0,
    bool v6Only: false,
    bool shared: false,
  }) async =>
      new ConnectionServer._(
        await SeltzerHttpServer.bind(
          address,
          port,
          backlog: backlog,
          v6Only: v6Only,
          shared: shared,
        ),
        channelsProvider,
      );

  Stream<Connection> get onConnection => _channelsController.stream;

  Future close({bool force: false}) => _delegate.close(force: force);
}
