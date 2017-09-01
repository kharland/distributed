import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

abstract class DatagramType {
  static const GREET = 0x12345678;
  static const DEFAULT = 0x23456781;

  static isValid(int value) {
    return value == GREET || value == DEFAULT;
  }
}

@immutable
class Datagram {
  final List<int> data;
  final int type;
  final String address;
  final int port;

  @literal
  const Datagram(this.data, this.address, this.port,
      [this.type = DatagramType.DEFAULT]);

  @override
  bool operator ==(other) =>
      other is Datagram &&
      type == other.type &&
      address == other.address &&
      port == other.port &&
      const ListEquality().equals(data, other.data);

  @override
  int get hashCode => hash4(type, data, address, port);
}
