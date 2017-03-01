/// An object that serializes instances of [T] to and from Strings.
abstract class Serializer<T> {
  /// Converts [object] to an instance of S.
  String serialize(T object);

  /// Converts [object] to an instance of D.
  T deserialize(String object);
}

/// A no-op [Serializer] implementation.
class StringSerializer implements Serializer<String> {
  @override
  String serialize(String object) => object;

  @override
  String deserialize(String object) => object;
}

class IntSerializer implements Serializer<int> {
  const IntSerializer();

  @override
  String serialize(int number) => number.toString();

  @override
  int deserialize(String number) => int.parse(number);
}
