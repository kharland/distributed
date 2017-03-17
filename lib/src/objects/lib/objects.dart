library distributed.objects.src.peer;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:distributed.port_daemon/ports.dart';
import 'package:meta/meta.dart';

part 'objects.g.dart';

String serialize(Built builtValue) =>
    JSON.encode(serializers.serialize(builtValue,
        specifiedType: new FullType(builtValue.runtimeType)));

Object deserialize(String serialized, Type type) => serializers
    .deserialize(JSON.decode(serialized), specifiedType: new FullType(type));

Message $message(String category, String payload, Peer sender) =>
    new Message((b) => b
      ..category = category
      ..payload = payload
      ..sender = sender);

Peer $peer(String name, HostMachine hostMachine) => new Peer((b) => b
  ..name = name
  ..hostMachine = hostMachine);

HostMachine $hostMachine(String address, int daemonPort) =>
    new HostMachine((b) => b
      ..address = address
      ..daemonPort = daemonPort);

PortAssignmentList $portAssignmentList(Map<String, int> assignments) =>
    new PortAssignmentList((b) =>
        b..assignments = (new MapBuilder<String, int>()..addAll(assignments)));

Registration $registration(int port, String error) => new Registration((b) => b
  ..port = port
  ..error = error);

SpawnRequest $spawnRequest(String nodeName, String uri) =>
    new SpawnRequest((b) => b
      ..nodeName = nodeName
      ..uri = uri);

abstract class PortAssignmentList
    implements Built<PortAssignmentList, PortAssignmentListBuilder> {
  static Serializer<PortAssignmentList> get serializer =>
      _$portAssignmentListSerializer;

  /// A mapping of a node's name to it's registered port.
  BuiltMap<String, int> get assignments;

  PortAssignmentList._();
  factory PortAssignmentList([updates(PortAssignmentListBuilder b)]) =
      _$PortAssignmentList;
}

abstract class PortAssignmentListBuilder
    implements Builder<PortAssignmentList, PortAssignmentListBuilder> {
  @virtual
  MapBuilder<String, int> assignments;

  PortAssignmentListBuilder._();
  factory PortAssignmentListBuilder() = _$PortAssignmentListBuilder;
}

abstract class Registration
    implements Built<Registration, RegistrationBuilder> {
  static Serializer<Registration> get serializer => _$registrationSerializer;

  /// The registered port.
  ///
  /// This value is unreliable if [error] is not empty.
  int get port;

  /// The error message if registration failed or the empty string if
  /// registration succeeded.
  String get error;

  Registration._();
  factory Registration([updates(RegistrationBuilder b)]) = _$Registration;
}

abstract class RegistrationBuilder
    implements Builder<Registration, RegistrationBuilder> {
  @virtual
  int port;

  @virtual
  String error;

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
  static final local = new HostMachine((b) => b
    ..address = 'localhost'
    ..daemonPort = Ports.defaultDaemonPort);

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
