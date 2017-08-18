import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet.dart';

/// Lazily converts a [String] into a series of [Packet].
///
/// The converter can be advanced using [moveNext].  The next packet can be
/// accessed using [current].
class LazyMessageConverter implements Iterator<Packet> {
  static const int PACKET_SIZE = 32768;

  final _StringChunkIterator _iterator;

  LazyMessageConverter(String message, [int packetByteSize = PACKET_SIZE])
      : _iterator = new _StringChunkIterator(packetByteSize, message);

  @override
  Packet get current {
    final data = _iterator.current;
    if (data != null) {
      return new MSGPacket(data.length, data);
    } else {
      return null;
    }
  }

  @override
  bool moveNext() => _iterator.moveNext();
}

/// Iterates over byte-chunks of a string of some specified size.
class _StringChunkIterator implements Iterator<List<int>> {
  static final _encode = const Utf8Encoder().convert;

  final List<int> _bytes;
  final int bytesPerChunk;

  List<int> _chunk;
  int _start = 0;

  _StringChunkIterator(this.bytesPerChunk, String string)
      : _bytes = _encode(string);

  @override
  List<int> get current => _chunk;

  @override
  bool moveNext() {
    if (_start + bytesPerChunk >= _bytes.length) {
      _chunk = null;
      return false;
    } else {
      _start += bytesPerChunk;
      _chunk = _bytes.sublist(_start, _start + bytesPerChunk);
      return true;
    }
  }
}
