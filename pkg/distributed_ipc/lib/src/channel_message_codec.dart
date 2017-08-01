import 'dart:convert';

import 'package:distributed.objects/objects.dart';
import 'package:meta/meta.dart';

/// Decodes [ChannelMessage] instances from String.
@immutable
class ChannelMessageDecoder extends Converter<String, ChannelMessage> {
  @literal
  const ChannelMessageDecoder();

  @override
  ChannelMessage convert(String input) => deserialize<ChannelMessage>(input);
}

/// Encodes [ChannelMessage] instances as String.
@immutable
class ChannelMessageEncoder extends Converter<ChannelMessage, String> {
  @literal
  const ChannelMessageEncoder();

  @override
  String convert(ChannelMessage input) => serialize<ChannelMessage>(input);
}
