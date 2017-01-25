import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:seltzer/seltzer.dart' as seltzer;

export 'package:distributed.node/src/socket/socket.dart';

class SeltzerSocket extends StreamView<String> implements Socket {
  static const _SECRET_ACCEPTED = 'cookie_acc';
  static const _SECRET_REJECTED = 'cookie_rej';

  final _SeltzerSocketSink _sink;

  static Future<Socket> connect(String url, {Secret secret}) async {
    var socket = await seltzer.connect(url);
    var stream = new _SeltzerSocketStream(socket);
    var sink = new _SeltzerSocketSink(socket);

    sink.add(secret.toString());
    var response = await stream.take(1).first;
    if (response == _SECRET_REJECTED) {
      throw new Exception('Secret $secret rejected by $url');
    }
    return new SeltzerSocket._(sink, stream);
  }

  static Future<Socket> receive(
    seltzer.SeltzerWebSocket socket, {
    Secret secret: Secret.acceptAny,
  }) async {
    var stream = new _SeltzerSocketStream(socket);
    var sink = new _SeltzerSocketSink(socket);
    var message = await stream.take(1).first;
    var foreignSecret = new Secret.fromString(message);

    if (!foreignSecret.matches(secret)) {
      socket.sendString(_SECRET_REJECTED);
      throw new Exception("Rejected bad cookie $foreignSecret != $secret");
    }
    socket.sendString(_SECRET_ACCEPTED);
    return new SeltzerSocket._(sink, stream);
  }

  SeltzerSocket._(_SeltzerSocketSink sink, _SeltzerSocketStream stream)
      : _sink = sink,
        super(stream);

  @override
  Future get done => _sink.done;

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  Future close({int code, String reason}) async =>
      _sink.closeAsSocket(code: code, reason: reason);

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  Future addStream(Stream<String> stream) => _sink.addStream(stream);
}

/// A Stream<String> SeltzerWebSocket wrapper that does not buffer messages.
///
/// Seltzer's onMessage stream is not a broadcast stream and all messages are
/// buffered until a listener is attached to the stream.  This makes it
/// impossible to perform a handshake on the stream, because higher-levels of
/// the application will receive these handshake messages even if they subscribe
/// after the handshake has completed.
///
/// Perhaps an implementation detail such as this should be encapsulated within
/// the SeltzerWebSocket implementation. Consider updating that and removing
/// this.
class _SeltzerSocketStream extends StreamView<String> {
  _SeltzerSocketStream(seltzer.SeltzerWebSocket socket)
      : super(socket.onMessage
            .asyncMap((m) => m.readAsString())
            .asBroadcastStream());
}

class _SeltzerSocketSink implements StreamSink<String> {
  final seltzer.SeltzerWebSocket _socket;

  _SeltzerSocketSink(this._socket);

  @override
  void add(String event) {
    _socket.sendString(event);
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    throw new UnimplementedError();
  }

  @override
  Future addStream(Stream<String> stream) => stream.forEach(_socket.sendString);

  @override
  Future close() {
    _socket.close();
    return done;
  }

  Future closeAsSocket({int code, String reason}) {
    _socket.close(code: code, reason: reason);
    return done;
  }

  @override
  Future get done => _socket.onClose.then((_) {});
}
