import 'dart:async';

import 'package:distributed.connection/src/socket/seltzer_socket.dart';

/// A bidirectional communication channel.
class Socket extends StreamView<String> implements StreamSink<String> {
  final StreamSink<String> _sink;

  Socket(this._sink, Stream<String> stream) : super(stream);

  /// Initiates a [Socket] connection over [url].
  static Future<Socket> connect(String url) => connectSeltzerSocket(url);

  /// The host address of this socket
  String get address => throw new UnimplementedError();

  @override
  Future get done => _sink.done;

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  Future addStream(Stream<String> stream) => _sink.addStream(stream);

  @override
  Future close() async => _sink.close();
}
