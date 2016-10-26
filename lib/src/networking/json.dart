import 'dart:convert';

/// Default json encoder/decoder.
abstract class Json {
  static final JsonDecoder _decoder = new JsonDecoder();
  static final JsonEncoder _encoder = new JsonEncoder();

  static Map<String, Object> decode(String json) =>
      _decoder.convert(json) as Map<String, Object>;

  static String encode(Map<String, Object> json) =>
    _encoder.convert(json);
}
