import 'dart:async';
import 'package:async/async.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BroadcastWebSocketChannel implements WebSocketChannel {
  final StreamSplitter _splitter;
  final WebSocketChannel _channel;

  BroadcastWebSocketChannel(WebSocketChannel channel)
      : _channel = channel,
        _splitter = new StreamSplitter(channel.stream);

  @override
  StreamChannel/*<S>*/ cast/*<S>*/() => _channel.cast();

  @override
  StreamChannel changeSink(StreamSink change(StreamSink sink)) =>
      _channel.changeSink(change);

  @override
  StreamChannel changeStream(Stream change(Stream stream)) =>
      _channel.changeStream(change);

  @override
  int get closeCode => _channel.closeCode;

  @override
  String get closeReason => _channel.closeReason;

  @override
  void pipe(StreamChannel other) => _channel.pipe(other);

  @override
  String get protocol => _channel.protocol;

  @override
  WebSocketSink get sink => _channel.sink;

  @override
  Stream get stream => _splitter.split();

  @override
  StreamChannel transform(StreamChannelTransformer transformer) =>
      _channel.transform(transformer);

  @override
  StreamChannel transformSink(StreamSinkTransformer transformer) =>
      _channel.transformSink(transformer);

  @override
  StreamChannel transformStream(StreamTransformer transformer) =>
      _channel.transformStream(transformer);
}
