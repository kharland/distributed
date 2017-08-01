library distributed.objects.message;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

part 'channel_message.g.dart';

/// A message sent over a channel.
@immutable
abstract class ChannelMessage
    implements Built<ChannelMessage, ChannelMessageBuilder> {
  static Serializer<ChannelMessage> get serializer =>
      _$channelMessageSerializer;

  /// The id of the queue this message belongs to.
  String get queue;

  /// The contents of this message.
  String get contents;

  ChannelMessage._();
  factory ChannelMessage(void update(ChannelMessageBuilder b)) =
      _$ChannelMessage;
}
