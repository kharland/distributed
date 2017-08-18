import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet.dart';

/// Assembles a message from a series of [Packet
abstract class MessageReceiver {
  static final _decode = const Utf8Decoder().convert;

  /// Whether this receiver has a complete message.
  bool get isDone;

  /// Consumes a fragment of this buffer's message from [packet].
  Packet receive(Packet packet);

  /// Compiles and returns the message in this buffer as a string.
  ///
  /// The buffer is emptied as a result of this call and can begin recieving
  /// a new message.
  String emit();
}

/// A [MessageReceiver] that uses the lockstep transfer algorithm.
class LockStepReceiver implements MessageReceiver {
  final _fragments = <int>[];
  bool _isDone = false;

  @override
  bool get isDone => _isDone;

  @override
  Packet receive(Packet packet) {
    if (packet.type == PacketType.MSG) {
      assert(!_isDone);
      _fragments.addAll(packet.toBytes());
      return const ACKPacket();
    } else {
      assert(packet.type == PacketType.END);
      _isDone = true;
      return null;
    }
  }

  @override
  String emit() {
    final message = MessageReceiver._decode(_fragments);
    _fragments.clear();
    _isDone = false;
    return message;
  }
}

/// A [MessageReceiver] that uses the fast transfer algorithm.
class FastReceiver implements MessageReceiver {
  bool _isDone = false;
  List<int> _fragment;

  @override
  bool get isDone => _isDone;

  @override
  Packet receive(Packet packet) {
    _isDone = true;
    _fragment = packet.toBytes();
    return null;
  }

  @override
  String emit() {
    final message = MessageReceiver._decode(_fragment);
    _fragment = null;
    _isDone = false;
    return message;
  }
}
