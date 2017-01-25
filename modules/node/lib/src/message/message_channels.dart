import 'dart:async';

import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/socket/socket.dart';
import 'package:distributed.node/src/socket/socket_channels.dart';
import 'package:stream_channel/stream_channel.dart';

class _MessageTransformer implements StreamChannelTransformer<Message, String> {
  @override
  StreamChannel<Message> bind(StreamChannel<String> channel) {
    var controller = new StreamController<Message>(sync: true)
      ..stream.map((message) => message.toString()).pipe(channel.sink);

    return new StreamChannel(
      channel.stream.map((s) => new Message.fromString(s)),
      controller,
    );
  }
}

class MessageChannels implements ConnectionChannels<Message> {
  static final _MessageTransformer _transformer = new _MessageTransformer();

  @override
  final StreamChannel<Message> user;
  @override
  final StreamChannel<Message> system;
  @override
  final StreamChannel<Message> error;

  final Future _doneFuture;

  MessageChannels(ConnectionChannels<String> original)
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

class MessageChannelsProvider implements ConnectionChannelsProvider<Message> {
  @override
  Future<ConnectionChannels<Message>> createFromUrl(String url) async =>
      new MessageChannels(
          await SocketChannels.outgoing(await Socket.connect(url)));
}
