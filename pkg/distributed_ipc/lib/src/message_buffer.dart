import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';

class MessageBuffer {
  final _fragments = <int>[];

  void add(MSGPacket packet) {
    _fragments.addAll(packet.message);
  }

  void clear() {
    _fragments.clear();
  }

  @override
  String toString() => utf8Decode(_fragments);
}
