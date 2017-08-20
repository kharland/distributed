import 'dart:convert';

const utf8Encoder = const Utf8Encoder();
const utf8Decoder = const Utf8Decoder();

List<int> utf8Encode(String value) => utf8Encoder.convert(value);
String utf8Decode(Iterable<int> bytes) => utf8Decoder.convert(bytes.toList());
