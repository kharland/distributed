/// Common object interfaces.

import 'package:distributed.node/node.dart';
import 'package:distributed.objects/objects.dart' as built;
import 'package:distributed.port_daemon/port_daemon.dart';

abstract class Entity {}

/// A narrow view of a [Node], useful for connecting to or identifying the
/// [Node].
abstract class Peer extends Entity {
  static final Peer Null = new Peer('', HostMachine.Null);

  factory Peer(String name, HostMachine hostMachine) =>
      built.$peer(name, hostMachine);

  /// Short name for printing
  String get displayName;

  /// The [HostMachine] where this [Peer] is running.
  HostMachine get hostMachine;

  /// This [Peer]'s name.
  String get name;

  static Peer deserialize(String peer) =>
      built.deserialize(peer, built.BuiltPeer);
}

/// A machine where any number of [Node] instances may be running.
abstract class HostMachine extends Entity {
  static final HostMachine Null = new HostMachine('', -1);

  /// A common [HostMachine] representing the local host.
  static final localHost = built.BuiltHostMachine.localHost;

  factory HostMachine(String address, int portDaemonPort) =>
      built.$hostMachine(address, portDaemonPort);

  /// The address of this [HostMachine].
  String get address;

  /// The port where this [HostMachine]'s [PortDaemon] is running.
  int get portDaemonPort;

  /// The http url for connecting to this [HostMachine]'s [PortDaemon].
  String get portDaemonUrl;

  static HostMachine deserialize(String hostMachine) =>
      built.deserialize(hostMachine, built.BuiltHostMachine);
}

/// A data object sent from one [Node] to another.
abstract class Message extends Entity {
  static final Message Null = new Message('', '', Peer.Null);

  factory Message(String category, String contents, Peer sender) =>
      built.$message(category, contents, sender);

  /// The [BuiltPeer] that created this [BuiltMessage].
  Peer get sender;

  /// A value used to group this [BuiltMessage] with other [BuiltMessage]s.
  String get category;

  /// Data contained in this message.
  String get contents;

  static Message deserialize(String message) =>
      built.deserialize(message, built.BuiltMessage);
}

String serialize(Entity entity) {
  if (entity is Peer) {
    return built.serialize(entity as built.BuiltPeer);
  } else if (entity is HostMachine) {
    return built.serialize(entity as built.BuiltHostMachine);
  } else if (entity is Message) {
    return built.serialize(entity as built.BuiltMessage);
  } else {
    throw new UnsupportedError(entity.toString());
  }
}
