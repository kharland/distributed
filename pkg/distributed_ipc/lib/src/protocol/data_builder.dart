import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/encoding.dart';

typedef DataPacketFactory = DataPacket Function(List<int>, int);

/// Assembles and disassembles messages so they may be sent over a UDP socket.
abstract class DataBuilder<T> {
  /// Splits [data] into [DataPacket]s small enough to send in a datagram.
  List<DataPacket> deconstruct(T data);

  /// Reconstructs a [T] from its complete set of [packets].
  T construct(List<DataPacket> packets);
}

/// A [DataBuilder] that assembles and disassembles strings.
/// FIXME: Chunk size is locked at 8.  Make variable.
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
