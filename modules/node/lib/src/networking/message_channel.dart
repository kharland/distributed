import 'dart:async';
import 'dart:convert';

import 'package:distributed.node/interfaces/message.dart';
import 'package:distributed.node/interfaces/node.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

/// A medium for passing messages between [Node]s.
class MessageChannel {
  final WebSocketChannel _webSocketChannel;
  final StreamController<Message> _onMessage =
      new StreamController<Message>.broadcast();
  final Completer<Null> _onClose = new Completer<Null>();

  bool _isOpen = true;

  MessageChannel.from(this._webSocketChannel) {
    StreamSubscription<Message> subscription;
    subscription = _webSocketChannel
        .cast/*<String>*/()
        .stream
        .map(Message.fromJsonString)
        .listen(_onMessage.add, onDone: () {
      _isOpen = false;
      subscription.cancel();
      _onMessage.close();
      _onClose.complete();
    }, cancelOnError: true);
  }

  Stream<Message> get onMessage => _onMessage.stream;

  Future<Null> get onClose => _onClose.future;

  void close() {
    if (_isOpen) {
      _webSocketChannel.sink.close(status.goingAway);
    }
  }

  void send(Message message) {
    _webSocketChannel.sink.add(JSON.encode(message.toJson()));
  }
}
