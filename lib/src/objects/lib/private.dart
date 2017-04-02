library distributed.objects;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:distributed.objects/private.dart' as objects;
import 'package:distributed.objects/public.dart' as public;

part 'private.g.dart';

String serialize(Built builtValue) =>
    JSON.encode(serializers.serialize(builtValue,
        specifiedType: new FullType(builtValue.runtimeType)));

Object deserialize(String serialized, Type type) => serializers
    .deserialize(JSON.decode(serialized), specifiedType: new FullType(type));

/* Shorthand constructors for built values */

BuiltMessage $message(String category, String contents, BuiltPeer sender) =>
    new BuiltMessage((b) => b
      ..category = category
      ..contents = contents
      ..sender = $_peerBuilder(sender));

BuiltPeer $peer(String name, BuiltHostMachine hostMachine) =>
    new BuiltPeer((b) => b
      ..name = name
      ..hostMachine = $_hostMachineBuilder(hostMachine));

BuiltHostMachine $hostMachine(String address, int portDaemonPort) =>
    new BuiltHostMachine((b) => b
      ..address = address
      ..portDaemonPort = portDaemonPort);

Registration $registration(List<int> ports, String error) =>
    new Registration((b) => b
      ..ports = new ListBuilder<int>(ports)
      ..error = error);

BuiltHostMachineBuilder $_hostMachineBuilder(BuiltHostMachine hostMachine) =>
    new BuiltHostMachineBuilder()
      ..address = hostMachine.address
      ..portDaemonPort = hostMachine.portDaemonPort;

BuiltPeerBuilder $_peerBuilder(BuiltPeer peer) => new BuiltPeerBuilder()
  ..name = peer.name
  ..hostMachine = $_hostMachineBuilder(peer.hostMachine);

/// A record of registration with the port daemon.
abstract class Registration
    implements Built<Registration, RegistrationBuilder> {
  static Serializer<Registration> get serializer => _$registrationSerializer;

  /// The list of ports associated with this registration.
  ///
  /// If any of the entities could not be registered, the corresponding port for
  /// that entity will be set to `Ports.error`.
  BuiltList<int> get ports;

  /// The error message if registration failed or the empty string if
  /// registration succeeded.
  String get error;

  Registration._();
  factory Registration([updates(RegistrationBuilder b)]) = _$Registration;

  static String serialize(Registration unserialized) =>
      objects.serialize(unserialized);

  static Registration deserialize(String serialized) =>
      objects.deserialize(serialized, Registration);
}

abstract class BuiltMessage
    implements Built<BuiltMessage, BuiltMessageBuilder>, public.Message {
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

abstract class BuiltPeer
    implements Built<BuiltPeer, BuiltPeerBuilder>, public.Peer {
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

abstract class BuiltHostMachine
    implements
        Built<BuiltHostMachine, BuiltHostMachineBuilder>,
        public.HostMachine {
  static final localHost = new BuiltHostMachine((b) => b
    ..address = 'localhost' //''127.0.0.1'
    ..portDaemonPort = 4369);

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

Serializers serializers = _$serializers;
