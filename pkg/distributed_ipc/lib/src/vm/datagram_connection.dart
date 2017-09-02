import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:meta/meta.dart';

class DatagramConnection extends EventSource<Message> implements Connection {
  @override
  final String localAddress;

  @override
  final String remoteAddress;

  @override
  final int localPort;

  @override
  final int remotePort;

  final EventSource<Message> _messageSource;
  final Sink<Message> _messageSink;

  DatagramConnection(
    this._messageSource,
    this._messageSink, {
    @required this.localAddress,
    @required this.localPort,
    @required this.remoteAddress,
    @required this.remotePort,
  }) {
    _messageSource.onEvent(emit);
  }

  @override
  void add(Message message) {
    _messageSink.add(message);
  }

  @override
  void close() {
    _messageSink.close();
  }
}
