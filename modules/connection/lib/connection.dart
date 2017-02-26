import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:distributed.connection/src/data_channels.dart';
import 'package:distributed.connection/src/message/message.dart';
import 'package:distributed.connection/src/socket/socket_channels.dart';
import 'package:stream_channel/stream_channel.dart';

export 'src/connection_strategy.dart';
export 'src/message/message.dart';
export 'src/message/message_categories.dart';

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
        _doneFuture = original.done;

  @override
  Future get done => _doneFuture;

  @override
  Future close() => Future.wait([
        user.sink.close(),
        system.sink.close(),
        error.sink.close(),
      ]).then((_) {});
}

class ConnectionProvider implements DataChannelsProvider<Message> {
  @override
  Future<Connection> createFromUrl(String url) async =>
      createFromSocket(await Socket.connect(url));

  @override
  Future<Connection> createFromSocket(socket) async =>
      new Connection(await SocketChannels.outgoing(socket));
}

class _MessageTransformer implements StreamChannelTransformer<Message, String> {
  @override
  StreamChannel<Message> bind(StreamChannel<String> channel) {
    var controller = new StreamController<Message>(sync: true)
      ..stream.map((message) => message.toString()).pipe(channel.sink);

    return new StreamChannel(
      channel.stream.map((s) => new Message.fromString(s)).asBroadcastStream(),
      controller,
    );
  }
}
