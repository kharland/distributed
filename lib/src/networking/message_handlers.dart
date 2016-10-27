import 'dart:async';
import 'package:distributed/interfaces/command.dart';
import 'package:distributed/interfaces/message.dart';
import 'package:distributed/interfaces/node.dart';

/// Handles messages from a peer.
abstract class MessageHandler {
  /// Returns true iff this executes on [message].
  bool filter(Message message);

  Future<Null> execute(Message message);
}

/// General message handler that filtes by message type.
abstract class _TypedMessageHandler<T extends Message>
    implements MessageHandler {
  final Node node;

  _TypedMessageHandler(this.node);

  @override
  bool filter(Message message) => message is T;

  @override
  Future<Null> execute(Message message);
}

class PeerInfoMessageHandler extends _TypedMessageHandler<PeerInfoMessage> {
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

class CommandMessageHandler extends _TypedMessageHandler<CommandMessage> {
  final Map<String, CommandHandler> _commandHandlers =
      <String, CommandHandler>{};

  CommandMessageHandler(Node node) : super(node);

  @override
  Future<Null> execute(Message message) async {
    var command = message as CommandMessage;
    if (!_commandHandlers.containsKey(command.formatName)) {
      throw new ArgumentError('No handler for ${command.formatName}');
    }

    _commandHandlers[command.formatName](message.sender, command.arguments);
  }

  void registerHandler(String format, CommandHandler handler) {
    _commandHandlers[format] = handler;
  }
}
