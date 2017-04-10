library distributed.objects;

import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:distributed/distributed.dart';
import 'package:distributed/src/port_daemon/ports.dart';

part 'private.g.dart';

abstract class Entity {
  static Entity deserialize(String entity, Type type) => serializers
      .deserialize(JSON.decode(entity), specifiedType: new FullType(type));

  String serialize() => JSON.encode(
      serializers.serialize(this, specifiedType: new FullType(runtimeType)));
}

/// A narrow view of a [Node], useful for connecting to or identifying the
/// [Node].
abstract class Peer extends Entity {
  static final Peer Null = new Peer('', HostMachine.Null);

  factory Peer(String name, HostMachine hostMachine) => new BuiltPeer((b) => b
    ..name = name
    ..hostMachine.replace(hostMachine));

  /// Short name for printing
  String get displayName;

  /// The [HostMachine] where this [Peer] is running.
  HostMachine get hostMachine;

  /// This [Peer]'s name.
  String get name;

  static Peer deserialize(String peer) => Entity.deserialize(peer, BuiltPeer);
}

/// A machine where any number of [Node] instances may be running.
abstract class HostMachine extends Entity {
  static final HostMachine Null = new HostMachine('', -1);

  /// A common [HostMachine] representing the local host.
  static final localHost = BuiltHostMachine.localHost;

  factory HostMachine(String address, int daemonPort) =>
      new BuiltHostMachine((b) => b
        ..address = address
        ..daemonPort = daemonPort);

  /// The address of this [HostMachine].
  String get address;

  /// The port where this [HostMachine]'s port daemon is running.
  int get daemonPort;

  /// The http url for connecting to this [HostMachine]'s port daemon.
  String get portDaemonUrl;

  static HostMachine deserialize(String hostMachine) =>
      Entity.deserialize(hostMachine, BuiltHostMachine);
}

/// A data object sent from one [Node] to another.
abstract class Message extends Entity {
  static final Message Null = new Message('', '', Peer.Null);

  factory Message(String category, String contents, Peer sender) =>
      new BuiltMessage((b) => b
        ..category = category
        ..contents = contents
        ..sender.replace(sender));

  /// The [BuiltPeer] that created this [BuiltMessage].
  Peer get sender;

  /// A value used to group this [BuiltMessage] with other [BuiltMessage]s.
  String get category;

  /// Data contained in this message.
  String get contents;

  static Message deserialize(String message) =>
      Entity.deserialize(message, BuiltMessage);
}

/// Network ports used by a [Node].
abstract class NodePorts extends Entity {
  static final NodePorts Null = new NodePorts(-1, -1, -1);

  factory NodePorts(int connectionPort, int controlPort, int diagnosticPort) =>
      new BuiltNodePorts((b) => b
        ..connectionPort = connectionPort
        ..controlPort = controlPort
        ..diagnosticPort = diagnosticPort);

  /// The port for connecting to this node using the websocket url scheme.
  int get connectionPort;

  /// The port for controlling this node using the http url scheme.
  int get controlPort;

  /// The port for diagnosing this node using the http url scheme.
  int get diagnosticPort;

  static NodePorts deserialize(String NodePorts) =>
      Entity.deserialize(NodePorts, BuiltNodePorts);
}

abstract class Registration extends Entity {
  static final Registration Null = new Registration('', NodePorts.Null);

  factory Registration(String nodeName, NodePorts ports) =>
      new BuiltRegistration((b) => b
        ..nodeName = nodeName
        ..ports = ports);

  String get nodeName;

  NodePorts get ports;

  static NodePorts deserialize(String registration) =>
      Entity.deserialize(registration, Registration);
}

//
// Private objects below this line
//

abstract class BuiltRegistration extends Entity
    implements
        Built<BuiltRegistration, BuiltRegistrationBuilder>,
        Registration {
  static Serializer<BuiltRegistration> get serializer =>
      _$builtRegistrationSerializer;

  @override
  String get nodeName;

  @override
  NodePorts get ports;

  BuiltRegistration._();
  factory BuiltRegistration([updates(BuiltRegistrationBuilder b)]) =
      _$BuiltRegistration;
}

abstract class BuiltMessage extends Entity
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

abstract class BuiltPeer extends Entity
    implements Built<BuiltPeer, BuiltPeerBuilder>, Peer {
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

abstract class BuiltHostMachine extends Entity
    implements Built<BuiltHostMachine, BuiltHostMachineBuilder>, HostMachine {
  static final localHost = new BuiltHostMachine((b) => b
    ..address = 'localhost'
    ..daemonPort = Ports.daemonPort);

  static Serializer<BuiltHostMachine> get serializer =>
      _$builtHostMachineSerializer;

  @override
  String get address;

  @override
  int get daemonPort;

  @override
  String get portDaemonUrl => 'http://$address:$daemonPort';

  BuiltHostMachine._();
  factory BuiltHostMachine([updates(BuiltHostMachineBuilder b)]) =
      _$BuiltHostMachine;
}

abstract class BuiltNodePorts extends Entity
    implements Built<BuiltNodePorts, BuiltNodePortsBuilder>, NodePorts {
  static Serializer<BuiltNodePorts> get serializer =>
      _$builtNodePortsSerializer;

  @override
  int get connectionPort;

  @override
  int get controlPort;

  @override
  int get diagnosticPort;

  BuiltNodePorts._();
  factory BuiltNodePorts([updates(BuiltNodePortsBuilder b)]) = _$BuiltNodePorts;
}

Serializers serializers = _$serializers;
