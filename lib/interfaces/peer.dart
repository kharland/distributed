/// A lightweight view of a node used to represent a remote peer.
class Peer {
  final String name;
  final String hostname;
  final int port;

  const Peer(this.name, this.hostname, {this.port});

  factory Peer.fromJson(Map<String, Object> json) {
    return new Peer(json['name'], json['hostname'], port: json['port']);
  }

  String get url => 'ws://$hostname:$port';

  String get displayName => "$name@$hostname";

  @override
  String toString() => 'Peer ${toJson()}';

  @override
  int get hashCode => toString().hashCode;

  @override
  bool operator ==(Object other) => other is Peer && other.hashCode == hashCode;

  Map<String, Object> toJson() =>
      <String, Object>{'name': name, 'hostname': hostname, 'port': port};
}
