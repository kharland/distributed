import 'dart:convert';
import 'dart:io';

class Peer {
  static const unknown = const Peer('unknown', null);

  final String name;
  final InternetAddress address;

  const Peer(this.name, this.address);

  factory Peer.fromJson(Map<String, Object> json) =>
      new Peer(json['name'], json['address']);

  factory Peer.fromString(String peer) =>
      new Peer.fromJson(JSON.decode(peer) as Map<String, Object>);

  @override
  String toString() => "$name@$address";

  @override
  bool operator ==(Object other) => other is Peer && other.hashCode == hashCode;

  @override
  int get hashCode => JSON.encode(toJson()).hashCode;

  Map<String, Object> toJson() =>
      <String, Object>{'name': name, 'address': address};
}
