import 'dart:convert';

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/datagram.dart';
import 'package:distributed.ipc/src/protocol/packet.dart';
import 'package:meta/meta.dart';

/// A [Codec] for converting between [Packet] and byte-data.
@immutable
abstract class PacketCodec extends Codec<Packet, List<int>> {
  factory PacketCodec.fromEncoding(EncodingType encodingType) {
    switch (encodingType) {
      case EncodingType.UTF8:
        return const Utf8PacketCodec();
      default:
        throw new UnimplementedError();
    }
  }

  @override
  final Converter<List<int>, Packet> decoder;

  @override
  final Converter<Packet, List<int>> encoder;

  @literal
  const PacketCodec(this.encoder, this.decoder);
}

@immutable
class PacketDatagramCodec extends Codec<Packet, Datagram> {
  @override
  Converter<Datagram, Packet> get decoder => const _DatagramToPacketConverter();

  @override
  Converter<Packet, Datagram> get encoder => const _PacketToDatagramEncoder();
}

@immutable
class _PacketToDatagramEncoder extends Converter<Packet, Datagram> {
  final PacketCodec _codec;

  @literal
  const _PacketToDatagramEncoder([this._codec = const Utf8PacketCodec()]);

  @override
  Datagram convert(Packet packet) {
    final dgType = packet.type == PacketType.GREET
        ? DatagramType.GREET
        : DatagramType.DATA;

    return new Datagram(
      _codec.encode(packet),
      packet.address,
      packet.port,
      dgType,
    );
  }
}

@immutable
class _DatagramToPacketConverter extends Converter<Datagram, Packet> {
  final PacketCodec _codec;

  @literal
  const _DatagramToPacketConverter([this._codec = const Utf8PacketCodec()]);

  @override
  Packet convert(Datagram datagram) => _codec.decode(datagram.data);
}

/// A [PacketCode] that uses UTF-8 encoding.
@immutable
class Utf8PacketCodec extends PacketCodec {
  @literal
  const Utf8PacketCodec()
      : super(
          const Utf8PacketEncoder(),
          const Utf8PacketDecoder(),
        );
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
      if (tokenEnd < 0) {
        throw new InvalidPacketDataException(string);
      }
      final token = string.substring(tokenStart, tokenEnd);
      tokenStart = tokenEnd + 1;
      return token;
    }

    final type = PacketType.fromValue(int.parse(nextToken(), radix: 16));
    final address = nextToken();
    final port = int.parse(nextToken());

    if (type == PacketType.DATA) {
      final position = int.parse(nextToken());
      final payloadBytesList = nextToken();
      final payload = payloadBytesList
          // drop L and R square brackets of list
          .substring(1, payloadBytesList.length - 1)
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

@immutable
class PacketCodeException implements Exception {
  final String _message;

  @literal
  const PacketCodeException(this._message);

  @override
  String toString() => '$runtimeType: $_message';
}

class InvalidPacketDataException extends PacketCodeException {
  @literal
  const InvalidPacketDataException(String encodedPacket) : super(encodedPacket);
}
