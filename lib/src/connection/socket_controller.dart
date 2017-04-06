import 'dart:async';

import 'package:distributed.http/vm.dart';
import 'package:stream_channel/stream_channel.dart';

// TODO: delete.
class SocketController {
  final Socket local;
  final Socket foreign;

  factory SocketController() {
    var controller = new StreamChannelController<String>();
    return new SocketController._(
        new TestSocket(
          controller.local.sink,
          controller.local.stream.asBroadcastStream(),
        ),
        new TestSocket(
          controller.foreign.sink,
          controller.foreign.stream.asBroadcastStream(),
        ));
  }

  SocketController._(this.local, this.foreign);

  void close() {
    local.close();
    foreign.close();
  }
}

class TestSocket extends StreamView<String> implements Socket {
  final Sink<String> _sink;

  TestSocket(this._sink, Stream<String> stream) : super(stream);

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  void close() {
    _sink.close();
  }

  @override
  String get localHost => null;

  @override
  int get port => null;

  @override
  String get remoteHost => null;
}
