import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/udp/data_builder.dart';
import 'package:distributed.ipc/src/udp/datagram_channel.dart';

class DatagramMessageSink implements Sink<Message> {
  final DataBuilder _dataBuilder;
  final DatagramChannel _channel;

  DatagramMessageSink(this._channel, this._dataBuilder);

  @override
  void add(Message message) {
    _dataBuilder.createDatagrams(message.content).forEach(_channel.add);
  }

  @override
  void close() {
    _channel.close();
  }
}
