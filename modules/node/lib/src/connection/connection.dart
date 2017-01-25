import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/peer.dart';

class Connection<T> {
  final Peer peer;
  final ConnectionChannels<T> channels;

  const Connection(this.peer, this.channels);
}
