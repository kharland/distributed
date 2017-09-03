import 'dart:convert';

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/udp/datagram.dart';
import 'package:meta/meta.dart';

/// A [Codec] for converting between [Datagram] and byte-data.
@immutable
abstract class DatagramCodec extends Codec<Datagram, List<int>> {
  factory DatagramCodec.fromEncoding(EncodingType encodingType) {
    switch (encodingType) {
      case EncodingType.UTF8:
        return const Utf8DatagramCodec();
      default:
        throw new UnimplementedError();
    }
  }

  @override
  final Converter<List<int>, Datagram> decoder;

  @override
  final Converter<Datagram, List<int>> encoder;

  @literal
  const DatagramCodec(this.encoder, this.decoder);
}

/// A [DatagramCode] that uses UTF-8 encoding.
@immutable
class Utf8DatagramCodec extends DatagramCodec {
  @literal
  const Utf8DatagramCodec()
      : super(
          const Utf8DatagramEncoder(),
          const Utf8DatagramDecoder(),
        );
}

@immutable
class Utf8DatagramEncoder extends Converter<Datagram, List<int>> {
  const Utf8DatagramEncoder();

  @override
  List<int> convert(Datagram datagram) {
    final type = datagram.type.value.toRadixString(16);
    final addr = datagram.address;
    final port = datagram.port;

    final tokens = [type, addr, port];
    if (datagram is DataDatagram) {
      tokens.addAll([datagram.position, datagram.payload]);
    }

    return utf8Encode(tokens.join(_d) + _d);
  }
}

@immutable
class Utf8DatagramDecoder extends Converter<List<int>, Datagram> {
  const Utf8DatagramDecoder();

  @override
  Datagram convert(List<int> bytes) {
    int tokenStart = 0;
    final string = utf8Decode(bytes);

    String nextToken() {
      final tokenEnd = string.indexOf(_d, tokenStart);
      if (tokenEnd < 0) {
        throw new InvalidDatagramException(string);
      }
      final token = string.substring(tokenStart, tokenEnd);
      tokenStart = tokenEnd + 1;
      return token;
    }

    DatagramType type;
    String typeToken = nextToken();

    try {
      type = DatagramType.fromValue(int.parse(typeToken, radix: 16));
    } on FormatException catch (error) {
      throw new DatagramTypeException('$error');
    } on ArgumentError catch (error) {
      throw new DatagramTypeException('$error');
    }

    final address = nextToken();
    final port = int.parse(nextToken());

    if (type == DatagramType.DATA) {
      final position = int.parse(nextToken());
      final payloadBytesList = nextToken();
      final payload = payloadBytesList
          // drop L and R square brackets of list
          .substring(1, payloadBytesList.length - 1)
          .split(',')
          .map(int.parse)
          .toList();

      return new DataDatagram(address, port, payload, position);
    } else {
      return new Datagram(type, address, port);
    }
  }
}

/// Field delimiter for all converters.
const _d = ':';

@immutable
class DatagramCodecException implements Exception {
  final String _message;

  @literal
  const DatagramCodecException(this._message);

  @override
  String toString() => '$runtimeType: $_message';
}

@immutable
class InvalidDatagramException extends DatagramCodecException {
  @literal
  const InvalidDatagramException(String data) : super(data);
}

@immutable
class DatagramTypeException extends DatagramCodecException {
  DatagramTypeException(value) : super(value.toString());
}
