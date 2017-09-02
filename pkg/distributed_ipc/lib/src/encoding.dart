import 'dart:convert';

import 'package:distributed.ipc/src/internal/enum.dart';
import 'package:meta/meta.dart';

@immutable
class EncodingType extends Enum {
  static const UTF8 = const EncodingType._(10, 'utf8');

  factory EncodingType.fromValue(int value) {
    if (value == UTF8.value) {
      return UTF8;
    } else {
      throw new ArgumentError(value);
    }
  }

  @literal
  const EncodingType._(int value, String name) : super(name, value);
}

/// Global utf-8 encoder.
const utf8Encoder = const Utf8Encoder();

/// Global utf-8 decoder.
const utf8Decoder = const Utf8Decoder();

/// Global utf-8 encoding callback
List<int> utf8Encode(String value) => utf8Encoder.convert(value);

/// Global utf-8 decoding callback
String utf8Decode(Iterable<int> bytes) => utf8Decoder.convert(bytes.toList());
