library distributed.objects.src.peer;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:meta/meta.dart';

part 'objects.g.dart';

String serialize(Built builtValue, Type type) =>
    JSON.encode(serializers.serialize(
      builtValue,
      specifiedType: new FullType(type),
    ));

Object deserialize(String serialized, Type type) => serializers.deserialize(
      JSON.decode(serialized),
      specifiedType: new FullType(type),
    );

Message createMessage(String category, String payload, Peer sender) =>
    new Message((b) => b
      ..category = category
      ..payload = payload
      ..sender = sender);

Peer createPeer(String name, HostMachine hostMachine) => new Peer((b) => b
  ..name = name
  ..hostMachine = hostMachine);

HostMachine createHostMachine(String address, int daemonPort) =>
    new HostMachine((b) => b
      ..address = address
      ..daemonPort = daemonPort);

Registration createRegistration([String name = '', int port = -1]) =>
    new Registration((b) => b
      ..name = name
      ..port = port);

abstract class Registration
    implements Built<Registration, RegistrationBuilder> {
  static Serializer<Registration> get serializer => _$registrationSerializer;

  /// The name of the node being registered.
  String get name;

  /// The port registered to the node with [name] or -1 if registration failed
  int get port;

  Registration._();
  factory Registration([updates(RegistrationBuilder b)]) = _$Registration;
}

abstract class RegistrationBuilder
    implements Builder<Registration, RegistrationBuilder> {
  @virtual
  String name;

  @virtual
  int port;

  @virtual
  bool failed;

  RegistrationBuilder._();
  factory RegistrationBuilder() = _$RegistrationBuilder;
}

abstract class Message implements Built<Message, MessageBuilder> {
  static Serializer<Message> get serializer => _$messageSerializer;

  /// The [Peer] that created this [Message].
  Peer get sender;

  /// A value used to group this [Message] with other [Message]s.
  String get category;

  /// Data contained in this message. TODO(kharland): Change to 'contents'.
  String get payload;

  Message._();
  factory Message([updates(MessageBuilder b)]) = _$Message;
}

abstract class MessageBuilder implements Builder<Message, MessageBuilder> {
  @virtual
  Peer sender;

  @virtual
  String category;

  @virtual
  String payload;

  MessageBuilder._();
  factory MessageBuilder() = _$MessageBuilder;
}

abstract class Peer implements Built<Peer, PeerBuilder> {
  static Serializer<Peer> get serializer => _$peerSerializer;

  /// The name of this [Peer].
  String get name;

  /// This peer's host machine.
  HostMachine get hostMachine;

  String get displayName => '$name@${hostMachine.address}';

  Peer._();
  factory Peer([updates(PeerBuilder b)]) = _$Peer;
}

abstract class PeerBuilder implements Builder<Peer, PeerBuilder> {
  @virtual
  String name;

  @virtual
  HostMachine hostMachine;

  PeerBuilder._();
  factory PeerBuilder() = _$PeerBuilder;
}

abstract class HostMachine implements Built<HostMachine, HostMachineBuilder> {
  static Serializer<HostMachine> get serializer => _$hostMachineSerializer;

  /// The address of this machine.
  String get address;

  /// The port where this machine's port daemon is running.
  int get daemonPort;

  String get daemonUrl => 'http://$address:$daemonPort';

  HostMachine._();
  factory HostMachine([updates(HostMachineBuilder b)]) = _$HostMachine;
}

abstract class HostMachineBuilder
    implements Builder<HostMachine, HostMachineBuilder> {
  @virtual
  String address;

  @virtual
  int daemonPort;

  HostMachineBuilder._();
  factory HostMachineBuilder() = _$HostMachineBuilder;
}

abstract class SpawnRequest
    implements Built<SpawnRequest, SpawnRequestBuilder> {
  static Serializer<SpawnRequest> get serializer => _$spawnRequestSerializer;

  /// The name of the node to spawn.
  String get nodeName;

  /// The uri containing the node's source code.
  String get uri;

  SpawnRequest._();
  factory SpawnRequest([updates(SpawnRequestBuilder b)]) = _$SpawnRequest;
}

abstract class SpawnRequestBuilder
    implements Builder<SpawnRequest, SpawnRequestBuilder> {
  @virtual
  String nodeName;

  @virtual
  String uri;

  SpawnRequestBuilder._();
  factory SpawnRequestBuilder() = _$SpawnRequestBuilder;
}

Serializers serializers = _$serializers;
