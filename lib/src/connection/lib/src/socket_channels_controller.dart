import 'package:distributed.connection/src/message_router.dart';
import 'package:distributed.connection/src/socket_controller.dart';

class SocketChannelsController {
  final MessageRouter local;
  final MessageRouter foreign;

  factory SocketChannelsController() {
    final sockets = new SocketController();
    return new SocketChannelsController._(
      new MessageRouter(sockets.local),
      new MessageRouter(sockets.foreign),
    );
  }

  SocketChannelsController._(this.local, this.foreign);

  void close() {
    local.close();
    foreign.close();
  }
}
