import 'dart:async';

import 'package:distributed.node/src/connection/connection_channels.dart';
import 'package:distributed.node/src/message/message.dart';
import 'package:distributed.node/src/peer.dart';

class Connection {
  final Peer peer;
  final ConnectionChannels<Message> channels;

  const Connection(this.peer, this.channels);

  Future<Peer> get done => channels.done.then((_) => peer);
}
