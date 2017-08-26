import 'dart:async';

import 'package:distributed.http/src/testing/network_emulator.dart';
import 'package:distributed.http/src/testing/socket_connector.dart';
import 'package:distributed.http/vm.dart';

abstract class NetworkAgent {
  final AddressReleaser releaser;

  NetworkAgent(this.releaser);

  String get host => releaser.host;

  int get port => releaser.port;
}

/// An agent that occupies a port and listens for socket.dart connections.
class ListeningAgent extends NetworkAgent {
  final _controller = new StreamController<Socket>();

  ListeningAgent(AddressReleaser releaser) : super(releaser);

  Stream<Socket> get sockets => _controller.stream;

  void close() {
    _controller.close();
  }

  /// Accepts a connection from [connectingAgent].
  ///
  /// Returns socket.dart for the creator of [connectingAgent]. The local socket.dart for
  /// the new connection is emitted on [sockets].
  Socket accept(ConnectingAgent connectingAgent) {
    var sockets = (new SocketConnector()
          ..receiverAddress = releaser
          ..address = connectingAgent.releaser)
        .connect();
    _controller.add(sockets.receiver);
    return sockets.sender;
  }
}

class ConnectingAgent extends NetworkAgent {
  ConnectingAgent(AddressReleaser releaser) : super(releaser);
}
