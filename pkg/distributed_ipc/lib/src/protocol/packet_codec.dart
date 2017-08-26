import 'dart:convert';

import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:distributed.ipc/src/utf8.dart';
import 'package:meta/meta.dart';

/// A code for encoding and decoding [Packet]s.
@immutable
abstract class PacketCodec extends Codec<Packet, List<int>> {
  @override
  final Converter<List<int>, Packet> decoder;

  @override
  final Converter<Packet, List<int>> encoder;

  @literal
  const PacketCodec(this.encoder, this.decoder);
}

/// A [PacketCode] that uses UTF-8 encoding.
@immutable
class Utf8PacketCodec extends PacketCodec {
  @literal
  const Utf8PacketCodec()
      : super(const Utf8PacketEncoder(), const Utf8PacketDecoder());
}

@immutable
class Utf8PacketEncoder extends Converter<Packet, List<int>> {
  const Utf8PacketEncoder();

  @override
  List<int> convert(Packet packet) {
    final type = packet.type.value.toRadixString(16);
    final addr = packet.address;
    final port = packet.port;

    final tokens = [type, addr, port];
    if (packet is DataPacket) {
      tokens.addAll([packet.position, packet.payload]);
    }

    return utf8Encode(tokens.join(_d) + _d);
  }
}

@immutable
class Utf8PacketDecoder extends Converter<List<int>, Packet> {
  const Utf8PacketDecoder();

  @override
  Packet convert(List<int> bytes) {
    int tokenStart = 0;
    final string = utf8Decode(bytes);

    String nextToken() {
      final tokenEnd = string.indexOf(_d, tokenStart);
      final token = string.substring(tokenStart, tokenEnd);
      tokenStart = tokenEnd + 1;
      return token;
    }

    final type = PacketTypes.fromValue(int.parse(nextToken(), radix: 16));
    final address = nextToken();
    final port = int.parse(nextToken());

    if (type == PacketTypes.DATA) {
      final position = int.parse(nextToken());
      final payloadByteString = nextToken();
      final payload = payloadByteString
          .substring(1, payloadByteString.length - 1)
          .split(',')
          .map(int.parse)
          .toList();

      return new DataPacket(address, port, payload, position);
    } else {
      return new Packet(type, address, port);
    }
  }
}

/// Field delimiter for all converters.
const _d = ':';
