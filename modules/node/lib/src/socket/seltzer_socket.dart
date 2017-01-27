import 'dart:async';

import 'package:distributed.net/secret.dart';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:seltzer/platform/vm.dart';
import 'package:seltzer/seltzer.dart';

export 'package:distributed.node/src/socket/socket.dart';

bool _isSeltzerInitialized = false;

void _initSeltzer() {
  if (!_isSeltzerInitialized) {
    useSeltzerInVm();
    _isSeltzerInitialized = true;
  }
}

Future<Socket> connectSeltzerSocket(String url, {Secret secret}) async {
  _initSeltzer();
  var socket = connect(url);
  var stream = new _SeltzerSocketStream(socket);
  var sink = new _SeltzerSocketSink(socket);
  return Socket.connect(sink, stream);
}

Future<Socket> receiveSeltzerSocket(
  SeltzerWebSocket socket, {
  Secret secret: Secret.acceptAny,
}) {
  _initSeltzer();
  var stream = new _SeltzerSocketStream(socket);
  var sink = new _SeltzerSocketSink(socket);
  return Socket.receive(sink, stream);
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
  _SeltzerSocketStream(SeltzerWebSocket socket)
      : super(socket.onMessage.asyncMap(_decodeMessage).asBroadcastStream());

  static String _decodeMessage(message) => message.readAsString();
}

class _SeltzerSocketSink implements StreamSink<String> {
  final SeltzerWebSocket _socket;

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

  @override
  Future get done => _socket.onClose.then((_) {});
}
