import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet_types.dart';

/// Converts strings into a series of byte-encoded [MSGPacket]s.
class MSGPacketEncoder extends Converter<String, List<List<int>>> {
  final int maxBytesPerPacket;

  MSGPacketEncoder(this.maxBytesPerPacket);

  @override
  List<List<int>> convert(String input) {
    final List<int> inputBytes = const Utf8Encoder().convert(input);
    final List<List<int>> packetsBytes = <List<int>>[];

    while (inputBytes.isNotEmpty) {
      final chunk = inputBytes.take(maxBytesPerPacket);
      packetsBytes.add(new MSGPacket(chunk.length, chunk).toBytes());
      inputBytes.removeRange(0, chunk.length - 1);
    }

    return packetsBytes;
  }
}
