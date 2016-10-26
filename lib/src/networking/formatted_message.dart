import 'package:distributed/interfaces/message.dart';
import 'package:distributed/src/networking/json.dart';

/// A wrapper to simplify [Message] decoding.
class FormattedMessage extends Message {
  /// A value that denotes how [message] should be parsed.
  final String format;

  /// The data contained in this message.
  final String message;

  FormattedMessage(this.format, this.message);

  factory FormattedMessage.fromJson(Map<String, Object> json) =>
      new FormattedMessage(json['format'], json['data']);

  @override
  Map<String, Object> toJson() =>
      <String, Object>{'format': format, 'data': message};
}
