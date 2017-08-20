import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';

/// Buffers [MSGPacket] to be combined into a single [String] message.
class MessageBuffer {
  final _fragments = <int>[];

  void add(MSGPacket packet) {
    _fragments.addAll(packet.message);
  }

  void clear() {
    _fragments.clear();
  }

  /// Returns the [String] decoded from the packets in this buffer.
  @override
  String toString() => utf8Decode(_fragments);
}
