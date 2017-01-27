import 'package:distributed.node/src/message/message_channels.dart';
import 'package:distributed.node/src/socket/socket_channels_controller.dart';

class MessageChannelsController {
  final MessageChannels local;
  final MessageChannels foreign;

  factory MessageChannelsController() {
    var socketChannelsController = new SocketChannelsController();
    var local = new MessageChannels(socketChannelsController.local);
    var foreign = new MessageChannels(socketChannelsController.foreign);
    return new MessageChannelsController._(local, foreign);
  }

  MessageChannelsController._(this.local, this.foreign);
}
