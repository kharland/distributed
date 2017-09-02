import 'package:meta/meta.dart';

/// A message sent from one process to another.
@immutable
class Message {
  final String content;

  @literal
  const Message(this.content);
}
