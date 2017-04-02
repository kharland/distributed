/// Common object interfaces visible to client libraries.

import 'package:distributed/src/node/node.dart';
import 'package:distributed/src/port_daemon/port_daemon.dart';

import 'package:distributed.objects/private.dart' as internal;

abstract class Entity {}

/// A narrow view of a [Node], useful for connecting to or identifying the
/// [Node].
abstract class Peer extends Entity {
  static final Peer Null = new Peer('', HostMachine.Null);

  factory Peer(String name, HostMachine hostMachine) =>
      // ignore: return_of_invalid_type, argument_type_not_assignable
      internal.$peer(name, hostMachine);

  /// Short name for printing
  String get displayName;

  /// The [HostMachine] where this [Peer] is running.
  HostMachine get hostMachine;

  /// This [Peer]'s name.
  String get name;

  static String serialize(Peer unserialized) =>
      internal.serialize(unserialized as internal.BuiltPeer);

  static Peer deserialize(String serialized) =>
      internal.deserialize(serialized, internal.BuiltPeer);
}

/// A machine where any number of [Node] instances may be running.
abstract class HostMachine extends Entity {
  static final HostMachine Null = new HostMachine('', -1);

  /// A common [HostMachine] representing the local host.
  static final localHost = internal.BuiltHostMachine.localHost;

  factory HostMachine(String address, int portDaemonPort) =>
      // ignore: return_of_invalid_type
      internal.$hostMachine(address, portDaemonPort);

  /// The address of this [HostMachine].
  String get address;

  /// The port where this [HostMachine]'s [PortDaemon] is running.
  int get portDaemonPort;

  /// The http url for connecting to this [HostMachine]'s [PortDaemon].
  String get portDaemonUrl;

  static String serialize(HostMachine unserialized) =>
      internal.serialize(unserialized as internal.BuiltHostMachine);

  static HostMachine deserialize(String serialized) =>
      internal.deserialize(serialized, internal.BuiltHostMachine);
}

/// A data object sent from one [Node] to another.
abstract class Message extends Entity {
  static final Message Null = new Message('', '', Peer.Null);

  factory Message(String category, String contents, Peer sender) =>
      // ignore: return_of_invalid_type, argument_type_not_assignable
      internal.$message(category, contents, sender);

  /// The [BuiltPeer] that created this [BuiltMessage].
  Peer get sender;

  /// A value used to group this [BuiltMessage] with other [BuiltMessage]s.
  String get category;

  /// Data contained in this message.
  String get contents;

  static String serialize(Message unserialized) =>
      internal.serialize(unserialized as internal.BuiltMessage);

  static Message deserialize(String serialized) =>
      internal.deserialize(serialized, internal.BuiltMessage);
}
