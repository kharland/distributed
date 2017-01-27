import 'package:distributed.node/src/socket/socket_channels.dart';
import 'package:stream_channel/stream_channel.dart';

import 'socket_controller.dart';

class SocketChannelsController {
  final SocketChannels local;
  final SocketChannels foreign;

  factory SocketChannelsController() {
    var userSockets = new SocketController();
    var systemSockets = new SocketController();
    var errorSockets = new SocketController();
    var local = new SocketChannels(
      new StreamChannel(userSockets.local, userSockets.local),
      new StreamChannel(systemSockets.local, systemSockets.local),
      new StreamChannel(errorSockets.local, errorSockets.local),
    );
    var foreign = new SocketChannels(
      new StreamChannel(userSockets.foreign, userSockets.foreign),
      new StreamChannel(systemSockets.foreign, systemSockets.foreign),
      new StreamChannel(errorSockets.foreign, errorSockets.foreign),
    );
    return new SocketChannelsController._(local, foreign);
  }

  SocketChannelsController._(this.local, this.foreign);
}
