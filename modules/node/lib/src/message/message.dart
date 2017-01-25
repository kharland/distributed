import 'dart:convert';

import 'package:distributed.node/src/message/message_categories.dart';

class Message {
  final String category;
  final String payload;

  Message(this.category, this.payload);

  Message.id(this.payload) : category = MessageCategories.identify;

  Message.error(this.payload) : category = MessageCategories.error;

  Message.statusOk()
      : category = MessageCategories.statusOk,
        payload = '';

  factory Message.fromJson(Map<String, Object> json) => new Message(
        json['category'],
        json['data'],
      );

  factory Message.fromString(String json) =>
      new Message.fromJson(JSON.decode(json) as Map<String, Object>);

  Map<String, Object> toJson() => {'action': category, 'data': payload};

  @override
  String toString() => JSON.encode(toJson());
}
