import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/data_builder.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';

class MessageSource extends EventSource<Message> {
  final _currentBuffer = <Datagram>[];

  MessageSource(EventSource<Datagram> dgSource, DataBuilder dataBuilder) {
    dgSource.onEvent((Datagram datagram) {
      switch (datagram.type) {
        case DatagramType.END:
          emit(new Message(dataBuilder.assembleDatagrams(_currentBuffer)));
          return;
        case DatagramType.DATA:
          _currentBuffer.add(datagram);
          return;
        default:
          throw new UnsupportedError(datagram.type.toString());
      }
    });
  }
}
