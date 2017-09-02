import 'dart:convert';

import 'package:distributed.ipc/src/internal/consumer.dart';
import 'package:distributed.ipc/src/internal/event_source.dart';

/// A bidirectional [EventSource].
abstract class Pipe<T> implements EventSource<T>, Sink<T> {
  /// Creates a [Pipe] of [U] that converts all [T] events using [codec].
  static Pipe<U> transform<T, U>(Pipe<T> pipe, Codec<U, T> codec) {
    return new _EncodedPipe(pipe, codec);
  }
}

/// A [Pipe] that delegates to a [Sink] object.
class SinkPipe<T> extends EventSource<T> implements Pipe<T> {
  final Sink<T> _sink;

  SinkPipe(this._sink);

  @override
  void add(T event) {
    _sink.add(event);
  }

  @override
  void close() {
    _sink.close();
  }
}

class _EncodedPipe<T, U> implements Pipe<U> {
  final Codec<U, T> _codec;
  final Pipe<T> _pipe;

  _EncodedPipe(this._pipe, this._codec);

  @override
  void add(U data) {
    _pipe.add(_codec.encode(data));
  }

  @override
  void close() {
    _pipe.close();
  }

  @override
  void emit(U event) {
    _pipe.emit(_codec.encode(event));
  }

  @override
  void emitAll(Iterable<U> events) {
    _pipe.emitAll(events.map(_codec.encode));
  }

  @override
  void onEvent(Consumer<U> consumer) {
    _pipe.onEvent((T event) {
      consumer(_codec.decode(event));
    });
  }
}
