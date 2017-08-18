import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet.dart';

class LazyPacketQueue {
  static const int PACKET_SIZE = 32768;

  final _StringChunkIterator _iterator;

  LazyPacketQueue(String message, [int packetByteSize = PACKET_SIZE])
      : _iterator = new _StringChunkIterator(packetByteSize, message);

  Packet peek() {
    final packet = next();
    _iterator.movePrev();
    return packet;
  }

  Packet next() {
    if (_iterator.moveNext()) {
      final data = _iterator.current;
      return new MSGPacket(data.length, data);
    } else {
      return null;
    }
  }
}

/// Iterates over byte-chunks of a string of some specified size.
class _StringChunkIterator implements Iterator<List<int>> {
  static final _encode = const Utf8Encoder().convert;
  static const _SHIFT_NEXT = 1;
  static const _SHIFT_PREV = -1;

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
      _shiftChunk(_SHIFT_NEXT);
      return true;
    }
  }

  void movePrev() {
    assert(_start > 0);
    _shiftChunk(_SHIFT_PREV);
  }

  void _shiftChunk(int direction) {
    _start += direction * bytesPerChunk;
    _chunk = _bytes.sublist(_start, _start + bytesPerChunk);
  }
}
