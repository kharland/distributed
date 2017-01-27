import 'package:distributed.node/src/connection/connection.dart';
import 'package:distributed.node/src/message/message_channels.dart';
import 'package:distributed.node/src/peer.dart';
import 'package:distributed.node/testing/socket_channels_controller.dart';

class ConnectionController {
  final Connection local;
  final Connection foreign;

  factory ConnectionController(Peer localPeer, Peer foreignPeer) {
    var channelsController = new SocketChannelsController();
    return new ConnectionController._(
      new Connection(
        localPeer,
        new MessageChannels(channelsController.local),
      ),
      new Connection(
        foreignPeer,
        new MessageChannels(channelsController.foreign),
      ),
    );
  }

  ConnectionController._(this.local, this.foreign);
}
