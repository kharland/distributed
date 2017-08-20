import 'dart:math';

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';

/// Lazily converts a [String] into a series of [Packet].
///
/// The converter can be advanced using [moveNext].  The next packet can be
/// accessed using [current].
class LazyMessageConverter implements Iterator<Packet> {
  // TODO(kharland): Figure out how to determine this value.
  static const int MAX_PACKET_BYTES = 5000;

  final _ByteChunkIterator _iterator;

  LazyMessageConverter(String message, [int maxPacketBytes = MAX_PACKET_BYTES])
      : _iterator = new _ByteChunkIterator(maxPacketBytes, utf8Encode(message));

  @override
  Packet get current {
    final data = _iterator.current;
    return data == null ? null : new MSGPacket(data);
  }

  @override
  bool moveNext() => _iterator.moveNext();
}

/// Iterates over byte-chunks of a string of some specified size.
class _ByteChunkIterator implements Iterator<List<int>> {
  final List<int> _bytes;
  final int bytesPerChunk;

  List<int> _chunk;
  int _chunkStart = 0;

  _ByteChunkIterator(this.bytesPerChunk, this._bytes);

  @override
  List<int> get current => _chunk;

  @override
  bool moveNext() {
    if (_chunkEnd >= _bytes.length) {
      if (_chunkStart == 0) {
        // Haven't read first chunk yet.
        _chunk = new List.unmodifiable(_bytes);
        _chunkStart = _chunkEnd;
        return true;
      } else {
        // Already finished iterating.
        _chunk = null;
        return false;
      }
    } else if (_chunkStart == 0 && _chunk == null) {
      _chunk = new List.unmodifiable(_bytes.sublist(_chunkStart, _chunkEnd));
      return true;
    } else {
      _chunkStart = _chunkEnd;
      _chunk = new List.unmodifiable(_bytes.sublist(_chunkStart, _chunkEnd));
      return true;
    }
  }

  int get _chunkEnd => min(_chunkStart + bytesPerChunk, _bytes.length);
}
