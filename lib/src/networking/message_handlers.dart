import 'dart:async';
import 'package:distributed/interfaces/command.dart';
import 'package:distributed/src/networking/message.dart';
import 'package:distributed/interfaces/node.dart';

/// Handles messages from a peer.
abstract class MessageHandler {
  /// Returns true iff this executes on [message].
  bool filter(Message message) => true;

  /// Called when a message that passes [filter] is received.
  Future<Null> execute(Message message) => null;
}

/// Mixin to filter Messages by Type.
abstract class _FilterByType<T extends Message> implements MessageHandler {
  @override
  bool filter(Message message) => message is T;
}

/// Finalizes a connection between two nodes when a [PeerInfoMessage] is
/// received.
class PeerInfoMessageHandler extends MessageHandler
    with _FilterByType<PeerInfoMessage> {
  final Node _node;

  PeerInfoMessageHandler(this._node);

  @override
  Future<Null> execute(Message message) async {
    PeerInfoMessage remoteInfo = message;
    if (!_node.isHidden) {
      for (var remotePeer in remoteInfo.connectedPeers) {
        if (!_node.peers.contains(remotePeer) &&
            _node.toPeer().name != remotePeer.name) {
          _node.createConnection(remotePeer);
        }
      }
    }
  }
}

/// Tells a [Node] to execute a specific command when a [CommandMessage] is
/// received.
class CommandMessageHandler extends MessageHandler
    with _FilterByType<CommandMessage> {
  final Node _node;
  final Map<String, CommandHandler> _commandHandlers =
      <String, CommandHandler>{};

  CommandMessageHandler(this._node);

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
