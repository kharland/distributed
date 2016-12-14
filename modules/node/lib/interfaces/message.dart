import 'dart:convert';
import 'package:distributed.node/interfaces/peer.dart';

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

  String toJsonString() => JSON.encode(toJson());
}
