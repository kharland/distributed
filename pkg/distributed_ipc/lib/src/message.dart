import 'package:meta/meta.dart';

@immutable
class NodeMessage {
  final String content;

  @literal
  const NodeMessage(this.content);
}
