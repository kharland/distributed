import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';
import 'package:distributed.ipc/src/message.dart';
import 'package:meta/meta.dart';

/// A connection between two processes.
class Connection implements Sink<Message> {
  final _consumers = <Consumer<Message>>[];

  /// This connection's local address.
  final String localAddress;

  /// This connection's local port.
  final int localPort;

  /// This connection's remote address.
  final String remoteAddress;

  /// This connection's remote port.
  final int remotePort;

  final EventSource<Message> _source;
  final Sink<Message> _sink;

  Connection(
    this._source,
    this._sink, {
    @required this.localAddress,
    @required this.localPort,
    @required this.remoteAddress,
    @required this.remotePort,
  }) {
    _source.onEvent(_emit);
  }

  @override
  void add(Message data) {
    _sink.add(data);
  }

  @override
  void close() {
    _sink.close();
  }

  /// Sets [consumer] to be called when this [Connection] receives a message.
  void onMessage(Consumer<Message> consumer) {
    _consumers.add(consumer);
  }

  /// Calls all [_consumers] with [message].
  void _emit(Message message) {
    _consumers.forEach((consume) {
      consume(message);
    });
  }
}
