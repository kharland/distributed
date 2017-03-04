import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/connection_monitor.dart';
import 'package:distributed.connection/src/data_channels.dart';
import 'package:distributed.connection/src/socket/socket_channels.dart';
import 'package:distributed.objects/objects.dart';
import 'package:stream_channel/stream_channel.dart';

export 'src/connection_guard.dart';

class Connection implements DataChannels<Message> {
  static final _MessageTransformer _transformer = new _MessageTransformer();

  @override
  final StreamChannel<Message> user;
  @override
  final StreamChannel<Message> system;
  @override
  final StreamChannel<Message> error;

  final Future _doneFuture;

  Connection(DataChannels<String> original)
      : user = _transformer.bind(original.user),
        system = _transformer.bind(original.system),
        error = _transformer.bind(original.error),
        _doneFuture = original.done {
    var monitor = new ConnectionMonitor(this);
    monitor.onDead.then((_) {
      close();
      monitor.stop();
    });
  }

  static Future<Connection> open(String url) async {
    var socket = await Socket.connect(url);
    return new Connection(await SocketChannels.outgoing(socket));
  }

  static Future<Connection> receive(Socket socket) async {
    return new Connection(await SocketChannels.incoming(socket));
  }

  @override
  Future get done => _doneFuture;

  @override
  Future close() => Future.wait([
        user.sink.close(),
        system.sink.close(),
        error.sink.close(),
      ]).then((_) {});
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
