import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/peer.dart';
import 'package:distributed/interfaces/serializer.dart';
import 'package:meta/meta.dart';

class CommandFormat {
  final String name;
  final Iterable<Type> parameterTypes;

  CommandFormat(this.name, this.parameterTypes);
}

class CommandMessage extends Message {
  static final DartCoreSerializers _coreSerializers = new DartCoreSerializers();
  final String formatName;
  final Iterable<Object> arguments;

  @override
  @virtual
  final Peer sender;

  CommandMessage(this.sender, this.formatName, this.arguments);

  factory CommandMessage.fromJson(Map<String, Object> json) {
    var args = json['arguments'] as List<Map<String, Object>>;
    return new CommandMessage(
        new Peer.fromJson(json['sender'] as Map<String, Object>),
        json['format'], args.map((Map<String, Object> arg) {
      return _coreSerializers.deserialize(arg['type'], arg['value']);
    }));
  }

  @override
  Map<String, Object> toJson() => <String, Object>{
        'format': formatName,
        'sender': sender.toJson(),
        'arguments': arguments
            .map((arg) => {
                  'type': arg.runtimeType.toString(),
                  'value': _serializeArg(arg)
                })
            .toList()
      };

  String _serializeArg(Object arg) {
    return _coreSerializers.serialize(arg);
  }
}
