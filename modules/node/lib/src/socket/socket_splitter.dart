import 'dart:async';
import 'dart:math';

import 'package:distributed.node/src/socket/socket.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/src/utils.dart';

abstract class SocketSplitter {
  factory SocketSplitter(Socket socket) =>
      new _SocketSplitter(socket, new _IntBasedBroker());

  StreamChannel<String> get primaryChannel;

  Pair<int, StreamChannel<String>> split([int id]);
}

abstract class _SocketBroker {
  void addRecipient(int id, StreamSink<String> recipient);

  void deliver(String message);

  String addressMessage(int recipientId, String message);
}

class _IntBasedBroker implements _SocketBroker {
  static const _delimiter = ':';

  final Map<int, StreamSink<String>> _recipients = <int, StreamSink<String>>{};

  @override
  void addRecipient(int id, StreamSink<String> recipient) {
    _recipients[id] = recipient;
  }

  @override
  String addressMessage(int recipientId, String message) {
    assert(_recipients.containsKey(recipientId));
    return '${recipientId}$_delimiter$message';
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
  final _SocketBroker _broker;
  StreamChannel<String> _primaryChannel;

  int highestId = 0;
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
    int channelId = id == null ? childId++ : id;

    var newBaseline = max(childId, id ?? childId - 1);
    highestId = max(highestId, newBaseline);
    childId = highestId + 1;

    var controller = new StreamChannelController(sync: true);
    _broker.addRecipient(channelId, controller.foreign.sink);
    controller.foreign.stream.forEach((String message) {
      _socket.add(_broker.addressMessage(channelId, message));
    });
    return new Pair<int, StreamChannel<String>>(channelId, controller.local);
  }
}
