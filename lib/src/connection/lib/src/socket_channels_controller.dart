import 'package:distributed.connection/src/socket_channels.dart';
import 'package:distributed.connection/src/socket_controller.dart';

class SocketChannelsController {
  final SocketChannels local;
  final SocketChannels foreign;

  factory SocketChannelsController() {
    final sockets = new SocketController();
    return new SocketChannelsController._(
      new SocketChannels(sockets.local),
      new SocketChannels(sockets.foreign),
    );
  }

  SocketChannelsController._(this.local, this.foreign);

  void close() {
    local.close();
    foreign.close();
  }
}
