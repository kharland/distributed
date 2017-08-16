import 'package:binary/binary.dart';
import 'package:distributed.ipc/src/protocol/packet_types.dart';

// TODO: Use package:intl/intl.dart

abstract class DatagramProtocol {
  /// Decodes [bytes] into a [Packet].
  static Packet decode(List<int> bytes) {
    final type = PacketType.fromValue(bytes.first);

    switch (type) {
      case PacketType.ACK:
        return decodeACK(bytes);
      case PacketType.RES:
        return decodeRES(bytes);
      case PacketType.END:
        return decodeEND(bytes);
      case PacketType.DROP:
        return decodeDROP(bytes);
      case PacketType.MSG:
        return decodeMSG(bytes);
      case PacketType.CONN:
        return decodeCONN(bytes);
      default:
        return const InvalidPacket();
    }
  }

  static Packet decodeACK(List<int> bytes) => const ACKPacket();

  static Packet decodeCONN(List<int> bytes) => const CONNPacket();

  static Packet decodeDROP(List<int> bytes) => const DROPPacket();

  static Packet decodeEND(List<int> bytes) => const ENDPacket();

  static Packet decodeMSG(List<int> bytes) {
    final messageSize = pack(bytes.skip(1).take(2));
    final message = bytes.skip(3).take(messageSize);
    return new MSGPacket(messageSize, message);
  }

  static Packet decodeRES(List<int> bytes) => const InvalidPacket();
}
