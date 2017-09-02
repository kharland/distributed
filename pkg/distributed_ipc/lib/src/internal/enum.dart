import 'package:meta/meta.dart';

@immutable
class Enum {
  final String name;
  final int value;

  @literal
  const Enum(this.name, this.value);

  @override
  String toString() => '$runtimeType($value, $value)';
}
