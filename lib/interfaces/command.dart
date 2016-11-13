import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/interfaces/serializer.dart';
import 'package:meta/meta.dart';

typedef void CommandHandler(Peer sender, Set<Object> arguments);

class CommandMessage extends Message {
  static final DartCoreSerializer _coreSerializer = new DartCoreSerializer();

  final String formatName;
  final Iterable<Object> arguments;

  @override
  @virtual
  final Peer sender;

  CommandMessage(this.sender, this.formatName, this.arguments);

  factory CommandMessage.fromJson(Map<String, Object> json) {
    var args = json['arguments'] as Iterable<String>;
    return new CommandMessage(
        new Peer.fromJson(json['sender'] as Map<String, Object>),
        json['format'],
        args.map(_coreSerializer.deserialize));
  }

  @override
  Map<String, Object> toJson() => <String, Object>{
        'format': formatName,
        'sender': sender.toJson(),
        'arguments': arguments.map(_coreSerializer.serialize).toList()
      };
}
