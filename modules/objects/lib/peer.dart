library distributed.objects.src.peer;

import 'dart:io';
import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';

part 'peer.g.dart';

abstract class Peer implements Built<Peer, PeerBuilder> {
  /// The name of this [Peer].
  String get name;

  /// The address of this [Peer].
  InternetAddress get address;

  Peer._();
  factory Peer([updates(PeerBuilder b)]) = _$Peer;
}

abstract class PeerBuilder implements Builder<Peer, PeerBuilder> {
  @virtual
  String name;

  @virtual
  InternetAddress address;

  PeerBuilder._();
  factory PeerBuilder() = _$PeerBuilder;
}
