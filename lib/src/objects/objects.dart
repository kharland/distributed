library distributed.objects;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:distributed/src/port_daemon/ports.dart';
import 'package:meta/meta.dart';

import 'interfaces.dart';

part 'objects.g.dart';

String serialize(Built builtValue) =>
    JSON.encode(serializers.serialize(builtValue,
        specifiedType: new FullType(builtValue.runtimeType)));

Object deserialize(String serialized, Type type) => serializers
    .deserialize(JSON.decode(serialized), specifiedType: new FullType(type));

BuiltMessage $message(String category, String contents, BuiltPeer sender) =>
    new BuiltMessage((b) => b
      ..category = category
      ..contents = contents
      ..sender = sender);

BuiltPeer $peer(String name, BuiltHostMachine hostMachine) =>
    new BuiltPeer((b) => b
      ..name = name
      ..hostMachine = hostMachine);

BuiltHostMachine $hostMachine(String address, int portDaemonPort) =>
    new BuiltHostMachine((b) => b
      ..address = address
      ..portDaemonPort = portDaemonPort);

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

abstract class BuiltMessage
    implements Built<BuiltMessage, BuiltMessageBuilder>, Message {
  static Serializer<BuiltMessage> get serializer => _$builtMessageSerializer;

  @override
  BuiltPeer get sender;

  @override
  String get category;

  @override
  String get contents;

  BuiltMessage._();
  factory BuiltMessage([updates(BuiltMessageBuilder b)]) = _$BuiltMessage;
}

abstract class BuiltMessageBuilder
    implements Builder<BuiltMessage, BuiltMessageBuilder> {
  @virtual
  BuiltPeer sender;

  @virtual
  String category;

  @virtual
  String contents;

  BuiltMessageBuilder._();
  factory BuiltMessageBuilder() = _$BuiltMessageBuilder;
}

abstract class BuiltPeer implements Built<BuiltPeer, BuiltPeerBuilder>, Peer {
  static Serializer<BuiltPeer> get serializer => _$builtPeerSerializer;

  @override
  String get name;

  @override
  BuiltHostMachine get hostMachine;

  @override
  String get displayName => '$name@${hostMachine.address}';

  BuiltPeer._();
  factory BuiltPeer([updates(BuiltPeerBuilder b)]) = _$BuiltPeer;
}

abstract class BuiltPeerBuilder
    implements Builder<BuiltPeer, BuiltPeerBuilder> {
  @virtual
  String name;

  @virtual
  BuiltHostMachine hostMachine;

  BuiltPeerBuilder._();
  factory BuiltPeerBuilder() = _$BuiltPeerBuilder;
}

abstract class BuiltHostMachine
    implements Built<BuiltHostMachine, BuiltHostMachineBuilder>, HostMachine {
  static final localHost = new BuiltHostMachine((b) => b
    ..address = 'localhost'
    ..portDaemonPort = Ports.defaultPortDaemonPort);

  static Serializer<BuiltHostMachine> get serializer =>
      _$builtHostMachineSerializer;

  @override
  String get address;

  @override
  int get portDaemonPort;

  @override
  String get portDaemonUrl => 'http://$address:$portDaemonPort';

  BuiltHostMachine._();
  factory BuiltHostMachine([updates(BuiltHostMachineBuilder b)]) =
      _$BuiltHostMachine;
}

abstract class BuiltHostMachineBuilder
    implements Builder<BuiltHostMachine, BuiltHostMachineBuilder> {
  @virtual
  String address;

  @virtual
  int portDaemonPort;

  BuiltHostMachineBuilder._();
  factory BuiltHostMachineBuilder() = _$BuiltHostMachineBuilder;
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
