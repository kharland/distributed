class Peer {
  final String name;
  final String hostname;
  final int port;
  final bool isHidden;

  const Peer(this.name, this.hostname, [this.port=Node.DEFAULT_PORT, this.isHidden=false]);
}