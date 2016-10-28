/// A lightweight view of a node used to represent a remote peer.
class Peer {
  final String name;
  final String hostname;
  final int port;

  const Peer(this.name, this.hostname, {this.port});

  factory Peer.fromJson(Map<String, Object> json) {
    return new Peer(json['name'], json['hostname'], port: json['port']);
  }

  /// Creates a peer from [namesAndPort].
  ///
  /// The format of [namesAndPort] is: <name>@<hostname>:<port>
  ///
  /// port is optional and defalts to 8080.
  ///
  /// Throws a [FormatException] if [namesAndPort] is invaild
  factory Peer.fromNamesAndPort(String namesAndPort) {
    var parts = namesAndPort.split(':');
    var nameParts = parts.first.split('@');
    var port = 8080;
    if (parts.length > 1) {
      try {
        port = int.parse(parts.last);
      } on FormatException catch (_) {
        throw new FormatException('Invalid port number: ${parts.last}');
      }
    }
    if (nameParts.length != 2) {
      throw new FormatException('Name or Hostname missing from $namesAndPort');
    } else {
      return new Peer(nameParts.first, nameParts.last, port: port);
    }
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
