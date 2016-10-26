/// A class that can serialize and deserialize T instances.

import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/networking/json.dart';

abstract class Serializer<T> {
  String serialize(T value);

  T deserialize(String value);
}

class _IntSerializer implements Serializer<int> {
  @override
  int deserialize(String value) => int.parse(value);

  @override
  String serialize(int value) => value.toString();
}

class _DoubleSerializer implements Serializer<double> {
  @override
  double deserialize(String value) => double.parse(value);

  @override
  String serialize(double value) => value.toString();
}

class _StringSerializer implements Serializer<String> {
  @override
  String deserialize(String value) => value;

  @override
  String serialize(String value) => value;
}

class DartCoreSerializers {
  Map<String, Serializer> _serializers = <String, Serializer>{
    '$int': new _IntSerializer(),
    '$double': new _DoubleSerializer(),
    '$String': new _StringSerializer(),
  };

  Object deserialize(String type, String value) {
    if (!_serializers.containsKey(type)) {
      throw new ArgumentError('Unable to deserialize value: $value');
    }
    return _serializers[type].deserialize(value);
  }

  String serialize(Object value) {
    if (!_serializers.containsKey(value.runtimeType.toString())) {
      throw new ArgumentError(
          'Unable to serialize value of type: ${value.runtimeType}');
    }
    return _serializers[value.runtimeType.toString()].serialize(value);
  }
}

//class CommandSerializer extends Serializer<CommandMessage> {
//  static final DartCoreSerializers _coreSerializers = new DartCoreSerializers();
//
//
//

//}
