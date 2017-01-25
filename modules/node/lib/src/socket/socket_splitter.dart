import 'dart:async';

import 'package:distributed.node/src/socket/socket.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/src/utils.dart';

abstract class SocketSplitter {
  factory SocketSplitter(Socket socket) =>
      new _SocketSplitter(socket, new _IntIdBroker());

  StreamChannel<String> get primaryChannel;

  Pair<int, StreamChannel<String>> split([int id]);
}

abstract class _MessageBroker<T> {
  void addRecipient(T key, StreamSink<String> recipient);

  void deliver(String message);

  String addressMessage(T recipientKey, String message);
}

class _IntIdBroker implements _MessageBroker<int> {
  static const _delimiter = ':';

  final Map<int, StreamSink<String>> _recipients = <int, StreamSink<String>>{};

  @override
  void addRecipient(int key, StreamSink<String> recipient) {
    _recipients[key] = recipient;
  }

  @override
  String addressMessage(int recipientKey, String message) {
    assert(_recipients.containsKey(recipientKey));
    return '${recipientKey}$_delimiter$message';
  }

  @override
  void deliver(String message) {
    // use indexOf instead split to avoid splitting on a user-added character
    // which matches our delimiter.
    int delimiterPosition = message.indexOf(_delimiter);
    var parts = [
      message.substring(0, delimiterPosition),
      message.substring(delimiterPosition + 1),
    ];
    var recipientId = int.parse(parts.first);
    message = parts.last;
    assert(_recipients.containsKey(recipientId));
    _recipients[recipientId].add(message);
  }
}

class _SocketSplitter implements SocketSplitter {
  final Socket _socket;
  final _MessageBroker _broker;
  StreamChannel<String> _primaryChannel;

  int childId = 0;

  _SocketSplitter(this._socket, this._broker) {
    _primaryChannel = split(0).last;
    _broker.addRecipient(childId++, _primaryChannel.sink);
    _socket.forEach(_broker.deliver);
  }

  @override
  StreamChannel<String> get primaryChannel => _primaryChannel;

  @override
  Pair<int, StreamChannel<String>> split([int id]) {
    var controller = new StreamChannelController(sync: true);
    var channelId = id;
    if (channelId == null) {
      channelId = childId++;
    }

    if (id != null && id >= childId) {
      childId = id + 1;
    }

    _broker.addRecipient(channelId, controller.foreign.sink);
    controller.foreign.stream.forEach((String message) {
      _socket.add(_broker.addressMessage(channelId, message));
    });

    return new Pair<int, StreamChannel<String>>(channelId, controller.local);
  }
}
