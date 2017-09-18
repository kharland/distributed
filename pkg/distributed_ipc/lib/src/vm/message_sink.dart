import 'dart:convert';
import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/data_channel.dart';

class MessageSink implements Sink<Message> {
  final DataChannel _channel;

  MessageSink(this._channel);

  @override
  void add(
    Message message, [
    Converter<String, List<int>> encoder = utf8Encoder,
  ]) {
    _channel.add(encoder.convert(message.content));
  }

  @override
  void close() {
    _channel.close();
  }
}
