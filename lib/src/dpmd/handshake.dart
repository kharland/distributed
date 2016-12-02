import 'dart:async';
import 'package:distributed/src/networking/message_channel.dart';

/// Handles incoming connection requests.
abstract class HandshakeServer {
  set maxConnections(int value);

  Stream<MessageChannel> get onChannel;
}

/// A single attempt to connect with a [Peer].
abstract class Handshake {
  Future<HandshakeResult> done;
}


class HandshakeResult {
  final bool isError;
  final Peer remote;
  final MessageChannel channel;

  HandshakeResult(this.remote, this.channel) : isError = false;
  HandshakeResult.error(this.remote, this.channel) : isError = true;
}