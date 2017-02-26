import 'dart:async';

import 'package:distributed.connection/socket.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/src/utils.dart';

/// Splits a [Socket] into multiple [StreamChannel] instances.
///
/// Each [StreamChannel] is associated with an id which can be used to send
/// message to another [StreamChannel] with the same id, which was also created
/// by a [SocketSplitter].
///
/// It is not recommended to continue communicating directly over the socket
/// once it has been split, as messages from all channels are sent over the
/// socket with metadata. This metadata is used to determine which channel
/// should receive a message.
class SocketSplitter {
  final Socket _socket;
  final _MessageBroker _broker;

  StreamChannel<String> _primaryChannel;
  int _childId = 0;

  SocketSplitter(this._socket) : _broker = new _IntIdBroker() {
    _primaryChannel = split(0).last;
    _broker.addRecipient(_childId++, _primaryChannel.sink);
    _socket.forEach(_broker.deliver);
  }

  /// The channel created when this splitter was constructed.
  ///
  /// This channel should be used instead of the original socket to send data,
  /// such as a mapping of split [StreamChannel]s and their ids, to the client
  /// at the other end of the socket.
  StreamChannel<String> get primaryChannel => _primaryChannel;

  /// Creates a new [StreamChannel] communicating over the original socket.
  ///
  /// The first element of the returned [Pair] is the channel's id, the second
  /// element is the channel.
  Pair<int, StreamChannel<String>> split([int id]) {
    var controller = new StreamChannelController<String>(sync: true);
    var channelId = id;
    if (channelId == null) {
      channelId = _childId++;
    }

    if (id != null && id >= _childId) {
      _childId = id + 1;
    }

    _broker.addRecipient(channelId, controller.foreign.sink);
    controller.foreign.stream.forEach((String message) {
      _socket.add(_broker.addressMessage(channelId, message));
    });

    return new Pair<int, StreamChannel<String>>(channelId, controller.local);
  }
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
    return '$recipientKey$_delimiter$message';
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
