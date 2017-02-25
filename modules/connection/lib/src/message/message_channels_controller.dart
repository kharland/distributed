import 'package:distributed.connection/connection.dart';
import 'package:distributed.connection/src/socket/socket_channels_controller.dart';

class MessageChannelsController {
  final Connection local;
  final Connection foreign;

  factory MessageChannelsController() {
    var socketChannelsController = new SocketChannelsController();
    var local = new Connection(socketChannelsController.local);
    var foreign = new Connection(socketChannelsController.foreign);
    return new MessageChannelsController._(local, foreign);
  }

  MessageChannelsController._(this.local, this.foreign);
}
