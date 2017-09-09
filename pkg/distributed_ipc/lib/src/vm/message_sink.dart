import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/udp/data_builder.dart';
import 'package:distributed.ipc/src/udp/data_channel.dart';

class MessageSink implements Sink<Message> {
  final DataBuilder _dataBuilder;
  final DataChannel _channel;

  MessageSink(this._channel, this._dataBuilder);

  @override
  void add(Message message) {
    _dataBuilder.splitIntoParts(message.content).forEach(_channel.add);
  }

  @override
  void close() {
    _channel.close();
  }
}
