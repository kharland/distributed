import 'dart:convert';

import 'package:distributed.ipc/src/encoding.dart';
import 'package:distributed.ipc/src/protocol/typed_datagram.dart';
import 'package:meta/meta.dart';

/// Field delimiter for all converters.
const _d = ':';

/// A code for encoding and decoding [TypedDatagram]s.
@immutable
class TypedDatagramCodec extends Codec<TypedDatagram, List<int>> {
  static const _decoder = const TypedDatagramDecoder();
  static const _encoder = const TypedDatagramEncoder();

  @override
  Converter<List<int>, TypedDatagram> get decoder => _decoder;

  @override
  Converter<TypedDatagram, List<int>> get encoder => _encoder;

  @literal
  const TypedDatagramCodec();
}

@immutable
class TypedDatagramEncoder extends Converter<TypedDatagram, List<int>> {
  const TypedDatagramEncoder();

  @override
  List<int> convert(TypedDatagram dg) {
    return utf8Encode(<String>[
      '${dg.type}',
      '${dg.address}',
      '${dg.port}',
      '${dg.data}',
    ].join(_d));
  }
}

@immutable
class TypedDatagramDecoder extends Converter<List<int>, TypedDatagram> {
  const TypedDatagramDecoder();

  @override
  TypedDatagram convert(List<int> bytes) {
    final tokens = utf8Decode(bytes).split(_d);
    const TYPE = 0;
    const ADDRESS = 1;
    const PORT = 2;
    const DATA = 3;

    final data = tokens[DATA]
        // Remove '[' and ']'
        .substring(1, tokens[DATA].length - 1)
        .split(',')
        .map(int.parse)
        .toList();

    return new TypedDatagram(
      data,
      tokens[ADDRESS],
      int.parse(tokens[PORT]),
      int.parse(tokens[TYPE]),
    );
  }
}

@immutable
class TypedDatagramCodeException implements Exception {
  final String _message;

  @literal
  const TypedDatagramCodeException(this._message);

  @override
  String toString() => '$runtimeType: $_message';
}

class InvalidTypedDatagramDataException extends TypedDatagramCodeException {
  @literal
  const InvalidTypedDatagramDataException(String encodedTypedDatagram)
      : super(encodedTypedDatagram);
}
