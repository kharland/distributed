import 'dart:async';
import 'dart:convert';

import 'package:stream_channel/stream_channel.dart';

/// A persistent network connection.
abstract class Socket<T> implements EventSink<T>, Stream<T> {}

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

/// A connected [Socket] pair.
class ConnectedSockets<T> {
  /// The local socket in this connection.
  ///
  /// The creator of these [ConnectedSockets] should use this [Socket].
  final Socket<T> local;

  /// The remote socket in this connection.
  ///
  /// The creator of these [ConnectedSockets] should use [local] to communicate
  /// with this [Socket].
  final Socket<T> foreign;

  ConnectedSockets._(this.local, this.foreign);

  factory ConnectedSockets() {
    final endpoints = new StreamChannelController<T>();

    final localSocket = new GenericSocket<T>(
      endpoints.local.stream.asBroadcastStream(),
      new DelegatingSocketSink<T>(endpoints.local.sink),
    );

    final foreignSocket = new GenericSocket<T>(
      endpoints.foreign.stream.asBroadcastStream(),
      new DelegatingSocketSink<T>(endpoints.foreign.sink),
    );

    return new ConnectedSockets._(localSocket, foreignSocket);
  }
}
