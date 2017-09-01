import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/encoding.dart';

/// Creates a [DataPacket] of [data] whose relative position in a sequence of
/// [DataPacket]s is [position].
typedef DataPacketFactory = DataPacket Function(List<int> data, int position);

/// Assembles and disassembles messages so they may be sent over a UDP socket.
abstract class DataBuilder<T> {
  /// Reconstructs a [T] from its complete set of [packets].
  T construct(List<DataPacket> packets);

  /// Splits [data] into [DataPacket]s small enough to send in a datagram.
  List<DataPacket> deconstruct(T data);
}

/// A [DataBuilder] that assembles and disassembles strings.
class StringDataBuilder implements DataBuilder<String> {
  final DataPacketFactory _createDataPacket;

  StringDataBuilder(this._createDataPacket);

  @override
  String construct(List<DataPacket> pieces) {
    assert(pieces.every((p) => p.type == PacketType.DATA));

    pieces.sort((a, b) => a.position.compareTo(b.position));
    return utf8Decode(pieces.map((p) => p.payload).expand((bytes) => bytes));
  }

  @override
  List<DataPacket> deconstruct(String data) {
    final List<int> encoded = utf8Encode(data);
    final packets = <Packet>[];

    for (int i = 0; i < encoded.length; i++) {
      packets.add(_createDataPacket([encoded[i]], i));
    }

    return packets;
  }
}
