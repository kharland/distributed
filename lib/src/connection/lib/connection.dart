import 'dart:async';

import 'package:async/async.dart';
import 'socket.dart';
import 'package:distributed.connection/src/socket_channels.dart';
import 'package:distributed.monitoring/periodic_function.dart';
import 'package:distributed.monitoring/resource.dart';
import 'package:distributed.objects/objects.dart';

/// A channel for passing [BuiltMessage]s.
///
/// A outgoing connection can be established using [Connection.open], or an
/// incoming connection can be established over a socket using
/// [Connection.receive].
///
/// Unlike most dart sinks, if the remote end of the connection is closed, this
/// connection will also close, regardless of whether any data has been sent or
/// received.
class Connection implements Sink<BuiltMessage> {
  final SocketChannels _socketChannels;
  final _closeMemo = new AsyncMemoizer();
  final _doneCompleter = new Completer();

  StreamSplitter<String> _userStreamSplitter;
  PeriodicFunction _keepAliveSignal;
  ResourceMonitor<String> _connectionMonitor;

  /// Opens a new [Connection] to url.
  ///
  /// It is expected that the remote end of the connection will be created via
  /// [Connection.receive].
  static Future<Connection> open(String url) async {
    return new Connection(await SocketChannels.outgoing(Socket.connect(url)));
  }

  /// Receives a new [Connection] over [socket].
  ///
  /// It is expected that the remote end of the connection was created via
  /// [Connection.open].
  static Future<Connection> receive(Socket socket) async =>
      new Connection(await SocketChannels.incoming(socket));

  Connection(this._socketChannels) {
    _userStreamSplitter =
        new StreamSplitter<String>(_socketChannels.userStream);
    _keepAliveSignal = new PeriodicFunction(_pingRemote);
    _connectionMonitor = new ResourceMonitor('', _socketChannels.systemStream);
    _connectionMonitor.onGone.then((_) {
      close();
    });
  }

  /// Sends [message] over this connection.
  @override
  void add(BuiltMessage message) {
    _socketChannels.sendToUser(serialize(message));
  }

  /// The [Stream] of messages sent to this connection.
  Stream<BuiltMessage> get messages => _userStreamSplitter
      .split()
      .map((String m) => deserialize(m, BuiltMessage) as BuiltMessage)
      .asBroadcastStream();

  /// A future that completes when this connection is closed.
  ///
  /// If the remote closes the connection, this is guaranteed to complete.
  Future get done => _doneCompleter.future;

  @override
  void close() {
    _closeMemo.runOnce(() {
      _userStreamSplitter.close();
      _keepAliveSignal.stop();
      _connectionMonitor.stop();
      _socketChannels.close();
      _doneCompleter.complete();
    });
  }

  void _pingRemote() {
    _socketChannels.sendToSystem('');
  }
}
