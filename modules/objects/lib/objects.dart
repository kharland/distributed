library distributed.objects.src.peer;

import 'dart:io';
import 'package:built_value/built_value.dart';
import 'package:meta/meta.dart';

part 'objects.g.dart';

abstract class Peer implements Built<Peer, PeerBuilder> {
  /// The name of this [Peer].
  String get name;

  /// This peer's host machine.
  HostMachine get hostMachine;

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
  /// The address of this machine.
  InternetAddress get address;

  /// The port where this machine's port daemon is running.
  int get daemonPort;

  HostMachine._();
  factory HostMachine([updates(HostMachineBuilder b)]) = _$HostMachine;
}

abstract class HostMachineBuilder
    implements Builder<HostMachine, HostMachineBuilder> {
  @virtual
  InternetAddress address;

  @virtual
  int daemonPort;

  HostMachineBuilder._();
  factory HostMachineBuilder() = _$HostMachineBuilder;
}
