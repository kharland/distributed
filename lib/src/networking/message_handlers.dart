import 'dart:async';
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/node.dart';

/// Handles messages from a peer.
abstract class MessageHandler {
  /// Returns true iff this executes on [message].
  bool filter(Message message);

  Future<Null> execute(Message message);
}

abstract class _FilterByTypeMessageHandler<T extends Message>
    implements MessageHandler {
  final Node node;

  _FilterByTypeMessageHandler(this.node);

  @override
  bool filter(Message message) => message is T;

  @override
  Future<Null> execute(Message message);
}

class PeerInfoMessageHandler
    extends _FilterByTypeMessageHandler<PeerInfoMessage> {
  PeerInfoMessageHandler(Node node) : super(node);

  @override
  Future<Null> execute(Message message) async {
    PeerInfoMessage remoteInfo = message;
    if (!node.isHidden) {
      for (var remotePeer in remoteInfo.connectedPeers) {
        if (!node.peers.contains(remotePeer) &&
            node.toPeer().name != remotePeer.name) {
          node.createConnection(remotePeer);
        }
      }
    }
  }
}
