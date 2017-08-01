import 'dart:async';

import 'package:distributed.ipc/ipc.dart';
import 'package:distributed.ipc/src/channel_provider.dart';
import 'package:distributed.ipc/src/channel.dart';
import 'package:distributed.ipc/src/socket.dart';
import 'package:distributed.objects/objects.dart';

typedef String EncodeMessage(ChannelMessage message);

typedef ChannelMessage DecodeMessage(String message);

/// A [ChannelProvider] implementation that reads and writes to a [Socket].
class SocketChannelProvider implements ChannelProvider {
  final EncodeMessage _encode;
  final DecodeMessage _decode;
  final Socket _socket;
  final _channelToController = <String, StreamController<String>>{};
  final _closeCompleter = new Completer<Null>();

  SocketChannelProvider(this._socket, this._encode, this._decode) {
    _socket.map(_decode).forEach(_receive);
  }

  @override
  Future get onClose => _closeCompleter.future;

  @override
  Channel channel(String name) {
    final channel = new Channel(name, _send, _socket as Stream<String>);
    _channelToController[channel.id] = new StreamController<String>();
    return channel;
  }

  /// Closes this [SocketChannelProvider].
  ///
  /// The underlying socket is not closed.
  @override
  Future close() {
    _channelToController.values.forEach((c) => c.close());
    _closeCompleter.complete();
    return _closeCompleter.future;
  }

  void _send(String queue, String message) {
    _socket.add(_encode(new ChannelMessage((b) => b
      ..contents = message
      ..queue = queue)));
  }

  void _receive(ChannelMessage message) {
    _channelToController[message.queue].add(message.contents);
  }
}
