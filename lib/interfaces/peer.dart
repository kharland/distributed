/// A remote node in a distributed system.

import 'dart:convert';

import 'package:meta/meta.dart';

class Peer {
  @virtual
  final String name;

  /// This [Peer]'s hostname.
  @virtual
  final String hostname;

  /// This [Peer]'s port.
  @virtual
  final int port;

  /// Whether this node will attempt to connect to all other nodes in a new
  /// [Peer]'s network.
  @virtual
  final bool isHidden;

  const Peer(this.name, this.hostname, {this.port, this.isHidden});

  factory Peer.fromJson(Map<String, Object> json) {
    return new Peer(
      json['name'],
      json['hostname'],
      port: json['port'],
      isHidden: json['isHidden'],
    );
  }

  String get url => 'ws://$hostname:$port';

  String get displayName => "$name@$hostname";

  @override
  String toString() => displayName;

  @override
  int get hashCode => JSON.encode(toJson()).hashCode;

  @override
  bool operator ==(Object other) => other is Peer && other.hashCode == hashCode;

  Map<String, Object> toJson() => <String, Object>{
        'name': name,
        'hostname': hostname,
        'port': port,
        'isHidden': isHidden
      };
}
