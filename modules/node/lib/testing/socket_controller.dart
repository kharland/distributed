import 'package:distributed.node/src/socket/socket.dart';
import 'package:stream_channel/stream_channel.dart';

class SocketController {
  static const _defaultAddress = 'localhost';
  final Socket local;
  final Socket foreign;

  factory SocketController() {
    var controller = new StreamChannelController<String>();
    var localSocket = new Socket(
      controller.local.sink,
      controller.local.stream,
    );
    var foreignSocket = new Socket(
      controller.foreign.sink,
      controller.foreign.stream,
    );
    return new SocketController._(localSocket, foreignSocket);
  }

  factory SocketController.broadcast([
    String localAddress = _defaultAddress,
    String remoteAddress = _defaultAddress,
  ]) {
    var controller = new StreamChannelController<String>();
    var localSocket = new Socket(
      controller.local.sink,
      controller.local.stream.asBroadcastStream(),
    );
    var foreignSocket = new Socket(
      controller.foreign.sink,
      controller.foreign.stream.asBroadcastStream(),
    );
    return new SocketController._(localSocket, foreignSocket);
  }

  SocketController._(this.local, this.foreign);
}
