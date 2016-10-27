/// A class that can serialize and deserialize T instances.
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

class _IterableSerializer implements Serializer<Iterable> {
  final _PrimitiveSerializers _primitiveSerializer =
      new _PrimitiveSerializers();

  bool canDeserialize(String string) {
    var parts = string.split(r'~');
    return parts.length > 1 && parts.first.startsWith('Iterable');
  }

  @override
  Iterable deserialize(String string) {
    String iterable = string.split(r'~').last;
    iterable = iterable.substring(1, iterable.length - 1);
    Iterable<String> values = iterable.split(',').map((v) => v.trim());
    return values.map(_primitiveSerializer.deserialize);
  }

  @override
  String serialize(Iterable<Object> iterable) {
    return 'Iterable~${iterable.map(_primitiveSerializer.serialize).toList()}';
  }
}

class _PrimitiveSerializers {
  Map<String, Serializer> _serializers = <String, Serializer>{
    '$int': new _IntSerializer(),
    '$double': new _DoubleSerializer(),
    '$String': new _StringSerializer(),
  };

  bool canDeserialize(String string) {
    var parts = string.split(r'^');
    return parts.length > 1 && _serializers.containsKey(parts.first);
  }

  Object deserialize(String string) {
    var parts = string.split(r'^');
    String type = parts.first;
    String value = parts.last;
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
    String result = _serializers[value.runtimeType.toString()].serialize(value);
    return '${value.runtimeType}^$result';
  }
}

class DartCoreSerializer implements Serializer<Object> {
  _PrimitiveSerializers _primitiveSerializers = new _PrimitiveSerializers();
  _IterableSerializer _iterableSerializer = new _IterableSerializer();

  @override
  Object deserialize(String value) {
    if (_primitiveSerializers.canDeserialize(value)) {
      return _primitiveSerializers.deserialize(value);
    } else if (_iterableSerializer.canDeserialize(value)) {
      return _iterableSerializer.deserialize(value);
    } else {
      throw new ArgumentError('Unable to serialize value: $value');
    }
  }

  @override
  String serialize(Object value) {
    if (value is Iterable) {
      return _iterableSerializer.serialize(value);
    } else {
      return _primitiveSerializers.serialize(value);
    }
  }
}
