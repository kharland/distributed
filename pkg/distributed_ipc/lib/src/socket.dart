import 'dart:async';
import 'dart:convert';

/// A persistent network connection.
abstract class Socket<T> implements EventSink<T>, Stream<T> {
  /// Converts [socket] into a [Socket] of [U] using [codec].
  static Socket<U> convert<T, U>(Socket<T> socket, Codec<U, T> codec) {
    final stream = socket.map(codec.decode);
    final sink = new EncodedSocketSink<T, U>(socket, codec.encoder);
    return new GenericSocket<U>(stream, sink);
  }
}

/// A [SocketSink] implementation that wraps another [EventSink].
class DelegatingSocketSink<T> implements EventSink<T> {
  final _closeCompleter = new Completer<Null>();
  final EventSink<T> _sink;

  DelegatingSocketSink(this._sink);

  @override
  void add(T event) {
    _sink.add(event);
  }

  @override
  void addError(Object errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent);
  }

  @override
  void close() {
    _sink.close();
    _closeCompleter.complete();
  }
}

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

/// A generic [Socket] implementation that uses specified data-channels.
class GenericSocket<T> extends StreamView<T> implements Socket<T> {
  final EventSink<T> _sink;

  GenericSocket(Stream<T> stream, this._sink) : super(stream);

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
