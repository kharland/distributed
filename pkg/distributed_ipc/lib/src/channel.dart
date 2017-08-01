import 'dart:async';
import 'package:meta/meta.dart';

/// A two-way communication channel.
@immutable
class Channel extends StreamView<String> implements Stream<String> {
  /// An unique identifier for this channel.
  final String id;
  final SendMessage _send;

  Channel(this.id, this._send, Stream<String> stream) : super(stream);

  /// Emits [message] on this [Channel].
  void add(String message) {
    _send(id, message);
  }
}

@visibleForTesting
typedef void SendMessage(String channelId, String message);
