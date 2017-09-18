import 'dart:convert';
import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';

class MessageSource extends EventSource<Message> {
  MessageSource(
    EventSource<Datagram> dgSource, [
    Converter<List<int>, String> decoder = utf8Decoder,
  ]) {
    dgSource.onEvent((Datagram datagram) {
      switch (datagram.type) {
        case DatagramType.DATA:
          emit(new Message(decoder.convert(datagram.data)));
          return;
        default:
          throw new UnsupportedError(datagram.type.toString());
      }
    });
  }
}
