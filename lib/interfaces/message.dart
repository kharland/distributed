import 'package:distributed/interfaces/peer.dart';

class Message {
  final Peer sender;
  final String action;
  final String data;

  Message(this.sender, this.action, this.data);

  factory Message.fromJson(Map<String, Object> json) => new Message(
      new Peer.fromJson(json['sender'] as Map<String, Object>),
      json['action'],
      json['data']);

  Map<String, Object> toJson() =>
      {'sender': sender.toJson(), 'action': action, 'data': data};
}
