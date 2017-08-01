library distributed.objects;

import 'package:built_value/serializer.dart';

import 'src/channel_message.dart';
export 'src/channel_message.dart';

part 'objects.g.dart';

/// Deserializes [object] as a [T]
T deserialize<T>(object) =>
    _$serializers.deserialize(object, specifiedType: new FullType(T));

/// Serializes [object].
String serialize<T>(T object) =>
    _$serializers.serialize(object, specifiedType: new FullType(T));
