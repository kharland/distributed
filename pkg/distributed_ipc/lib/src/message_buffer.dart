import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';

/// Buffers [DataPacket] to be combined into a single [String] message.
class MessageBuffer {
  final _fragments = <int>[];

  /// Adds [packet] to this buffer.
  void add(DataPacket packet) {
    _fragments.addAll(packet.payload);
  }

  /// Removes all packets from this buffer.
  void clear() {
    _fragments.clear();
  }

  /// Returns the [String] decoded from the packets in this buffer.
  @override
  String toString() => utf8Decode(_fragments);
}
