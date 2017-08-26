import 'dart:async';
import 'dart:convert';

/// A connection between to processes.
abstract class Socket<T> implements EventSink<T>, Stream<T> {}

/// A [SocketSink] that converts a [T] data to send over a [SocketSink] of [S].
class EncodedSocketSink<S, T> implements EventSink<T> {
  final Converter<T, S> _converter;
  final EventSink<S> _sink;

  EncodedSocketSink(this._sink, this._converter);

  @override
  void add(T event) {
    _sink.add(_converter.convert(event));
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  void close() {
    _sink.close();
  }
}

/// Simulates a [Socket] by wrapping a [Stream] and [Sink].
class PseudoSocket<T> extends StreamView<T> implements Socket<T> {
  final EventSink<T> _sink;

  PseudoSocket(Stream<T> stream, this._sink) : super(stream);

  @override
  void add(T event) {
    _sink.add(event);
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  void close() {
    _sink.close();
  }
}
