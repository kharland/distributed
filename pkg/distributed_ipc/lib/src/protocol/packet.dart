class PacketType {
  final int value;
  final String description;

  static const ACK = const PacketType._(0x1, 'Acknowledgement');
  static const RES = const PacketType._(0x2, 'Resend last message');
  static const MSG = const PacketType._(0x3, 'Message part');
  static const END = const PacketType._(0x4, 'End of message parts');
  static const DIS = const PacketType._(0x5, 'Drop connection');
  static const CON = const PacketType._(0x6, 'Open connection');

  static final _valueToType = <int, PacketType>{
    ACK.value: ACK,
    RES.value: RES,
    MSG.value: MSG,
    END.value: END,
    DIS.value: DIS,
    CON.value: CON,
  };

  /// Returns a [Packet] whose value is [value].
  static PacketType fromValue(int value) {
    assert(_valueToType.containsKey(value), 'Invalid value $value');
    return _valueToType[value];
  }

  @override
  String toString() => '$value';

  const PacketType._(this.value, this.description);
}

abstract class Packet {
  final PacketType type;

  /// Decodes a [Packet] from [bytes].
  static Packet decode(List<int> bytes) {
    final type = PacketType.fromValue(bytes.first);

    switch (type) {
      case PacketType.ACK:
        return decodeACK(bytes);
      case PacketType.MSG:
        return decodeMSG(bytes);
      case PacketType.END:
        return decodeEND(bytes);
      case PacketType.RES:
        return decodeRES(bytes);
      case PacketType.CON:
        return decodeCONN(bytes);
      case PacketType.DIS:
        return decodeDROP(bytes);
      default:
        return const InvalidPacket();
    }
  }

  static Packet decodeACK(List<int> _) => const ACKPacket();

  static Packet decodeCONN(List<int> _) => const CONNPacket();

  static Packet decodeDROP(List<int> _) => const DROPPacket();

  static Packet decodeEND(List<int> _) => const ENDPacket();

  static Packet decodeMSG(List<int> bytes) {
    final message = bytes.skip(1).toList();
    return new MSGPacket(message);
  }

  static Packet decodeRES(List<int> bytes) => const RESPacket();

  /// Converts this [Packet] into a list of bytes.
  List<int> toBytes() => new List.unmodifiable([type.value]);

  const Packet._(this.type);
}

class InvalidPacket extends Packet {
  const InvalidPacket() : super._(null);
}

class ACKPacket extends Packet {
  const ACKPacket() : super._(PacketType.ACK);
}

class CONNPacket extends Packet {
  const CONNPacket() : super._(PacketType.CON);
}

class RESPacket extends Packet {
  const RESPacket() : super._(PacketType.RES);
}

class ENDPacket extends Packet {
  const ENDPacket() : super._(PacketType.END);
}

class DROPPacket extends Packet {
  const DROPPacket() : super._(PacketType.DIS);
}

class MSGPacket extends Packet {
  /// The content of this packet.
  ///
  /// For now we only support utf-8 encoding.
  final List<int> message;

  /// The byte-length of [message].
  ///
  /// The value is in the range [0, 32768 (2^15)].
  int get messageSize => message.length;

  @override
  List<int> toBytes() => new List.unmodifiable([type.value]..addAll(message));

  const MSGPacket(this.message) : super._(PacketType.MSG);
}
