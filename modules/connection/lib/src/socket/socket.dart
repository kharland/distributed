import 'dart:async';

import 'package:distributed.connection/src/socket/seltzer_socket.dart';
import 'package:distributed.net/secret.dart';
import 'package:distributed.net/timeout.dart';

/// A two-way communication channel for sending raw data.
///
/// A socket is the lowest-level medium for communication between two nodes.
class Socket extends StreamView<String> implements StreamSink<String> {
  static const _secretAccepted = 'cookie_acc';
  static const _secretRejected = 'cookie_rej';
  static const _timeoutError = 'Timed out waiting for remote host';

  final StreamSink<String> _sink;

  Socket(this._sink, Stream<String> stream) : super(stream);

  /// Initiates a [Socket] connection over [url].
  static Future<Socket> connectToUrl(String url,
          {Secret secret: Secret.acceptAny}) =>
      connectSeltzerSocket(url, secret: secret);

  /// Initiates a [Socket] connection.
  ///
  /// Returns a future that completes with a [Socket] communicating over [sink]
  /// and [stream] with the remote host.
  ///
  /// [secret] is a key to help the remote host decide whether to accept the
  /// connection.  If secret does not match the remote hosts, the connection is
  /// closed and a [SocketException] is thrown.
  static Future<Socket> connect(
    StreamSink<String> sink,
    Stream<String> stream, {
    Secret secret: Secret.acceptAny,
  }) async {
    sink.add(secret.toString());
    var timeout = new Timeout(() {
      throw new SocketException(_timeoutError);
    });
    var response = await stream.take(1).first;
    timeout.cancel();
    if (response == _secretRejected) {
      throw new SocketException('Remote host rejected secret $secret');
    }
    return new Socket(sink, stream);
  }

  /// Receives a [Socket] connection.
  ///
  /// Returns a future that completes with a [Socket] communicating over [sink]
  /// and [stream] with the remote host.
  ///
  /// If the remote host supplies a [Secret] that doesn't match [secret], sink
  /// is closed and a [SocketException] is thrown.
  static Future<Socket> receive(
    StreamSink<String> sink,
    Stream<String> stream, {
    Secret secret: Secret.acceptAny,
  }) async {
    var timeout = new Timeout(() {
      throw new SocketException(_timeoutError);
    });
    var message = await stream.take(1).first;
    timeout.cancel();

    var foreignSecret = new Secret.fromString(message);
    if (!foreignSecret.matches(secret)) {
      sink.add(_secretRejected);
      throw new Exception("Rejected bad cookie $foreignSecret != $secret");
    }
    sink.add(_secretAccepted);
    return new Socket(sink, stream);
  }

  /// The host address of this socket
  String get address => throw new UnimplementedError();

  @override
  Future get done => _sink.done;

  @override
  void add(String data) {
    _sink.add(data);
  }

  @override
  void addError(errorEvent, [StackTrace stackTrace]) {
    _sink.addError(errorEvent, stackTrace);
  }

  @override
  Future addStream(Stream<String> stream) => _sink.addStream(stream);

  @override
  Future close() async => _sink.close();
}

class SocketException implements Exception {
  final String message;

  SocketException([this.message = '']);

  @override
  String toString() => '$SocketException: $message';
}
