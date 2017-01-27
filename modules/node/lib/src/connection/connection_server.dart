import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.node/src/peer_identification_strategy.dart';
import 'package:distributed.node/src/socket/seltzer_socket.dart';
import 'package:seltzer/platform/vm.dart';

export 'package:distributed.node/src/connection/connection.dart';

class ConnectionServer {
  final ConnectionChannelsProvider<Message> _channelsProvider;
  final PeerIdentificationStrategy _identificationStrategy;
  final StreamController<Connection> _channelsController =
      new StreamController<Connection>(sync: true);
  final SeltzerHttpServer _delegate;

  ConnectionServer._(
    this._delegate,
    this._channelsProvider,
    this._identificationStrategy, {
    Secret secret: Secret.acceptAny,
  }) {
    _delegate.socketConnections.forEach((SeltzerWebSocket rawSocket) async {
      var socket = await receiveSeltzerSocket(rawSocket, secret: secret);
      var channels = await _channelsProvider.createFromSocket(socket);
      var remotePeerAddress = socket.address;
      var remotePeerName = await _identificationStrategy.identifyRemote(
        channels.system.sink,
        channels.system.stream,
      );
      var remotePeer = new Peer(remotePeerName, remotePeerAddress);
      _channelsController.add(new Connection(remotePeer, channels));
    });
  }

  static Future<ConnectionServer> bind(
    address,
    int port,
    ConnectionChannelsProvider<Message> channelsProvider,
    PeerIdentificationStrategy identificationStrategy, {
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
        identificationStrategy,
      );

  Stream<Connection> get onConnection => _channelsController.stream;

  Future close({bool force: false}) => _delegate.close(force: force);
}
