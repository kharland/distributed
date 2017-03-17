/// Public interfaces used to hide distributed.objects dependency on
/// built_value.
import 'package:distributed.node/node.dart';
import 'package:distributed.objects/objects.dart' as built;
import 'package:distributed.port_daemon/port_daemon.dart';

/// built_value.

/// A narrow view of a [Node], useful for connecting to or identifying the
/// [Node].
abstract class Peer {
  factory Peer(String name, built.BuiltHostMachine hostMachine) =>
      built.$peer(name, hostMachine);

  /// Short name for printing
  String get displayName;

  /// The [HostMachine] where this [Peer] is running.
  built.BuiltHostMachine get hostMachine;

  /// This [Peer]'s name.
  String get name;
}

/// A machine where any number of [Node] instances may be running.
abstract class HostMachine {
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
}

/// A data object sent from one [Node] to another.
abstract class Message {
  /// The [BuiltPeer] that created this [BuiltMessage].
  Peer get sender;

  /// A value used to group this [BuiltMessage] with other [BuiltMessage]s.
  String get category;

  /// Data contained in this message.
  String get contents;
}
