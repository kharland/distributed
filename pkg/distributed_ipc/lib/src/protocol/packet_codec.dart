import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet.dart';

class PacketCodec extends Codec<Packet, List<int>> {
  static const _encoder = const _PacketEncoder();
  static const _decoder = const _PacketDecoder();

  const PacketCodec();

  @override
  Converter<List<int>, Packet> get decoder => _decoder;

  @override
  Converter<Packet, List<int>> get encoder => _encoder;
}

class _PacketEncoder extends Converter<Packet, List<int>> {
  const _PacketEncoder();

  @override
  List<int> convert(Packet packet) => packet.toBytes();
}

class _PacketDecoder extends Converter<List<int>, Packet> {
  const _PacketDecoder();

  @override
  Packet convert(List<int> bytes) => Packet.decode(bytes);
}
