import 'package:meta/meta.dart';

@immutable
class Message {
  final String content;

  @literal
  const Message(this.content);
}
