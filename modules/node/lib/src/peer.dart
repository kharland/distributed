import 'dart:convert';

class Peer {
  static const unknown = const Peer('unknown', 'unknown');

  final String name;
  final String address;

  const Peer(this.name, this.address);

  factory Peer.fromJson(Map<String, Object> json) =>
      new Peer(json['name'], json['address']);

  factory Peer.fromString(String peer) => new Peer.fromJson(JSON.decode(peer));

  @override
  String toString() => "$name@$address";

  @override
  bool operator ==(Object other) => other is Peer && other.hashCode == hashCode;

  @override
  int get hashCode => JSON.encode(toJson()).hashCode;

  Map<String, Object> toJson() =>
      <String, Object>{'name': name, 'address': address};
}
