import 'dart:async';
import 'dart:convert';

import 'package:distributed/interfaces/node.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/src/networking/system_payloads.dart';
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
    });
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

class Message {
  final Peer sender;
  final String action;
  final String data;

  Message(this.sender, this.action, this.data);

  factory Message.fromJson(Map<String, Object> json) => new Message(
      new Peer.fromJson(json['sender'] as Map<String, Object>),
      json['action'],
      json['data']);

  static Message fromJsonString(String json) =>
      new Message.fromJson(JSON.decode(json) as Map<String, Object>);

  Map<String, Object> toJson() =>
      {'sender': sender.toJson(), 'action': action, 'data': data};
}
