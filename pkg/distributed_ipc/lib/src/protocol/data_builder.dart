import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';

/// Encapsulates assembling and disassembling messages before
/// sending them through a udp socket.
abstract class DataBuilder<T> {
  /// Splits [data] into a series of [Packet] small enough to send in
  /// a datagram.
  List<DataPacket> deconstruct(T data);

  /// Reconstructs a [T] from a complete set of data [pieces].
  T construct(List<DataPacket> pieces);
}

/// A [DataBuilder] that assembles and disassembles strings.
class StringDataBuilder implements DataBuilder<String> {
  final String address;
  final int port;

  /// The number of data bytes to include in each [packet].
  ///
  /// FIXME: Chunk size is locked at 8.  Make variable.
  final int _chunkByteCount;

  StringDataBuilder(this.address, this.port, [this._chunkByteCount = 8]);

  @override
  String construct(List<DataPacket> pieces) {
    assert(pieces.every((p) => p.type == PacketTypes.DATA));

    pieces.sort((a, b) => a.position.compareTo(b.position));
    return utf8Decode(pieces.map((p) => p.payload).expand((bytes) => bytes));
  }

  @override
  List<DataPacket> deconstruct(String data) {
    final List<int> encoded = utf8Encode(data);
    final packets = <Packet>[];

    for (int i = 0; i < encoded.length; i++) {
      packets.add(new DataPacket(address, port, [encoded[i]], i));
    }

    return packets;
  }
}

//
///// Iterates over byte-chunks of a string of some specified size.
//class _ByteChunkIterator implements Iterator<List<int>> {
//  final List<int> _bytes;
//  final int bytesPerChunk;
//
//  List<int> _chunk;
//  int _chunkStart = 0;
//
//  _ByteChunkIterator(this.bytesPerChunk, this._bytes);
//
//  @override
//  List<int> get current => _chunk;
//
//  @override
//  bool moveNext() {
//    if (_chunkEnd >= _bytes.length) {
//      if (_chunkStart == 0) {
//        // Haven't read first chunk yet.
//        _chunk = new List.unmodifiable(_bytes);
//        _chunkStart = _chunkEnd;
//        return true;
//      } else {
//        // Already finished iterating.
//        _chunk = null;
//        return false;
//      }
//    } else if (_chunkStart == 0 && _chunk == null) {
//      _chunk = new List.unmodifiable(_bytes.sublist(_chunkStart, _chunkEnd));
//      return true;
//    } else {
//      _chunkStart = _chunkEnd;
//      _chunk = new List.unmodifiable(_bytes.sublist(_chunkStart, _chunkEnd));
//      return true;
//    }
//  }
//
//  int get _chunkEnd => min(_chunkStart + bytesPerChunk, _bytes.length);
//}
