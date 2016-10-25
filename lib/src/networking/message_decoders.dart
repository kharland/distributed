import 'package:distributed/interfaces/message.dart';
import 'package:distributed/src/networking/json.dart';

/// Decodes a [Message] from a string format.
typedef Message DecodeCallback(String message);

/// Decodes [Message]s from various string formats.
class MessageDecoder {
  final Map<String, DecodeCallback> _decodersByFormat =
      <String, DecodeCallback>{
    'PeerInfoMessage': (String message) =>
        new PeerInfoMessage.fromJson(Json.decode(message)),
    'DisconnectMessage': (String message) =>
        new DisconnectMessage.fromJson(Json.decode(message))
  };

  Message decode(String format, String data) {
    if (canDecode(format)) {
      return _decodersByFormat[format](data);
    }
    throw new UnsupportedError(format);
  }

  bool canDecode(String format) => _decodersByFormat.containsKey(format);

  void addFormat(String format, DecodeCallback decoder) {
    _decodersByFormat[format] = decoder;
  }
}
