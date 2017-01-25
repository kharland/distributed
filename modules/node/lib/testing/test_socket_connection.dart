import 'dart:async';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:stream_channel/stream_channel.dart';

class TestSocketConnection {
  final Socket local;
  final Socket foreign;

  factory TestSocketConnection() {
    var controller = new StreamChannelController<String>();
    var localSocket = new _TestSocket(
      controller.local.sink,
      controller.local.stream,
    );
    var foreignSocket = new _TestSocket(
      controller.foreign.sink,
      controller.foreign.stream,
    );
    return new TestSocketConnection._(localSocket, foreignSocket);
  }

  TestSocketConnection._(this.local, this.foreign);
}

class _TestSocket extends StreamView<String> implements Socket {
  final StreamSink<String> _sink;

  _TestSocket(this._sink, Stream<String> stream) : super(stream);

  @override
  void add(String event) {
    _sink.add(event);
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  Future addStream(Stream<String> stream) => _sink.addStream(stream);

  @override
  Future close() => _sink.close();

  @override
  Future get done => _sink.done;
}
