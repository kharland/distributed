import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class PacketTypes {
  final int value;
  final String description;

  static const ACK = const PacketTypes._(0x1, 'Acknowledgement');
  static const RES = const PacketTypes._(0x2, 'Resend last message');
  static const DATA = const PacketTypes._(0x3, 'Data part');
  static const END = const PacketTypes._(0x4, 'End of message parts');

  static final _valueToType = <int, PacketTypes>{
    ACK.value: ACK,
    RES.value: RES,
    DATA.value: DATA,
    END.value: END,
  };

  /// Returns a [Packet] whose value is [value].
  static PacketTypes fromValue(int value) {
    assert(_valueToType.containsKey(value), 'Invalid value $value');
    return _valueToType[value];
  }

  @override
  String toString() => '$value';

  @literal
  const PacketTypes._(this.value, this.description);
}

class Packet {
  static const _equality = const PacketEquality();

  static Packet ack(String address, int port) =>
      new Packet(PacketTypes.ACK, address, port);

  static Packet res(String address, int port) =>
      new Packet(PacketTypes.RES, address, port);

  static Packet end(String address, int port) =>
      new Packet(PacketTypes.END, address, port);

  final PacketTypes type;
  final String address;
  final int port;

  @override
  int get hashCode => _equality.hash(this);

  @override
  String toString() => '$runtimeType ${{
        'type': type,
        'address': address,
        'port': port,
      }}';

  @override
  bool operator ==(other) => _equality.equals(this, other);

  const Packet(this.type, this.address, this.port);
}

/// A [Packet] that carries a payload.
class DataPacket extends Packet {
  /// This packet's position within a sequence of packets.
  ///
  /// If this packet is not part of a sequence, this value is always 1.
  final int position;

  /// The contents of this packet.
  ///
  /// For now we only support utf-8 encoding.
  final List<int> payload;

  @override
  String toString() => '$runtimeType ${{
    'type': type,
    'address': address,
    'port': port,
    'position': position,
    'payload': payload,
  }}';

  const DataPacket(String address, int port, this.payload, this.position)
      : super(PacketTypes.DATA, address, port);
}

@immutable
class PacketTypeException implements Exception {
  final int typeByte;

  @literal
  const PacketTypeException(this.typeByte);

  @override
  String toString() => 'Unexpected packet type ${typeByte.toRadixString(16)}';
}

/// An equality relation on [Packet] objects.
@immutable
class PacketEquality implements Equality<Packet> {
  static final _listEq = const ListEquality().equals;

  @literal
  const PacketEquality();

  @override
  bool equals(Packet e1, Packet e2) {
    if (e1 is DataPacket && e2 is! DataPacket ||
        e1 is! DataPacket && e2 is DataPacket) {
      return false;
    } else if (e1 is DataPacket && e2 is DataPacket) {
      return _basePropertiesEqual(e1, e2) &&
          e1.position == e2.position &&
          _listEq(e1.payload, e2.payload);
    } else {
      return _basePropertiesEqual(e1, e2);
    }
  }

  bool _basePropertiesEqual(Packet e1, Packet e2) =>
      e1.type == e2.type && e1.address == e2.address && e1.port == e2.port;

  @override
  int hash(Packet p) => p.toString().hashCode;

  @override
  bool isValidKey(Object o) => o is Packet;
}
