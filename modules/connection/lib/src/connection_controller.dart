import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/connection.dart';
import 'package:distributed.connection/src/socket/socket_channels_controller.dart';

class ConnectionChannelsController {
  final DataChannels local;
  final DataChannels foreign;

  factory ConnectionChannelsController() {
    var channelsController = new SocketChannelsController();
    return new ConnectionChannelsController._(
      new Connection(channelsController.local),
      new Connection(channelsController.foreign),
    );
  }

  ConnectionChannelsController._(this.local, this.foreign);
}
