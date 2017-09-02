import 'dart:convert';

import 'package:distributed.ipc/src/internal/enum.dart';
import 'package:meta/meta.dart';

/// Used to specify the type of encoding to use for a socket.
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

const utf8Encoder = const Utf8Encoder();
const utf8Decoder = const Utf8Decoder();

/// A callback that encodes [input] as a [List] of [int].
typedef List<int> Encoder(String input);

/// A callback that decodes a [String] from [input].
typedef String Decoder(List<int> input);

/* Shorthand [Encoder] and [Decoder] callbacks. */

List<int> utf8Encode(String value) => utf8Encoder.convert(value);
String utf8Decode(Iterable<int> bytes) => utf8Decoder.convert(bytes.toList());
