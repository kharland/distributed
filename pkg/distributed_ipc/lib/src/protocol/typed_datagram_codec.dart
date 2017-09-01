import 'dart:convert';

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:meta/meta.dart';

/// Field delimiter for all converters.
const _d = ':';

/// A code for encoding and decoding [Datagram]s.
@immutable
class DatagramCodec extends Codec<Datagram, List<int>> {
  static const _decoder = const DatagramDecoder();
  static const _encoder = const DatagramEncoder();

  @override
  Converter<List<int>, Datagram> get decoder => _decoder;

  @override
  Converter<Datagram, List<int>> get encoder => _encoder;

  @literal
  const DatagramCodec();
}

@immutable
class DatagramEncoder extends Converter<Datagram, List<int>> {
  const DatagramEncoder();

  @override
  List<int> convert(Datagram dg) {
    return utf8Encode(<String>[
      '${dg.type}',
      '${dg.address}',
      '${dg.port}',
      '${dg.data}',
    ].join(_d));
  }
}

@immutable
class DatagramDecoder extends Converter<List<int>, Datagram> {
  const DatagramDecoder();

  @override
  Datagram convert(List<int> bytes) {
    final tokens = utf8Decode(bytes).split(_d);
    const TYPE = 0;
    const ADDRESS = 1;
    const PORT = 2;
    const DATA = 3;

    try {
      final data = tokens[DATA]
          // Remove '[' and ']'
          .substring(1, tokens[DATA].length - 1)
          .split(',')
          .map(int.parse)
          .toList();

      final type = int.parse(tokens[TYPE]);
      if (!DatagramType.isValid(type)) {
        throw new DatagramTypeException(type);
      }

      return new Datagram(
        data,
        tokens[ADDRESS],
        int.parse(tokens[PORT]),
        int.parse(tokens[TYPE]),
      );
    } catch (error) {
      throw new DatagramDecodeException('$error');
    }
  }
}

@immutable
class DatagramCodecException implements Exception {
  final String _message;

  @literal
  const DatagramCodecException(this._message);

  @override
  String toString() => '$runtimeType: $_message';
}

@immutable
class DatagramDecodeException extends DatagramCodecException {
  @literal
  const DatagramDecodeException(String encodedDatagram)
      : super(encodedDatagram);
}

@immutable
class DatagramTypeException extends DatagramCodecException {
  DatagramTypeException(int value) : super(value.toRadixString(16));
}
