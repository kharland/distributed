import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/socket/socket_channels.dart';
import 'package:distributed.monitoring/resource.dart';
import 'package:distributed.objects/objects.dart';
import 'package:stream_channel/stream_channel.dart';

/// A channel for passing [Message]s.
///
/// A outgoing connection can be established using [Connection.open], or an
/// incoming connection can be established over a socket using
/// [Connection.receive].
///
/// Unlike most dart sinks, if the remote end of the connection is closed, this
/// connection will also close, regardless of whether any data has been sent or
/// received.
class Connection {
  static final _MessageTransformer _transformer = new _MessageTransformer();
  final StreamChannel<Message> _userChannel;
  final StreamChannel<String> _rawChannel;
  final Future _doneFuture;
  PeriodicFunction _keepAliveSignal;
  ResourceMonitor<String> _connectionMonitor;

  /// Opens a new [Connection] to url.
  ///
  /// It is expected that the remote end of the connection will be created via
  /// [Connection.receive].
  static Future<Connection> open(String url) async {
    var socket = await Socket.connect(url);
    return new Connection(await SocketChannels.outgoing(socket));
  }

  /// Receives a new [Connection] over [socket].
  ///
  /// It is expected that the remote end of the connection was created via
  /// [Connection.open].
  static Future<Connection> receive(Socket socket) async =>
      new Connection(await SocketChannels.incoming(socket));

  Connection(SocketChannels socketChannels)
      : _userChannel = _transformer.bind(socketChannels.user),
        _rawChannel = socketChannels.system,
        _doneFuture = socketChannels.done {
    _keepAliveSignal = new PeriodicFunction('conn', () {
      _rawChannel.sink.add(null);
    });
    _connectionMonitor = new ResourceMonitor('conn', _rawChannel.stream);
    _connectionMonitor.onGone.then((_) {
      close();
    });
  }

  /// Sends [message] over this connection.
  void sendMessage(Message message) {
    _userChannel.sink.add(message);
  }

  /// The [Stream] of messages sent to this connection.
  Stream<Message> get messages => _userChannel.stream;

  /// A future that completes when this connection is closed.
  ///
  /// If the remote closes the connection, this is guaranteed to complete.
  Future get done => _doneFuture;

  Future<Null> close() => Future.wait([
        _userChannel.sink.close(),
        _rawChannel.sink.close(),
      ]).then((_) {
        _keepAliveSignal.stop();
        _connectionMonitor.stop();
      });
}

class _MessageTransformer implements StreamChannelTransformer<Message, String> {
  @override
  StreamChannel<Message> bind(StreamChannel<String> channel) {
    var controller = new StreamController<Message>(sync: true)
      ..stream.map((message) => serialize(message, Message)).pipe(channel.sink);

    return new StreamChannel<Message>(
      channel.stream
          .map((message) => deserialize(message, Message))
          .asBroadcastStream(),
      controller,
    );
  }
}
