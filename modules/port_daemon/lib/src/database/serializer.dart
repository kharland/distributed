import 'package:fixnum/fixnum.dart';

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

class Int64Serializer implements Serializer<Int64> {
  const Int64Serializer();

  @override
  String serialize(Int64 number) => number.toString();

  @override
  Int64 deserialize(String number) => Int64.parseInt(number);
}
