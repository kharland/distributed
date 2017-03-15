import 'package:distributed.connection/src/socket/socket_channels.dart';
import 'package:distributed.connection/src/socket/socket_controller.dart';
import 'package:stream_channel/stream_channel.dart';

class SocketChannelsController {
  final SocketChannels local;
  final SocketChannels foreign;

  factory SocketChannelsController() {
    var userSockets = new SocketController();
    var systemSockets = new SocketController();
    var local = new SocketChannels(
      new StreamChannel(userSockets.local, userSockets.local),
      new StreamChannel(systemSockets.local, systemSockets.local),
    );
    var foreign = new SocketChannels(
      new StreamChannel(userSockets.foreign, userSockets.foreign),
      new StreamChannel(systemSockets.foreign, systemSockets.foreign),
    );
    return new SocketChannelsController._(local, foreign);
  }

  SocketChannelsController._(this.local, this.foreign);
}
