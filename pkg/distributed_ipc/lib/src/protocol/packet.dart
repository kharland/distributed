import 'package:collection/collection.dart';
import 'package:distributed.ipc/src/enum.dart';
import 'package:meta/meta.dart';

@immutable
class PacketType extends Enum {
  static const ACK = const PacketType._(0x1, 'Acknowledgement');
  static const RES = const PacketType._(0x2, 'Resend last message');
  static const DATA = const PacketType._(0x3, 'Data part');
  static const END = const PacketType._(0x4, 'End of message parts');
  static const GREET = const PacketType._(0x5, 'Connection request');
  static const ERROR = const PacketType._(100, 'Error');

  static final _valueToType = <int, PacketType>{
    ACK.value: ACK,
    RES.value: RES,
    DATA.value: DATA,
    END.value: END,
    ERROR.value: ERROR,
  };

  /// Returns a [Packet] whose value is [value].
  static PacketType fromValue(int value) {
    if (!_valueToType.containsKey(value)) {
      throw new ArgumentError('Invalid packet value $value');
    }
    return _valueToType[value];
  }

  @literal
  const PacketType._(int value, String description) : super(description, value);
}

class Packet {
  static const _equality = const PacketEquality();

  static Packet ack(String address, int port) =>
      new Packet(PacketType.ACK, address, port);

  static Packet res(String address, int port) =>
      new Packet(PacketType.RES, address, port);

  static Packet end(String address, int port) =>
      new Packet(PacketType.END, address, port);

  final PacketType type;
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
@literal
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

  @literal
  const DataPacket(String address, int port, this.payload, this.position)
      : super(PacketType.DATA, address, port);
}

/// A [Packet] used to initiate communication between two nodes.
@immutable
class GreetPacket extends Packet {
  /// This packet's encoding type.
  final int encodingType;

  /// A value describing the transfer algorithm to use.
  final int transferType;

  @literal
  GreetPacket(
    String address,
    int port, {
    @required this.encodingType,
    @required this.transferType,
  })
      : super(PacketType.GREET, address, port);
}

/// A [Packet] used to initiate communication between two nodes.
@immutable
class ErrorPacket extends Packet {
  /// This packet's error message.
  final String message;

  @literal
  ErrorPacket(String address, int port, this.message)
      : super(PacketType.ERROR, address, port);
}

/// An equality relation on [Packet] objects.
@immutable
class PacketEquality implements Equality<Packet> {
  static final _listEq = const ListEquality().equals;

  @literal
  const PacketEquality();

  // FIXME: compare GREET packet.
  // FIXME: compare ERROR packet.
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
